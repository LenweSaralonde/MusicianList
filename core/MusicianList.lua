MusicianList = LibStub("AceAddon-3.0"):NewAddon("MusicianList", "AceEvent-3.0")

local LibDeflate

local isSongSaving = false
local isSongLoading = false

local MusicianGetCommands
local MusicianButtonGetMenu

local EXTRACT_PROGRESSION_RATIO = .33

--- OnInitialize
--
function MusicianList:OnInitialize()

	-- Init storage
	if MusicianList_Storage == nil then
		MusicianList_Storage = {
			['version'] = MusicianList.STORAGE_VERSION,
			['data'] = {}
		}
		MusicianList.RestoreDemoSongs()
	end

	-- Check for outdated Musician version
	if Musician.Utils.VersionCompare(MusicianList.MUSICIAN_MIN_VERSION, GetAddOnMetadata("Musician", "Version")) > 0 or MusicianList.FILE_HEADER > Musician.FILE_HEADER then
		C_Timer.After(10, function()
			Musician.Utils.Error(MusicianList.Msg.ERR_OUTDATED_MUSICIAN_VERSION)
		end)
		return
	end

	-- Check if Musician format is more recent that the one supported by MusicianList
	-- Also ensure the catalogue version is correct
	if MusicianList.FILE_HEADER < Musician.FILE_HEADER or MusicianList_Storage.version > MusicianList.STORAGE_VERSION then
		C_Timer.After(10, function()
			Musician.Utils.Error(MusicianList.Msg.ERR_OUTDATED_MUSICIANLIST_VERSION)
		end)
		return
	end

	MusicianList.Updater.UpdateDB(MusicianList.OnReady)
end

--- Second initialization phase, when all DB updates are complete
--
function MusicianList.OnReady()
	-- Import libraries
	LibDeflate = LibStub:GetLibrary("LibDeflate")

	-- Create frame
	-- @var processFrame (Frame)
	MusicianList.processFrame = CreateFrame("Frame")
	MusicianList.processFrame:SetFrameStrata("HIGH")
	MusicianList.processFrame:EnableMouse(false)
	MusicianList.processFrame:SetMovable(false)

	-- Keep the raw binary song data so we can save it later
	MusicianList:RegisterMessage(Musician.Events.SourceSongLoaded, function(event, song, data)
		MusicianList.RefreshFrame()
	end)

	-- Notify loading progression
	MusicianList:RegisterMessage(Musician.Events.SongImportProgress, function(event, song, progression)
		MusicianList:SendMessage(MusicianList.Events.SongLoadProgress, song, progression)
	end)

	-- Notify saving progression
	MusicianList:RegisterMessage(Musician.Events.SongExportProgress, MusicianList.OnSongExport)
	MusicianList:RegisterMessage(Musician.Events.SongExportStart, MusicianList.OnSongExport)
	MusicianList:RegisterMessage(Musician.Events.SongExportComplete, MusicianList.OnSongExport)

	-- Hook Musician functions
	MusicianGetCommands = Musician.GetCommands
	Musician.GetCommands = MusicianList.GetCommands
	MusicianButtonGetMenu = MusicianButton.GetMenu
	MusicianButton.GetMenu = MusicianList.GetMenu

	-- Static popups
	--

	-- Delete song
	StaticPopupDialogs["MUSICIAN_LIST_DELETE_CONFIRM"] = {
		preferredIndex = STATICPOPUPS_NUMDIALOGS,
		text = MusicianList.Msg.DELETE_CONFIRM,
		button1 = YES,
		button2 = NO,
		OnAccept = function(self, params)
			MusicianList.DoDelete(params.id, params.fromCommandLine)
		end,
		timeout = 30,
		whileDead = 1,
		hideOnEscape = 1,
	}

	-- Save song
	StaticPopupDialogs["MUSICIAN_LIST_SAVE"] = {
		preferredIndex = STATICPOPUPS_NUMDIALOGS,
		text = MusicianList.Msg.SAVE_SONG_AS,
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = 1,
		maxBytes = Musician.Song.MAX_NAME_LENGTH,
		editBoxWidth = 350,
		OnAccept = function(self, params)
			local name = self.editBox:GetText()
			MusicianList.SaveConfirm(name, params.fromCommandLine)
		end,
		EditBoxOnEnterPressed = function(self, params)
			local parent = self:GetParent()
			local name = parent.editBox:GetText()
			MusicianList.SaveConfirm(name, params.fromCommandLine)
			parent:Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		OnShow = function(self, params)
			self.editBox:SetText(Musician.Utils.NormalizeSongName(params.name))
			self.editBox:HighlightText(0)
			self.editBox:SetFocus()
		end,
		OnHide = function(self)
			ChatEdit_FocusActiveWindow()
			self.editBox:SetText("")
		end,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		hideOnEscape = 1
	}

	-- Rename song
	StaticPopupDialogs["MUSICIAN_LIST_RENAME"] = {
		preferredIndex = STATICPOPUPS_NUMDIALOGS,
		text = MusicianList.Msg.RENAME_SONG,
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = 1,
		maxBytes = Musician.Song.MAX_NAME_LENGTH,
		editBoxWidth = 350,
		OnAccept = function(self, params)
			local name = self.editBox:GetText()
			MusicianList.RenameConfirm(params.id, name, params.fromCommandLine)
		end,
		EditBoxOnEnterPressed = function(self, params)
			local parent = self:GetParent()
			local name = parent.editBox:GetText()
			MusicianList.RenameConfirm(params.id, name, params.fromCommandLine)
			parent:Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		OnShow = function(self, params)
			self.editBox:SetText(Musician.Utils.NormalizeSongName(params.oldName))
			self.editBox:HighlightText(0)
			self.editBox:SetFocus()
		end,
		OnHide = function(self)
			ChatEdit_FocusActiveWindow()
			self.editBox:SetText("")
		end,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		hideOnEscape = 1
	}

	-- Overwrite confirmation
	StaticPopupDialogs["MUSICIAN_LIST_OVERWRITE_CONFIRM"] = {
		preferredIndex = STATICPOPUPS_NUMDIALOGS,
		text = MusicianList.Msg.OVERWRITE_CONFIRM,
		button1 = YES,
		button2 = NO,
		OnAccept = function(self, callback)
			callback()
		end,
		timeout = 30,
		whileDead = 1,
		hideOnEscape = 1,
	}

	-- Init UI
	MusicianList.Frame.Init()
	MusicianList.AddButtons()
