MusicianList = LibStub("AceAddon-3.0"):NewAddon("MusicianList", "AceEvent-3.0")

local LibDeflate

local PROCESS_SAVE = "save"
local PROCESS_LOAD = "load"

local currentImportStep
local currentImportData
local importedSongData

local currentProcess

local MusicianGetCommands
local MusicianButtonGetMenu

--- OnInitialize
--
function MusicianList:OnInitialize()

	-- Init storage
	if MusicianList_Storage == nil then
		MusicianList_Storage = {
			['version'] = MusicianList.STORAGE_VERSION,
			['data'] = {}
		}
	end

	-- Check for outdated Musician version
	if Musician.Utils.VersionCompare(MusicianList.MUSICIAN_MIN_VERSION, GetAddOnMetadata("Musician", "Version")) > 0 then
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

	-- Import libraries
	LibDeflate = LibStub:GetLibrary("LibDeflate")

	-- Create frame
	-- @var processFrame (Frame)
	MusicianList.processFrame = CreateFrame("Frame")
	MusicianList.processFrame:SetFrameStrata("HIGH")
	MusicianList.processFrame:EnableMouse(false)
	MusicianList.processFrame:SetMovable(false)
	MusicianList.processFrame:SetScript("OnUpdate", MusicianList.OnUpdate)

	-- Register events
	MusicianList:RegisterMessage(Musician.Events.SongImportStart, MusicianList.OnSongImportStart)
	MusicianList:RegisterMessage(Musician.Events.SongImportProgress, MusicianList.OnSongImportProgress)
	MusicianList:RegisterMessage(Musician.Events.SongImportFailed, MusicianList.OnSongImportFailed)
	MusicianList:RegisterMessage(Musician.Events.SourceSongLoaded, MusicianList.OnSourceSongLoaded)
	MusicianList:RegisterMessage(Musician.Events.SongImportStart, MusicianList.OnSongImportStart)

	-- Show progress bar while loading
	MusicianList:RegisterMessage(MusicianList.Events.SongLoadProgress, function(event, process, progression)
		MusicianFrame.RefreshLoadingProgressBar(event, process.song, progression * .75)
	end)

	-- Show progress bar while saving
	MusicianList:RegisterMessage(MusicianList.Events.SongSaveProgress, function(event, process, progression)
		MusicianFrame.RefreshLoadingProgressBar(event, { ['importing'] = true }, progression)
	end)
	MusicianList:RegisterMessage(MusicianList.Events.SongSaveComplete, function(event)
		MusicianFrame.RefreshLoadingProgressBar(event, { ['importing'] = false }, 1)
	end)

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
		OnAccept = function(self, id)
			MusicianList.DoDelete(id)
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
		editBoxWidth = 350,
		OnAccept = function(self)
			local name = strtrim(self.editBox:GetText())
			MusicianList.SaveConfirm(name)
		end,
		EditBoxOnEnterPressed = function(self)
			local parent = self:GetParent()
			local name = strtrim(parent.editBox:GetText())
			MusicianList.SaveConfirm(name)
			parent:Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		OnShow = function(self, name)
			self.editBox:SetText(name)
			self.editBox:HighlightText(0)
			self.editBox:SetFocus()
		end,
		OnHide = function(self)
			ChatEdit_FocusActiveWindow()
			self.editBox:SetText("")
		end,
		timeout = 0,
		exclusive = 1,
		hideOnEscape = 1
	}

	-- Rename song
	StaticPopupDialogs["MUSICIAN_LIST_RENAME"] = {
		preferredIndex = STATICPOPUPS_NUMDIALOGS,
		text = MusicianList.Msg.RENAME_SONG,
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = 1,
		editBoxWidth = 350,
		OnAccept = function(self, songData)
			local name = strtrim(self.editBox:GetText())
			MusicianList.RenameConfirm(songData.id, name)
		end,
		EditBoxOnEnterPressed = function(self, songData)
			local parent = self:GetParent()
			local name = strtrim(parent.editBox:GetText())
			MusicianList.RenameConfirm(songData.id, name)
			parent:Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		OnShow = function(self, songData)
			self.editBox:SetText(songData.oldName)
			self.editBox:HighlightText(0)
			self.editBox:SetFocus()
		end,
		OnHide = function(self)
			ChatEdit_FocusActiveWindow()
			self.editBox:SetText("")
		end,
		timeout = 0,
		exclusive = 1,
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

	-- Hyperlinks
	--

	hooksecurefunc("ChatFrame_OnHyperlinkShow", function(self, link, text, button)
		local args = { strsplit(':', link) }
		local prefix = table.remove(args, 1)
		if prefix == "musicianlist" then
			local command = table.remove(args, 1)
			local value = table.concat(args, ':')

			-- Load song
			if command == "load" then -- Load song
				MusicianList.Load(value)
			elseif command == "play" then -- Play song
				MusicianList.Load(value, true)
			elseif command == "delete" then -- Delete song
				MusicianList.Delete(value)
			end
		end
	end)

	-- Init UI
	MusicianList.Frame.Init()
end

--- Get command definitions
-- @return (table)
function MusicianList.GetCommands()
	local commands = MusicianGetCommands()

	-- Replace existing "Play" command

	local playCommand = table.remove(commands, 2)
	table.insert(commands, 2, {
		command = { "play" },
		text = MusicianList.Msg.COMMAND_PLAY,
		params = MusicianList.Msg.COMMAND_PLAY_PARAMS,
		func = function(value)
			if value ~= "" then
				MusicianList.Load(value, true)
			else
				playCommand.func()
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
			MusicianList.Load(value, false)
		end
	})

	-- Save song

	table.insert(commands, #commands - 2, {
		command = { "save" },
		text = MusicianList.Msg.COMMAND_SAVE,
		params = MusicianList.Msg.COMMAND_SAVE_PARAMS,
		func = MusicianList.Save
	})

	-- Delete song

	table.insert(commands, #commands - 2, {
		command = { "delete", "del", "remove", "rm" },
		text = MusicianList.Msg.COMMAND_DELETE,
		params = MusicianList.Msg.COMMAND_DELETE_PARAMS,
		func = MusicianList.Delete
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
			MusicianList.Rename(index, name)
		end
	})

	return commands
