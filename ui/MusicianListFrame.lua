MusicianList.Frame = LibStub("AceAddon-3.0"):NewAddon("MusicianList.Frame", "AceEvent-3.0")

local totalSongs = 0

--- Init
--
MusicianList.Frame.Init = function()
	MusicianList.Frame:RegisterMessage(MusicianList.Events.ListUpdate, MusicianList.Frame.SetData)

	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadProgress, MusicianList.Frame.OnProgress)

	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadStart, function()
		MusicianList.Frame.ResetProgressBars()
		MusicianList.Frame.DisableButtons()
	end)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadComplete, function()
		MusicianList.Frame.ResetProgressBars()
		MusicianList.Frame.EnableButtons()
	end)

	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongSaveStart, MusicianList.Frame.DisableButtons)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongSaveComplete, MusicianList.Frame.EnableButtons)

	MusicianList.Frame.SetData()
end

--- SetData
--
MusicianList.Frame.SetData = function()

	local list = MusicianList.GetSongList()
	local song, index
	for index, song in pairs(list) do
		local rowFrameName = "MusicianListSong" .. index

		local rowFrame
		if _G[rowFrameName] ~= nil then
			rowFrame = _G[rowFrameName]
		else
			rowFrame = CreateFrame("Frame", rowFrameName, MusicianListFrameSongContainer, "MusicianListSongTemplate")
		end

		rowFrame.song = song
		rowFrame.index:SetText(song.index)
		rowFrame.title:SetText(song.name)
		rowFrame.duration:SetText(MusicianList.FormatTime(song.duration, true))
	end

	totalSongs = #list

	-- Disable unused frames
	for index = #list + 1, MusicianListFrameSongContainer:GetNumChildren() do
		_G["MusicianListSong" .. index].song = nil
	end

	MusicianList.Frame.Filter()
end

--- Filter
-- @param filter (string)
MusicianList.Frame.Filter = function(filter)
	if filter ~= nil then
		MusicianListFrameSearchBox:SetText(strtrim(filter))
	else
		filter = MusicianListFrameSearchBox:GetText()
	end

	filter = MusicianList.SearchString(filter)

	local index = 1
	local height = 0
	for index = 1, MusicianListFrameSongContainer:GetNumChildren() do
		local rowFrame = _G["MusicianListSong" .. index]
		if rowFrame.song ~= nil and (filter == "" or string.match(rowFrame.song.searchName, filter)) then
			rowFrame:Show()
			rowFrame:SetPoint("TOPLEFT", 0, -height)
			height = height + rowFrame:GetHeight()
		else
			rowFrame:Hide()
		end
	end

	MusicianListFrameSongContainer:SetHeight(height)

	if height == 0 then
		MusicianListFrameListEmpty:Show()
		if filter ~= "" and totalSongs > 0 then
			MusicianListFrameListEmptyText:SetText(MusicianList.Msg.NO_SONG_FOUND)
			MusicianListFrameListEmptyImportButton:Hide()
		else
			MusicianListFrameListEmptyText:SetText(MusicianList.Msg.SONG_LIST_EMPTY)
			MusicianListFrameListEmptyImportButton:Show()
		end
	else
		MusicianListFrameListEmpty:Hide()
	end
end

--- ResetProgressBars
--
MusicianList.Frame.ResetProgressBars = function(event, process, success)
	local rowFrame
	for _, rowFrame in pairs({ MusicianListFrameSongContainer:GetChildren() }) do
		rowFrame.progressBar:Hide()
		rowFrame.progressBar:SetWidth(0)
	end
end

--- OnProgress
-- @param filter (string)
-- @param process (table)
-- @param progression (number)
MusicianList.Frame.OnProgress = function(event, process, progression)
	local rowFrame
	for _, rowFrame in pairs({ MusicianListFrameSongContainer:GetChildren() }) do
		if process.id == rowFrame.song.id then
			rowFrame.progressBar:Show()
			rowFrame.progressBar:SetWidth(rowFrame.background:GetWidth() * progression)
			return
		end
	end
end

--- Disable all buttons while a process is running
--
MusicianList.Frame.DisableButtons = function()
	local rowFrame
	for _, rowFrame in pairs({ MusicianListFrameSongContainer:GetChildren() }) do
		rowFrame.title:Disable()
		rowFrame.title.playButton:Disable()
		rowFrame.title.previewButton:Disable()
		rowFrame.title.renameButton:Disable()
		rowFrame.title.deleteButton:Disable()
	end
end

--- Enable all buttons when a process finishes
--
MusicianList.Frame.EnableButtons = function()
	local rowFrame
	for _, rowFrame in pairs({ MusicianListFrameSongContainer:GetChildren() }) do
		rowFrame.title:Enable()
		rowFrame.title.playButton:Enable()
		rowFrame.title.previewButton:Enable()
		rowFrame.title.renameButton:Enable()
		rowFrame.title.deleteButton:Enable()
	end
end