end

--- OnSongExport
-- Handle song export events
function MusicianList.OnSongExport(event, song, ...)
	if not(song.isSaving) then return end

	local saveEvent
	if event == Musician.Events.SongExportProgress then
		saveEvent = MusicianList.Events.SongSaveProgress
	elseif event == Musician.Events.SongExportStart then
		saveEvent = MusicianList.Events.SongSaveStart
	elseif event == Musician.Events.SongExportComplete then
		saveEvent = MusicianList.Events.SongSaveComplete
	end
	MusicianList:SendMessage(saveEvent, song, ...)
end

--- Get command definitions
-- @return commands (table)
function MusicianList.GetCommands()
	local commands = MusicianGetCommands()
	local isOldPlayCommand = Musician.Utils.VersionCompare(GetAddOnMetadata("Musician", "Version"), '1.5.0.4') <= 0

	-- Replace existing "Play" command

	local playFunc = commands[2].func
	Musician.Utils.DeepMerge(commands[2], {
		text = isOldPlayCommand and MusicianList.Msg.COMMAND_PLAY_OLD or MusicianList.Msg.COMMAND_PLAY,
		params = MusicianList.Msg.COMMAND_PLAY_PARAMS,
		func = function(value)
			if value ~= "" then
				MusicianList.Load(value, MusicianList.LoadActions.Play, true)
			else
				playFunc()
			end
		end
	})

	-- Replace existing "Preview" command

	local previewFunc = commands[4].func
	Musician.Utils.DeepMerge(commands[4], {
		text = isOldPlayCommand and MusicianList.Msg.COMMAND_PREVIEW_OLD or MusicianList.Msg.COMMAND_PREVIEW,
		params = MusicianList.Msg.COMMAND_PREVIEW_PARAMS,
		func = function(value)
			if value ~= "" then
				MusicianList.Load(value, MusicianList.LoadActions.Preview, true)
			else
				previewFunc()
			end
		end
	})

	-- List songs

	table.insert(commands, #commands - 2, {
		command = { "list", "songs" },
		text = MusicianList.Msg.COMMAND_LIST,
		func = function()
			MusicianListFrame:Show()
		end
	})

	-- Find song

	table.insert(commands, #commands - 2, {
		command = { "find", "search", "filter" },
		text = MusicianList.Msg.COMMAND_FIND,
		params = MusicianList.Msg.COMMAND_FIND_PARAMS,
		func = function(filter)
			MusicianList.Frame.Filter(filter)
			MusicianListFrame:Show()
		end
	})

	-- Load song

	table.insert(commands, #commands - 2, {
		command = { "load" },
		text = MusicianList.Msg.COMMAND_LOAD,
		params = MusicianList.Msg.COMMAND_LOAD_PARAMS,
		func = function(value)
			MusicianList.Load(value, nil, true)
		end
	})

	-- Save song

	table.insert(commands, #commands - 2, {
		command = { "save" },
		text = MusicianList.Msg.COMMAND_SAVE,
		params = MusicianList.Msg.COMMAND_SAVE_PARAMS,
		func = function(value)
			MusicianList.Save(value, true)
		end
	})

	-- Delete song

	table.insert(commands, #commands - 2, {
		command = { "delete", "del", "remove", "rm" },
		text = MusicianList.Msg.COMMAND_DELETE,
		params = MusicianList.Msg.COMMAND_DELETE_PARAMS,
		func = function(value)
			MusicianList.Delete(value, true)
		end
	})

	-- Rename song

	table.insert(commands, #commands - 2, {
		command = { "rename", "ren", "mv" },
		text = MusicianList.Msg.COMMAND_RENAME,
		params = MusicianList.Msg.COMMAND_RENAME_PARAMS,
		func = function(argStr)
			local argsTable = { strsplit(" ", argStr) }
			local index = table.remove(argsTable, 1)
			local name = strtrim(table.concat(argsTable, " "))
			MusicianList.Rename(index, name, true)
		end
	})

	-- Restore demo songs

	table.insert(commands, #commands - 2, {
		command = { "demosongs" },
		text = MusicianList.Msg.COMMAND_RESTORE_DEMO,
		func = function(argStr)
			MusicianList.RestoreDemoSongs(true)
			MusicianList:SendMessage(MusicianList.Events.ListUpdate)
			Musician.Utils.Print(MusicianList.Msg.DEMO_SONGS_RESTORED)
		end
	})

	return commands