end

--- Return main menu elements
-- @return (table)
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

	-- Save song
	if Musician.sourceSong then
		table.insert(menu, 7, {
			notCheckable = true,
			text = MusicianList.Msg.MENU_SAVE,
			func = function()
				MusicianList.Save()
			end
		})
	end

	return menu
end

--- Get sorted song list
-- @return (table)
function MusicianList.GetSongList()
	local list = {}
	local songData, id
	for id, songData in pairs(MusicianList_Storage.data) do
		table.insert(list, {
			id = id,
			name = songData.name,
			searchName = MusicianList.SearchString(songData.name),
			duration = songData.cropTo - songData.cropFrom
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

--- Process save step on frame
--
local function processSaveStep()
	local to = min(#currentProcess.rawData, currentProcess.cursor + MusicianList.CHUNK_SIZE - 1)
	local from = currentProcess.cursor
	local chunk = string.sub(currentProcess.rawData, from, to)
	local compressedChunk = LibDeflate:CompressDeflate(chunk, { ['level'] = 9 })

	table.insert(currentProcess.savedData.chunks, compressedChunk)

	Musician.Comm:SendMessage(MusicianList.Events.SongSaveProgress, currentProcess, to / #currentProcess.rawData)

	-- Process complete
	if to == #currentProcess.rawData then
		currentProcess.cursor = to
		currentProcess.savedData.name = currentProcess.name
		MusicianList_Storage.data[currentProcess.id] = Musician.Utils.DeepCopy(currentProcess.savedData)
		Musician.Comm:SendMessage(MusicianList.Events.SongSaveComplete, currentProcess)
		Musician.Comm:SendMessage(MusicianList.Events.ListUpdate)
		currentProcess = nil

		Musician.Utils.Print(MusicianList.Msg.DONE_SAVING)
	else
		currentProcess.cursor = to + 1
	end
end

--- Save song, showing "save as" dialog if no name is provided
-- @param [name] (string)
function MusicianList.Save(name)
	-- Defaults to loaded song
	if name == nil or name == '' then
		StaticPopup_Show("MUSICIAN_LIST_SAVE", nil, nil, strtrim(Musician.sourceSong.name))
	else
		MusicianList.SaveConfirm(strtrim(name))
	end
end

--- Save song, requesting to overwrite existing song
-- @param [name] (string)
function MusicianList.SaveConfirm(name)
	local song, id = MusicianList.GetSong(MusicianList.GetSongId(name))

	if song then
		StaticPopup_Show("MUSICIAN_LIST_OVERWRITE_CONFIRM", Musician.Utils.Highlight(name), nil, function()
			MusicianList.DoSave(name)
		end)
	else
		MusicianList.DoSave(name)
	end
end

--- Save song, without confirmation
-- @param name (string)
function MusicianList.DoSave(name)

	if currentProcess or Musician.importingSong then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_CANNOT_SAVE_NOW)
		return
	end

	if not(importedSongData) or not(Musician.sourceSong) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_NO_SONG_TO_SAVE)
		return
	end

	if not(name) or name == "" then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NAME_EMPTY)
		return
	end

	Musician.Utils.Print(string.gsub(MusicianList.Msg.SAVING_SONG, "{name}", Musician.Utils.Highlight(name)))

	Musician.sourceSong.name = name

	currentProcess = {
		['process'] = PROCESS_SAVE,
		['cursor'] = 1,
		['rawData'] = importedSongData,
		['id'] = MusicianList.GetSongId(name),
		['name'] = name,
		['savedData'] = {
			['chunks'] = {},
			['tracks'] = {},
			['cropFrom'] = nil,
			['cropTo'] = nil,
		}
	}

	-- Save track settings
	local track
	for _, track in pairs(Musician.sourceSong.tracks) do
		table.insert(currentProcess.savedData.tracks, {
			['instrument'] = track.instrument,
			['transpose'] = track.transpose,
			['muted'] = track.muted,
			['solo'] = track.solo,
		})
	end

	-- Save song settings
	currentProcess.savedData.cropFrom = Musician.sourceSong.cropFrom
	currentProcess.savedData.cropTo = Musician.sourceSong.cropTo

	Musician.Comm:SendMessage(MusicianList.Events.SongSaveStart, currentProcess)
	Musician.Comm:SendMessage(MusicianList.Events.SongSaveProgress, currentProcess, 0)

	Musician.sourceSong.isInList = true
end

--- Process load step on frame
--
local function processLoadStep()
	-- Uncompressing complete, waiting for standard Musician import to complete
	if currentProcess.cursor == nil then
		return
	end

	local compressedChunk = currentProcess.savedData.chunks[currentProcess.cursor]
	local chunk = LibDeflate:DecompressDeflate(compressedChunk)

	-- Check and replace header in first chunk
	if currentProcess.rawData == "" then
		chunk = Musician.FILE_HEADER .. string.sub(chunk, 5)
	end

	currentProcess.rawData = currentProcess.rawData .. chunk

	Musician.Comm:SendMessage(MusicianList.Events.SongLoadProgress, currentProcess, currentProcess.cursor / #currentProcess.savedData.chunks)

	-- Process complete
	if currentProcess.cursor == #currentProcess.savedData.chunks then
		currentProcess.cursor = nil

		currentProcess.song.importing = true
		currentProcess.song.import = {}
		local import = currentProcess.song.import
		import.step = 2
		import.data = currentProcess.rawData
		import.cursor = 1
		import.progression = 0
		import.crop = false

		Musician.importingSong = currentProcess.song
		importedSongData = import.data
	else
		currentProcess.cursor = currentProcess.cursor + 1
	end
end

--- Load song
-- @param idOrIndex (string)
-- @param play (boolean) Play song after loading
function MusicianList.Load(idOrIndex, play)

	if currentProcess or Musician.importingSong then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_CANNOT_LOAD_NOW)
		return
	end
	local songData, id = MusicianList.GetSong(idOrIndex)

	-- Song has not been found by name
	if not(songData) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
		return
	end

	currentProcess = {
		['process'] = PROCESS_LOAD,
		['cursor'] = 1,
		['play'] = play,
		['rawData'] = '',
		['id'] = id,
		['song'] = Musician.Song.create(),
		['savedData'] = songData
	}

	Musician.Utils.Print(string.gsub(MusicianList.Msg.LOADING_SONG, "{name}", Musician.Utils.Highlight(currentProcess.savedData.name)))

	currentProcess.song.importing = true
	Musician.Comm:SendMessage(MusicianList.Events.SongLoadStart, currentProcess)
	Musician.Comm:SendMessage(MusicianList.Events.SongLoadProgress, currentProcess, 0)
end

--- Delete song, with confirmation
-- @param [idOrIndex] (string)
function MusicianList.Delete(idOrIndex)
	-- Defaults to loaded song
	if idOrIndex == nil or idOrIndex == '' then
		idOrIndex = Musician.sourceSong and Musician.sourceSong.isInList and Musician.sourceSong.name or ""
	end

	local songData, id = MusicianList.GetSong(idOrIndex)

	if not(songData) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
		return
	end

	StaticPopup_Show("MUSICIAN_LIST_DELETE_CONFIRM", Musician.Utils.Highlight(songData.name), nil, id)
end

--- Delete song, without confirmation
-- @param [id] (string)
function MusicianList.DoDelete(id)
	local songData, _ = MusicianList.GetSong(id)
	if not(songData) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
		return
	end

	MusicianList_Storage.data[id] = nil
	Musician.Utils.Print(string.gsub(MusicianList.Msg.SONG_DELETED, "{name}", Musician.Utils.Highlight(songData.name)))

	if Musician.sourceSong and songData.name == Musician.sourceSong.name then
		Musician.sourceSong.isInList = nil
	end

	Musician.Comm:SendMessage(MusicianList.Events.ListUpdate)
end

--- Rename song, showing "rename" dialog if no name is provided
-- @param idOrIndex (string)
-- @param name (string)
function MusicianList.Rename(idOrIndex, name)
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
		StaticPopup_Show("MUSICIAN_LIST_RENAME", Musician.Utils.Highlight(songData.name), nil, { id = id, oldName = songData.name })
	else
		MusicianList.RenameConfirm(id, name)
	end
end

--- Rename song, requesting to overwrite existing song
-- @param [id] (string)
-- @param [name] (string)
function MusicianList.RenameConfirm(id, name)
	-- Find out if another song already exists with the same name
	local song2, id2 = MusicianList.GetSong(MusicianList.GetSongId(name))

	if song2 and id ~= id2 then
		StaticPopup_Show("MUSICIAN_LIST_OVERWRITE_CONFIRM", Musician.Utils.Highlight(name), nil, function()
			MusicianList.DoRename(id, name)
		end)
	else
		MusicianList.DoRename(id, name)
	end
end

--- Rename song, without confirmation
-- @param [id] (string)
-- @param [name] (string)
function MusicianList.DoRename(id, name)
	local songData, _ = MusicianList.GetSong(id)
	if not(songData) then
		Musician.Utils.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
		return
	end

	local newId = MusicianList.GetSongId(name)
	local oldName = songData.name

	MusicianList_Storage.data[id] = nil
	songData.name = name
	MusicianList_Storage.data[newId] = songData

	if Musician.sourceSong and Musician.sourceSong.isInList and Musician.sourceSong.name == oldName then
		Musician.sourceSong.name = name
		MusicianFrame.Clear(true)
		Musician.Comm:SendMessage(Musician.Events.RefreshFrame)
	end

	local msg = MusicianList.Msg.SONG_RENAMED
	msg = string.gsub(msg, "{name}", Musician.Utils.Highlight(oldName))
	msg = string.gsub(msg, "{newName}", Musician.Utils.Highlight(name))
	Musician.Utils.Print(msg)

	Musician.Comm:SendMessage(MusicianList.Events.ListUpdate)
end

--- OnSongImportStart
-- @param event (string)
-- @param song (Musician.Song)
function MusicianList.OnSongImportStart(event, song)
	if song ~= Musician.importingSong then
		return
	end
	currentImportStep = song.import.step
end

--- OnSongImportProgress
-- @param event (string)
-- @param song (Musician.Song)
-- @param progression (number)
function MusicianList.OnSongImportProgress(event, song, progression)
	if song ~= Musician.importingSong then
		return
	end

	if currentImportStep ~= song.import.step then
		currentImportStep = song.import.step

		-- Import step 2: song is base64-decoded
		if song.import.step == 2 then
			currentImportData = song.import.data
		end
	end
end

--- OnSongImportFailed
-- @param event (string)
-- @param song (Musician.Song)
function MusicianList.OnSongImportFailed(event, song)
	-- Abort loading process if it failed for some reason
	if currentProcess and currentProcess.process == PROCESS_LOAD and song == currentProcess.song then
		currentProcess = nil
	end
end

--- OnSourceSongLoaded
-- @param event (string)
function MusicianList.OnSourceSongLoaded(event)
	-- Loaded song has been imported
	if currentProcess and currentProcess.process == PROCESS_LOAD and Musician.sourceSong == currentProcess.song then
		-- Update track settings
		local trackIndex, track, trackSetting
		for trackIndex, track in pairs(Musician.sourceSong.tracks) do
			trackSetting = currentProcess.savedData.tracks[trackIndex]
			track.instrument = trackSetting.instrument
			track.transpose = trackSetting.transpose
			Musician.sourceSong:SetTrackSolo(track, trackSetting.solo)
			Musician.sourceSong:SetTrackMuted(track, trackSetting.muted)
		end

		-- Update song settings
		Musician.sourceSong.name = currentProcess.savedData.name
		Musician.sourceSong.cropFrom = currentProcess.savedData.cropFrom
		Musician.sourceSong.cropTo = currentProcess.savedData.cropTo
		Musician.sourceSong:Reset()

		local doPlay = currentProcess.play

		currentProcess = nil
		Musician.Comm:SendMessage(Musician.Events.RefreshFrame)
		MusicianFrame.Clear(true)
		Musician.TrackEditor.OnLoad()

		Musician.sourceSong.isInList = true

		Musician.Utils.Print(MusicianList.Msg.DONE_LOADING)

		if doPlay then
			Musician.Comm.PlaySong()
		end
	end

	importedSongData = currentImportData
	currentImportData = nil
	currentImportStep = nil
end


--- Perform all on-frame actions
-- @param frame (Frame)
-- @param elapsed (number)
function MusicianList.OnUpdate(frame, elapsed)
	if currentProcess == nil then
		return
	end

	if currentProcess.process == PROCESS_SAVE then
		processSaveStep()
	elseif currentProcess.process == PROCESS_LOAD then
		processLoadStep()
	end
end

--- Get song ID by name
-- @param name (string)
-- @return (string) Song ID
function MusicianList.GetSongId(name)
	return strtrim(strlower(name))
end

--- Get saved song data by name or index
-- @param idOrIndex (string)
-- @return (table), (string) Song data, song ID
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
-- @return (string)
function MusicianList.FormatTime(time, simple)
	time = floor(time + .5)
	local s = time % 60
	time = floor(time / 60)
	local m = time

	return m .. ":" .. Musician.Utils.PaddingZeros(s, 2)
end

--- Clean string for search, keeping only lowercase letters without accents and numbers.
-- @param str (string)
-- @return string without accents (string)
function MusicianList.SearchString(str)
	str = strlower(str)
	str = MusicianList.StripAccents(str)
	str = string.gsub(str, "%p+", " ")
	return strtrim(string.gsub(str, "%s+", " "))
end

--- Remove all accents from provided string
-- @param str (string)
-- @return string without accents (string)
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
