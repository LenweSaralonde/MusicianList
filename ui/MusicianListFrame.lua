MusicianList.Frame = LibStub("AceAddon-3.0"):NewAddon("MusicianList.Frame", "AceEvent-3.0")

local totalSongs = 0

local isDragging = false

local MAGNETIC_EDGES_RANGE = 20

--- Handle magnetic edges
--
local function magneticEdges()

	local frame = MusicianListFrame
	local anchor = MusicianFrame

	local isTopSticky = abs(anchor:GetBottom() - frame:GetTop()) <= MAGNETIC_EDGES_RANGE
	local isBottomSticky = abs(anchor:GetTop() - frame:GetBottom()) <= MAGNETIC_EDGES_RANGE
	local isLeftSticky = abs(anchor:GetRight() - frame:GetLeft()) <= MAGNETIC_EDGES_RANGE
	local isRightSticky = abs(anchor:GetLeft() - frame:GetRight()) <= MAGNETIC_EDGES_RANGE

	local isLeftAligned = abs(anchor:GetLeft() - frame:GetLeft()) <= MAGNETIC_EDGES_RANGE
	local isRightAligned = abs(anchor:GetRight() - frame:GetRight()) <= MAGNETIC_EDGES_RANGE
	local isTopAligned = abs(anchor:GetTop() - frame:GetTop()) <= MAGNETIC_EDGES_RANGE
	local isBottomAligned = abs(anchor:GetBottom() - frame:GetBottom()) <= MAGNETIC_EDGES_RANGE

	frame:ClearAllPoints()

	-- Anchored by top border
	if isTopSticky then
		if isLeftAligned then
			frame:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, 0)
		end
		if isRightAligned then
			frame:SetPoint('TOPRIGHT', anchor, 'BOTTOMRIGHT', 0, 0)
		end
	end

	-- Anchored by bottom border
	if isBottomSticky then
		if isLeftAligned then
			frame:SetPoint('BOTTOMLEFT', anchor, 'TOPLEFT', 0, 0)
		end
		if isRightAligned then
			frame:SetPoint('BOTTOMRIGHT', anchor, 'TOPRIGHT', 0, 0)
		end
	end

	-- Anchored by left border
	if isLeftSticky then
		if isTopAligned then
			frame:SetPoint('TOPLEFT', anchor, 'TOPRIGHT', 0, 0)
		end
		if isBottomAligned then
			frame:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMRIGHT', 0, 0)
		end
	end

	-- Anchored by right border
	if isRightSticky then
		if isTopAligned then
			frame:SetPoint('TOPRIGHT', anchor, 'TOPLEFT', 0, 0)
		end
		if isBottomAligned then
			frame:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMLEFT', 0, 0)
		end
	end
end

--- Handle magnetic edges on drag start
--
function onMagneticDragStart()
	isDragging = true
end

--- Handle magnetic edges on drag stop
--
function onMagneticDragStop()
	isDragging = false
	if MusicianFrame:IsVisible() and MusicianListFrame:IsVisible() then
		magneticEdges()
	end
end

--- Init
--
MusicianList.Frame.Init = function()
	-- Data refresh events
	MusicianList.Frame:RegisterMessage(MusicianList.Events.ListUpdate, MusicianList.Frame.SetData)

	-- Source import events
	MusicianList.Frame:RegisterMessage(Musician.Events.SongImportStart, MusicianList.Frame.DisableButtons)
	MusicianList.Frame:RegisterMessage(Musician.Events.SongImportComplete, MusicianList.Frame.EnableButtons)
	MusicianList.Frame:RegisterMessage(Musician.Events.SourceSongLoaded, function()
		MusicianList.Frame.Filter()
	end)

	-- Load song events
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadStart, function()
		MusicianList.Frame.ResetProgressBars()
		MusicianList.Frame.DisableButtons()
	end)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadComplete, function()
		MusicianList.Frame.ResetProgressBars()
		MusicianList.Frame.EnableButtons()
	end)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadProgress, MusicianList.Frame.OnLoadProgress)

	-- Save song events
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongSaveStart, function()
		MusicianList.Frame.DisableButtons()
		MusicianList.RefreshFrame()
	end)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongSaveComplete, function()
		MusicianFrame.SetLoadingProgressBar(nil)
		MusicianFrame.Clear()
		MusicianList.Frame.EnableButtons()
		MusicianList.RefreshFrame()
	end)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongSaveProgress, MusicianList.Frame.OnSaveProgress)

	MusicianList.Frame.SetData()

	-- Handle magnetic edges
	MusicianListFrame:HookScript('OnDragStart', onMagneticDragStart)
	MusicianListFrame:HookScript('OnDragStop', onMagneticDragStop)
	MusicianFrame:HookScript('OnDragStart', onMagneticDragStart)
	MusicianFrame:HookScript('OnDragStop', onMagneticDragStop)
	MusicianListFrameResizeButton:HookScript('OnMouseDown', onMagneticDragStart)
	MusicianListFrameResizeButton:HookScript('OnMouseUp', onMagneticDragStop)
	MusicianFrame:HookScript('OnShow', magneticEdges)
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
	local visibleIndex = 1
	local height = 0
	for index = 1, MusicianListFrameSongContainer:GetNumChildren() do
		local rowFrame = _G["MusicianListSong" .. index]
		if rowFrame.song ~= nil and (filter == "" or string.match(rowFrame.song.searchName, filter)) then
			rowFrame:Show()
			rowFrame:SetPoint("TOPLEFT", 0, -height)
			rowFrame.visibleIndex = visibleIndex
			height = height + rowFrame:GetHeight()
			MusicianList.Frame.HighlightSongRow(rowFrame, rowFrame:IsMouseOver())
			visibleIndex = visibleIndex + 1
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