end

--- Return main menu elements
-- @return menu (table)
function MusicianList.GetMenu()
	local menu = MusicianButtonGetMenu()

	-- Show song list

	table.insert(menu, 3, {
		notCheckable = true,
		text = MusicianList.Msg.MENU_LIST,
		func = function()
			MusicianListFrame:Show()
		end
	})

	return menu
end

--- Add buttons in Musician UI
--
function MusicianList.AddButtons()
	local buttonWidth = 25

	local listButton = CreateFrame("Button", "MusicianFrameListButton", MusicianFrame, "MusicianListIconButtonTemplate")
	MusicianFrameListButtonText:SetPoint("LEFT", 6, 0)
	listButton:SetWidth(buttonWidth)
	listButton:SetHeight(22)
	listButton:SetText(MusicianList.Icons.List)
	listButton.tooltipText = MusicianList.Msg.MENU_LIST
	listButton:SetPoint("TOPRIGHT", -10, -10)
	listButton:HookScript("OnClick", function()
		MusicianListFrame:Show()
	end)

	local saveButton = CreateFrame("Button", "MusicianFrameSaveButton", MusicianFrame, "MusicianListIconButtonTemplate")
	MusicianFrameSaveButtonText:SetPoint("LEFT", 8, 0)
	saveButton:SetWidth(buttonWidth)
	saveButton:SetHeight(22)
	saveButton:SetText(MusicianList.Icons.Save)
	saveButton.tooltipText = MusicianList.Msg.ACTION_SAVE
	saveButton:SetPoint("TOPRIGHT", -10 - buttonWidth, -10)
	saveButton:HookScript("OnClick", function()
		MusicianList.Save()
	end)

	local linkButton = MusicianFrameLinkButton
	linkButton.icon:SetPoint("LEFT", 7, 0)
	linkButton:SetWidth(buttonWidth)
	linkButton.tooltipText = linkButton:GetText()
	linkButton:SetText('')
	linkButton:SetPoint("TOPRIGHT", -10 - 2 * buttonWidth, -10)

	MusicianFrameTrackEditorButton:SetWidth(buttonWidth * 3)

	local trackEditorSaveButton = CreateFrame("Button", "MusicianTrackEditorSaveButton", MusicianTrackEditor, "MusicianListIconButtonTemplate")
	trackEditorSaveButton:SetWidth(50)
	trackEditorSaveButton:SetHeight(20)
	trackEditorSaveButton:SetText(MusicianList.Icons.Save)
	trackEditorSaveButton.tooltipText = MusicianList.Msg.ACTION_SAVE
	trackEditorSaveButton:SetPoint("RIGHT", MusicianTrackEditorGoToStartButton, "LEFT", -40, 0)
	trackEditorSaveButton:HookScript("OnClick", function()
		MusicianList.Save()
	end)

	local importFrame = MusicianSongLinkImportFrame
	local importIntoListButton = CreateFrame("Button", "MusicianListImportIntoListButton", importFrame, "UIPanelButtonTemplate")
	local importButton = importFrame.importButton
	local cancelButton = importFrame.cancelImportButton
	importIntoListButton:SetWidth(importButton:GetWidth())
	importIntoListButton:SetHeight(importButton:GetHeight())
	importIntoListButton:SetText(MusicianList.Msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON)
	importIntoListButton:SetPoint("TOP", importButton, "BOTTOM", 0, -5)
	importFrame:SetHeight(importFrame:GetHeight() + importIntoListButton:GetHeight() + 5)
	importIntoListButton:HookScript("OnClick", function()
		importIntoListButton.onClick()
	end)

	local function updateSongLinkImportFrame(title, playerName)
		playerName = Musician.Utils.NormalizePlayerName(playerName)

		-- Get currently requesting song title from the player, if any
		local requestingSong = Musician.SongLinks.GetRequestingSong(playerName)
		if requestingSong then
			title = requestingSong.title
			if requestingSong.dataOnly then
				importButton:Disable()
				importButton:Show()
				importIntoListButton:Hide()
				cancelButton:SetPoint('TOP', importIntoListButton, 'TOP')
			else
				importButton:Hide()
				importIntoListButton:Disable()
				importIntoListButton:Show()
				cancelButton:SetPoint('TOP', importButton, 'TOP')
			end
		else
			importButton:Enable()
			importButton:Show()
			importIntoListButton:Enable()
			importIntoListButton:Show()
		end
	end

	MusicianList:RegisterMessage(Musician.Events.SongLink, function(event, title, playerName)
		playerName = Musician.Utils.NormalizePlayerName(playerName)

		updateSongLinkImportFrame(title, playerName)

		importIntoListButton.onClick = function()
			if not(Musician.SongLinks.GetRequestingSong(playerName)) then
				Musician.SongLinks.RequestSong(title, playerName, true)
			end
		end

		-- Start import
		MusicianList:RegisterMessage(Musician.Events.SongReceiveStart, function(event, sender)
			sender = Musician.Utils.NormalizePlayerName(sender)
			if sender ~= playerName then return end
			updateSongLinkImportFrame(title, playerName)
		end)

		-- Import successful
		MusicianList:RegisterMessage(Musician.Events.SongReceiveSucessful, function(event, sender, songData, song)
			sender = Musician.Utils.NormalizePlayerName(sender)
			if sender ~= playerName then return end

			local isDataOnly = song == nil
			if not(isDataOnly) then return end

			local compressedCursor = 1

			-- Check file format
			local compressedHeader = string.sub(songData, compressedCursor, #Musician.FILE_HEADER_COMPRESSED)
			compressedCursor = compressedCursor + #Musician.FILE_HEADER_COMPRESSED
			if compressedHeader ~= Musician.FILE_HEADER_COMPRESSED then
				Musician.Utils.Error(Musician.Msg.INVALID_MUSIC_CODE)
				return
			end

			-- Extract first compressed chunk containing full song name
			local firstChunkLength = Musician.Utils.UnpackNumber(string.sub(songData, compressedCursor, compressedCursor + 1))
			compressedCursor = compressedCursor + 2
			local firstChunk = LibDeflate:DecompressDeflate(string.sub(songData, compressedCursor, compressedCursor + firstChunkLength - 1))
			compressedCursor = compressedCursor + firstChunkLength

			-- Extract second compressed chunk containing the song duration
			local secondChunkLength = Musician.Utils.UnpackNumber(string.sub(songData, compressedCursor, compressedCursor + 1))
			compressedCursor = compressedCursor + 2
			local secondChunk = LibDeflate:DecompressDeflate(string.sub(songData, compressedCursor, compressedCursor + secondChunkLength - 1))

			-- Extract song name from the first chunk
			local cursor = 1
			local songTitleLength = Musician.Utils.UnpackNumber(string.sub(firstChunk, cursor, cursor + 1))
			cursor = cursor + 2
			local songName = Musician.Utils.NormalizeSongName(string.sub(firstChunk, cursor, cursor + songTitleLength - 1))

			-- Extract duration from the second chunk
			local duration = Musician.Utils.UnpackNumber(string.sub(secondChunk, 2, 4))

			-- Add song to the list
			local songId = MusicianList.GetSongId(songName)
			MusicianList_Storage.data[songId] = {
				name = songName,
				format = Musician.FILE_HEADER,
				data = songData,
				duration = duration,
			}
			MusicianList:SendMessage(MusicianList.Events.ListUpdate)
			MusicianList.RefreshFrame()
		end)
	end)

	-- Enable or disable buttons according to current UI state
	MusicianList.RefreshFrame()
end

--- Update Musician UI elements
--
function MusicianList.RefreshFrame()
	if not(isSongSaving) and not(isSongLoading) then
		if Musician.sourceSong then
			MusicianFrameSaveButton:Enable()
			MusicianTrackEditorSaveButton:Enable()
			MusicianFrameLinkButton:Enable()
		else
			MusicianFrameSaveButton:Disable()
			MusicianTrackEditorSaveButton:Disable()
			MusicianFrameLinkButton:Disable()
		end
		MusicianFrameSource:Enable()
		MusicianFrameClearButton:Enable()
	else
		MusicianFrameSaveButton:Disable()
		MusicianTrackEditorSaveButton:Disable()
		MusicianFrameLinkButton:Disable()
		MusicianFrameSource:Disable()
		MusicianFrameClearButton:Disable()
	end
end

--- Get sorted song list
-- @return list (table)
function MusicianList.GetSongList()
	local list = {}
	local songData, id
	for id, songData in pairs(MusicianList_Storage.data) do
		table.insert(list, {
			id = id,
			name = songData.name,
			searchName = MusicianList.SearchString(songData.name),
			duration = songData.duration
		})
	end

	table.sort(list, function(a, b)
		return a.searchName < b.searchName
	end)

	-- Add indexes
	local index, song
	for index, song in pairs(list) do
		song.index = index
	end

	return list
end

--- Save song, showing "save as" dialog if no name is provided
-- @param[opt] name (string)
-- @param[opt=false] fromCommandLine (boolean)
function MusicianList.Save(name, fromCommandLine)
	-- No source song
	if not(Musician.sourceSong) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_NO_SONG_TO_SAVE)
		return
	end

	-- Defaults to loaded song
	if name == nil or name == '' then
		StaticPopup_Show("MUSICIAN_LIST_SAVE", nil, nil, { name = Musician.sourceSong.name, fromCommandLine = fromCommandLine })
	else
		MusicianList.SaveConfirm(name, fromCommandLine)
	end
end

--- Save song, requesting to overwrite existing song
-- @param[opt] name (string)
-- @param[opt=false] fromCommandLine (boolean)
function MusicianList.SaveConfirm(name, fromCommandLine)
	name = Musician.Utils.NormalizeSongName(name)

	local song, id = MusicianList.GetSong(MusicianList.GetSongId(name))

	if song then
		StaticPopup_Show("MUSICIAN_LIST_OVERWRITE_CONFIRM", Musician.Utils.Highlight(name), nil, function()
			MusicianList.DoSave(name, fromCommandLine)
		end)
	else
		MusicianList.DoSave(name, fromCommandLine)
	end
end

--- Save song, without confirmation
-- @param name (string)
-- @param[opt=false] fromCommandLine (boolean)
function MusicianList.DoSave(name, fromCommandLine)
	name = Musician.Utils.NormalizeSongName(name)

	if isSongSaving or isSongLoading then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_CANNOT_SAVE_NOW)
		return
	end

	if not(Musician.sourceSong) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_NO_SONG_TO_SAVE)
		return
	end

	if not(name) or name == "" then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NAME_EMPTY)
		return
	end

	if fromCommandLine then
		Musician.Utils.Print(string.gsub(MusicianList.Msg.SAVING_SONG, "{name}", Musician.Utils.Highlight(name)))
	end

	isSongSaving = true
	local song = Musician.sourceSong

	local songId = MusicianList.GetSongId(name)
	local songData = {
		name = name,
		format = Musician.FILE_HEADER,
		data = '',
		duration = song.cropTo - song.cropFrom,
	}

	MusicianList.RefreshFrame()

	song.isInList = true
	song.isSaving = true

	song.name = name

	song:ExportCompressed(function(data)
		songData.data = data

		MusicianList_Storage.data[songId] = songData
		Musician.sourceSong.name = name
		MusicianList:SendMessage(MusicianList.Events.ListUpdate)

		if fromCommandLine then
			Musician.Utils.Print(MusicianList.Msg.DONE_SAVING)
		end

		song.isSaving = nil
		isSongSaving = false
		MusicianList.RefreshFrame()
	end)