--- OnLoadProgress
-- @param filter (string)
-- @param song (MusicianSong)
-- @param progression (number)
MusicianList.Frame.OnLoadProgress = function(event, song, progression)
	local rowFrame
	for _, rowFrame in pairs({ MusicianListFrameSongContainer:GetChildren() }) do
		if song.savedId == rowFrame.song.id then
			rowFrame.progressBar:Show()
			rowFrame.progressBar:SetWidth(rowFrame.background:GetWidth() * progression)
			return
		end
	end
end

--- OnSaveProgress
-- @param filter (string)
-- @param song (MusicianSong)
-- @param progression (number)
MusicianList.Frame.OnSaveProgress = function(event, song, progression)
	MusicianFrame.SetLoadingProgressBar(progression)
end
--- Disable all buttons while a process is running
--
MusicianList.Frame.DisableButtons = function()
	local rowFrame
	for _, rowFrame in pairs({ MusicianListFrameSongContainer:GetChildren() }) do
		rowFrame.title:Disable()
		rowFrame.title.playButton:Disable()
		rowFrame.title.previewButton:Disable()
		rowFrame.title.linkButton:Disable()
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
		rowFrame.title.linkButton:Enable()
		rowFrame.title.renameButton:Enable()
		rowFrame.title.deleteButton:Enable()
	end
	MusicianList.Frame.Filter()
end

--- Highlight song row on frame update
-- @param rowFrame (Frame)
-- @param elapsed (number)
MusicianList.Frame.SongRowOnUpdate = function(rowFrame, elapsed)
	local isMouseOver = rowFrame:IsMouseOver()
	if rowFrame.isHighlighted ~= isMouseOver then
		rowFrame.isHighlighted = isMouseOver
		MusicianList.Frame.HighlightSongRow(rowFrame, isMouseOver)
	end
end

--- Highlight song row
-- @param rowFrame (Frame)
-- @param isHighlighted (boolean)
MusicianList.Frame.HighlightSongRow = function(rowFrame, isHighlighted)
	if isHighlighted then
		rowFrame.title.deleteButton:Show()
		rowFrame.title.renameButton:Show()
		rowFrame.title.linkButton:Show()
		rowFrame.title.previewButton:Show()
		rowFrame.title.playButton:Show()
		rowFrame.duration:Hide()
		rowFrame.background:SetColorTexture(.6, 0, 0, 1)
	else
		rowFrame.title.deleteButton:Hide()
		rowFrame.title.renameButton:Hide()
		rowFrame.title.linkButton:Hide()
		rowFrame.title.previewButton:Hide()
		rowFrame.title.playButton:Hide()
		rowFrame.duration:Show()

		-- Change background color if the song is the currently loaded one
		if Musician.sourceSong and Musician.sourceSong.isInList and Musician.sourceSong.name == rowFrame.song.name then
			rowFrame.background:SetColorTexture(.5, .5, .5, .5)
		else
			-- Odd and even colors
			if rowFrame.visibleIndex % 2 == 0 then
				rowFrame.background:SetColorTexture(0, 0, 0, .5)
			else
				rowFrame.background:SetColorTexture(.1, .1, .1, .5)
			end
		end
	end
end