end

--- Load song
-- @param idOrIndex (string)
-- @param action (number) Action to perform after loading
-- @param[opt=false] fromCommandLine (boolean)
function MusicianList.Load(idOrIndex, action, fromCommandLine)

	local songData, id = MusicianList.GetSong(idOrIndex)

	-- Song has not been found by name
	if not(songData) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
		return
	end

	-- A song is already being imported
	if isSongLoading then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_CANNOT_LOAD_NOW)
		return
	end

	-- Initiate loading process
	if fromCommandLine then
		Musician.Utils.Print(string.gsub(MusicianList.Msg.LOADING_SONG, "{name}", Musician.Utils.Highlight(songData.name)))
	end

	local song = Musician.Song.create()
	isSongLoading = true
	song.savedId = id
	MusicianList:SendMessage(MusicianList.Events.SongLoadStart, song, songData)
	MusicianList.RefreshFrame()
	song:ImportCompressed(songData.data, false, function(success)

		isSongLoading = false

		-- Import failed
		if not(success) then
			MusicianList:SendMessage(MusicianList.Events.SongLoadComplete, song, false)
			return
		end

		-- Stop previous source song being played
		if Musician.sourceSong and Musician.sourceSong:IsPlaying() then
			Musician.sourceSong:Stop()
		end

		song.isInList = true
		Musician.sourceSong = song
		collectgarbage()

		if fromCommandLine then
			Musician.Utils.Print(MusicianList.Msg.DONE_LOADING)
		end

		if action == MusicianList.LoadActions.Play then
			Musician.Comm.PlaySong()
		elseif action == MusicianList.LoadActions.Preview then
			song:Play()
		end

		MusicianList:SendMessage(MusicianList.Events.SongLoadComplete, song, true)
		MusicianList:SendMessage(Musician.Events.SourceSongLoaded, song, songData.data)
		MusicianList.RefreshFrame()
	end)
end

--- Delete song, with confirmation
-- @param[opt] idOrIndex (string)
-- @param[opt=false] fromCommandLine (boolean)
function MusicianList.Delete(idOrIndex, fromCommandLine)
	-- Defaults to loaded song
	if idOrIndex == nil or idOrIndex == '' then
		idOrIndex = Musician.sourceSong and Musician.sourceSong.isInList and Musician.sourceSong.name or ""
	end

	local songData, id = MusicianList.GetSong(idOrIndex)

	if not(songData) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
		return
	end

	StaticPopup_Show("MUSICIAN_LIST_DELETE_CONFIRM", Musician.Utils.Highlight(songData.name), nil, { id = id, fromCommandLine = fromCommandLine })
end

--- Delete song, without confirmation
-- @param[opt] id (string)
-- @param[opt=false] fromCommandLine (boolean)
function MusicianList.DoDelete(id, fromCommandLine)
	local songData, _ = MusicianList.GetSong(id)
	if not(songData) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
		return
	end

	MusicianList_Storage.data[id] = nil

	if fromCommandLine then
		Musician.Utils.Print(string.gsub(MusicianList.Msg.SONG_DELETED, "{name}", Musician.Utils.Highlight(songData.name)))
	end

	if Musician.sourceSong and songData.name == Musician.sourceSong.name then
		Musician.sourceSong.isInList = nil
	end

	MusicianList:SendMessage(MusicianList.Events.ListUpdate)
end

--- Rename song, showing "rename" dialog if no name is provided
-- @param idOrIndex (string)
-- @param name (string)
-- @param[opt=false] fromCommandLine (boolean)
function MusicianList.Rename(idOrIndex, name, fromCommandLine)
	-- Defaults to loaded song
	if idOrIndex == nil or idOrIndex == '' then
		idOrIndex = Musician.sourceSong and Musician.sourceSong.isInList and Musician.sourceSong.name or ""
	end

	local songData, id = MusicianList.GetSong(idOrIndex)

	if not(songData) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
		return
	end

	if name == nil or name == '' then
		StaticPopup_Show("MUSICIAN_LIST_RENAME", Musician.Utils.Highlight(songData.name), nil, { id = id, oldName = songData.name, fromCommandLine = fromCommandLine })
	else
		MusicianList.RenameConfirm(id, name, fromCommandLine)
	end
end

--- Rename song, requesting to overwrite existing song
-- @param[opt] id (string)
-- @param[opt] name (string)
-- @param[opt=false] fromCommandLine (boolean)
function MusicianList.RenameConfirm(id, name, fromCommandLine)
	name = Musician.Utils.NormalizeSongName(name)

	-- Find out if another song already exists with the same name
	local song2, id2 = MusicianList.GetSong(MusicianList.GetSongId(name))

	if song2 and id ~= id2 then
		StaticPopup_Show("MUSICIAN_LIST_OVERWRITE_CONFIRM", Musician.Utils.Highlight(name), nil, function()
			MusicianList.DoRename(id, name, fromCommandLine)
		end)
	else
		MusicianList.DoRename(id, name, fromCommandLine)
	end
end

--- Rename song, without confirmation
-- @param[opt] id (string)
-- @param[opt] name (string)
-- @param[opt=false] fromCommandLine (boolean)
function MusicianList.DoRename(id, name, fromCommandLine)
	name = Musician.Utils.NormalizeSongName(name)

	local songData, _ = MusicianList.GetSong(id)
	if not(songData) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
		return
	end

	local newId = MusicianList.GetSongId(name)
	local oldName = songData.name

	MusicianList_Storage.data[id] = nil
	songData.name = name

	-- Update song title in compressed song data
	local cursor = #Musician.FILE_HEADER_COMPRESSED + 1
	local titleCompressedChunkLength = Musician.Utils.UnpackNumber(string.sub(songData.data, cursor, cursor + 1))
	cursor = cursor + titleCompressedChunkLength + 2
	local newTitleChunk = Musician.Utils.PackNumber(#name, 2) .. name
	local newTitleCompressedChunk = LibDeflate:CompressDeflate(newTitleChunk, { level = 9 })
	songData.data = Musician.FILE_HEADER_COMPRESSED .. Musician.Utils.PackNumber(#newTitleCompressedChunk, 2) .. newTitleCompressedChunk .. string.sub(songData.data, cursor)

	-- Update song data in storage
	MusicianList_Storage.data[newId] = songData

	if Musician.sourceSong and Musician.sourceSong.isInList and Musician.sourceSong.name == oldName then
		Musician.sourceSong.name = name
		MusicianFrame.Clear()
		MusicianList.RefreshFrame()
	end

	if fromCommandLine then
		local msg = MusicianList.Msg.SONG_RENAMED
		msg = string.gsub(msg, "{name}", Musician.Utils.Highlight(oldName))
		msg = string.gsub(msg, "{newName}", Musician.Utils.Highlight(name))
		Musician.Utils.Print(msg)
	end

	MusicianList:SendMessage(MusicianList.Events.ListUpdate)
end

--- Post song link in the chat
-- @param idOrIndex (string)
-- @param[opt=false] fromCommandLine (boolean)
function MusicianList.Link(idOrIndex, fromCommandLine)
	-- Defaults to loaded song
	if idOrIndex == nil or idOrIndex == '' then
		idOrIndex = Musician.sourceSong and Musician.sourceSong.isInList and Musician.sourceSong.name or ""
	end

	local songData, id = MusicianList.GetSong(idOrIndex)

	if not(songData) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
		return
	end

	Musician.SongLinks.AddSongData(songData.data, songData.name)
	ChatEdit_LinkItem(nil, Musician.SongLinks.GetHyperlink(songData.name))
end

--- Restore demo songs
-- @param overwrite (boolean)
function MusicianList.RestoreDemoSongs(overwrite)
	local id, song
	for id, song in pairs(MusicianList.DemoSongs) do
		if overwrite or MusicianList_Storage.data[id] == nil then
			MusicianList_Storage.data[id] = Musician.Utils.DeepCopy(song)
		end
	end
end

--- Get song ID by name
-- @param name (string)
-- @return songId (string) Song ID
function MusicianList.GetSongId(name)
	return strtrim(strlower(name))
end

--- Get saved song data by name or index
-- @param idOrIndex (string)
-- @return songData (table)
-- @return songId (table)
function MusicianList.GetSong(idOrIndex)
	local id = MusicianList.GetSongId(idOrIndex)

	-- Get by id
	if MusicianList_Storage.data[id] then
		return MusicianList_Storage.data[id], id
	else
		-- Try to get by index
		local list = MusicianList.GetSongList()
		local index = tonumber(strtrim(idOrIndex))
		if index ~= nil and list[index] then
			id = MusicianList.GetSongId(list[index].name)
			return MusicianList_Storage.data[id], id
		else -- Not found
			return nil, nil
		end
	end
end

--- Format time to mm:ss.ss format
-- @param time (number)
-- @return formattedTime (string)
function MusicianList.FormatTime(time, simple)
	time = floor(time + .5)
	local s = time % 60
	time = floor(time / 60)
	local m = time

	return m .. ":" .. Musician.Utils.PaddingZeros(s, 2)
end

--- Clean string for search, keeping only lowercase letters without accents and numbers.
-- @param str (string)
-- @return filteredStr (string)
function MusicianList.SearchString(str)
	str = strlower(str)
	str = MusicianList.StripAccents(str)
	str = string.gsub(str, "%p+", " ")
	return strtrim(string.gsub(str, "%s+", " "))
end

--- Remove all accents from provided string
-- @param str (string)
-- @return filteredStr (string)
function MusicianList.StripAccents(str)

	if(str == nil) then return "" end

	local accents = {
		{"À Á Â Ã Ä Å Ā Ă Ą", "A"},
		{"à á â ã ä å ā ă ą", "a"},
		{"Æ", "AE"},
		{"æ", "ae"},
		{"Ɓ", "B"},
		{"ẞ", "SS"},
		{"ß", "ss"},
		{"ƀ", "b"},
		{"Ç Ć Ĉ Ċ Č", "C"},
		{"ç ć ĉ ċ č", "c"},
		{"Ð Ď Đ", "D"},
		{"ď đ ð", "d"},
		{"È É Ê Ë Ē Ĕ Ė Ę Ě", "E"},
		{"è é ê ë ē ĕ ė ę ě", "e"},
		{"ſ", "f"},
		{"Ĝ Ğ Ġ Ģ", "G"},
		{"ĝ ğ ġ ģ", "g"},
		{"Ĥ Ħ", "H"},
		{"ĥ ħ", "h"},
		{"Ì Í Î Ï Ĩ Ī Ĭ Į İ", "I"},
		{"ì í î ï ĩ ī ĭ į ı", "i"},
		{"Ĳ", "IJ"},
		{"ĳ", "ij"},
		{"Ĵ", "J"},
		{"ĵ", "j"},
		{"Ķ", "K"},
		{"ķĸ", "k"},
		{"Ĺ Ļ Ľ Ŀ Ł", "L"},
		{"ĺ ļ ľ ŀ ł", "l"},
		{"Ñ Ń Ņ Ň Ŋ", "N"},
		{"ñ ń ņ ň ŉ ŋ", "n"},
		{"Ò Ó Ô Õ Ö Ø Ō Ŏ Ő", "O"},
		{"ò ó ô õ ö ø ō ŏ ő", "o"},
		{"þ Þ", "P"},
		{"Œ", "OE"},
		{"œ", "oe"},
		{"Ŕ Ŗ Ř", "R"},
		{"ŕ ŗ ř", "r"},
		{"Ś Ŝ Ş Š", "S"},
		{"ś ŝ ş š", "s"},
		{"Ţ Ť Ŧ", "T"},
		{"ţ ť ŧ", "t"},
		{"Ù Ú Û Ü Ũ Ū Ŭ Ů Ű Ų", "U"},
		{"ù ú û ü ũ ū ŭ ů ű ų", "u"},
		{"Ŵ", "W"},
		{"ŵ", "w"},
		{"Ý Ŷ Ÿ", "Y"},
		{"ý ŷ ÿ", "y"},
		{"Ź Ż Ž", "Z"},
		{"ź ż ž", "z"}
	}

	local accentRow, a

	for _, accentRow in pairs(accents) do
		accentRow[1] = {strsplit(' ', accentRow[1])}
		for _, a in pairs(accentRow[1]) do
			str = string.gsub(str, a, accentRow[2])
		end
	end

	return str
end
