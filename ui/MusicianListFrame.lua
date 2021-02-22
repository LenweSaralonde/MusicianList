MusicianList.Frame = LibStub("AceAddon-3.0"):NewAddon("MusicianList.Frame", "AceEvent-3.0")

local totalSongs = 0

local isDragging = false
local highlightedRowFrame

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
local function onMagneticDragStart()
	isDragging = true
end

--- Handle magnetic edges on drag stop
--
local function onMagneticDragStop()
	isDragging = false
	if MusicianFrame:IsVisible() and MusicianListFrame:IsVisible() then
		magneticEdges()
	end
end

--- Get song row frame by index
-- @param index (int)
-- @return rowFrame (Frame)
local function getRowFrame(index)
	return _G['MusicianListSong'.. index]
end

--- Init
--
function MusicianList.Frame.Init()
	-- Data refresh events
	MusicianList.Frame:RegisterMessage(MusicianList.Events.ListUpdate, MusicianList.Frame.SetData)

	-- Source import events
	MusicianList.Frame:RegisterMessage(Musician.Events.SongImportStart, function()
		MusicianList.Frame.DisableButtons()
	end)
	MusicianList.Frame:RegisterMessage(Musician.Events.SongImportComplete, function()
		MusicianList.Frame.EnableButtons()
	end)
	MusicianList.Frame:RegisterMessage(Musician.Events.SourceSongLoaded, function()
		MusicianList.RefreshFrame()
		MusicianList.Frame.Filter()
	end)

	-- Load song events
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadStart, function(event, song)
		local rowFrame = getRowFrame(song.index)
		rowFrame.progressBar:SetWidth(0)
		rowFrame.progressBar:Show()
		MusicianList.Frame.DisableButtons()
	end)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadComplete, function(event, song, success)
		local rowFrame = getRowFrame(song.index)
		rowFrame.progressBar:Hide()
		MusicianList.Frame.EnableButtons()
	end)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadProgress, function(event, song, progression)
		local rowFrame = getRowFrame(song.index)
		rowFrame.progressBar:SetWidth(rowFrame.background:GetWidth() * progression)
	end)

	-- Save song events
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongSaveStart, function()
		MusicianList.Frame.DisableButtons()
		MusicianList.RefreshFrame()
	end)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongSaveComplete, function(event, song, songId)
		MusicianFrame.SetLoadingProgressBar(nil)
		MusicianFrame.Clear()
		MusicianList.Frame.EnableButtons()
	end)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongSaveProgress, function(event, song, songId, progression)
		MusicianFrame.SetLoadingProgressBar(progression)
	end)

	MusicianList.Frame.SetData()

	-- Handle magnetic edges
	MusicianListFrame:HookScript('OnDragStart', onMagneticDragStart)
	MusicianListFrame:HookScript('OnDragStop', onMagneticDragStop)
	MusicianFrame:HookScript('OnDragStart', onMagneticDragStart)
	MusicianFrame:HookScript('OnDragStop', onMagneticDragStop)
	MusicianListFrameResizeButton:HookScript('OnMouseDown', onMagneticDragStart)
	MusicianListFrameResizeButton:HookScript('OnMouseUp', onMagneticDragStop)
	MusicianFrame:HookScript('OnShow', magneticEdges)

	-- Show main frame when list shows up if it was previously anchored
	MusicianListFrame:HookScript('OnShow', function(self)
		if self:GetNumPoints() > 0 then
			MusicianFrame:Show()
		end
	end)

	-- Hide list when the main window is hidden if anchored to it
	--
	MusicianFrame:HookScript('OnHide', function()
		MusicianFrame.musicianListWasVisible = MusicianListFrame:IsVisible()
		if MusicianListFrame:GetNumPoints() > 0 then
			MusicianListFrame:Hide()
		end
	end)

	-- Show list when the main window is shown if anchored to it and was previously visible
	--
	MusicianFrame:HookScript('OnShow', function()
		if MusicianFrame.musicianListWasVisible ~= false and MusicianListFrame:GetNumPoints() > 0 then
			MusicianListFrame:Show()
		end
	end)

	-- Show song list window when compressed song data has been successfully downloaded.
	--
	MusicianList.Frame:RegisterMessage(Musician.Events.SongReceiveSucessful, function(event, sender, songData, song)
		local isDataOnly = song == nil
		if isDataOnly then
			MusicianListFrame:Show()
		end
	end)
end

--- SetData
--
function MusicianList.Frame.SetData()
	local list = MusicianList.GetSongList()
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
	MusicianList.Frame.Filter()
end

--- Filter
-- @param filter (string)
function MusicianList.Frame.Filter(filter)
	if filter ~= nil then
		MusicianListFrameSearchBox:SetText(strtrim(filter))
	else
		filter = MusicianListFrameSearchBox:GetText()
	end

	filter = MusicianList.SearchString(filter)

	local index = 1
	local visibleIndex = 1
	local height = 0
	local children = { MusicianListFrameSongContainer:GetChildren() }
	for index, rowFrame in ipairs(children) do
		if index <= totalSongs and rowFrame.song ~= nil and (filter == "" or string.match(rowFrame.song.searchName, filter)) then
			rowFrame:Show()
			rowFrame:SetPoint("TOPLEFT", 0, -height)
			rowFrame.visibleIndex = visibleIndex
			rowFrame.isHighlighted = nil
			height = height + rowFrame:GetHeight()
			MusicianList.Frame.HighlightSongRow(rowFrame)
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

--- Enable or disable all buttons
-- @param enabled (boolean)
function MusicianList.Frame.SetButtonsEnabled(enabled)
	local rowFrame
	for _, rowFrame in pairs({ MusicianListFrameSongContainer:GetChildren() }) do
		rowFrame.title:SetEnabled(enabled)
		rowFrame.title.playButton:SetEnabled(enabled)
		rowFrame.title.previewButton:SetEnabled(enabled)
		rowFrame.title.linkButton:SetEnabled(enabled)
		rowFrame.title.renameButton:SetEnabled(enabled)
		rowFrame.title.deleteButton:SetEnabled(enabled)
	end
end

--- Disable all buttons while a process is running
--
function MusicianList.Frame.DisableButtons()
	MusicianList.Frame.SetButtonsEnabled(false)
end

--- Enable all buttons when a process finishes
--
function MusicianList.Frame.EnableButtons()
	MusicianList.Frame.SetButtonsEnabled(true)
end

--- Set tooltip for the highlighted song row
-- @param rowFrame (Frame)
-- @param hasMouseOver (boolean)
function MusicianList.Frame.SetRowTooltip(rowFrame, hasMouseOver)
	if hasMouseOver and rowFrame.title.text:GetStringWidth() > rowFrame.title.text:GetWidth() then
		GameTooltip:SetOwner(rowFrame.title, "ANCHOR_RIGHT")
		GameTooltip_SetTitle(GameTooltip, rowFrame.title:GetText())
	elseif not(hasMouseOver) and GameTooltip:GetOwner() == rowFrame.title then
		GameTooltip:Hide()
	end
end

--- Highlight song row
-- @param rowFrame (Frame)
-- @param[opt] isHighlighted (boolean)
function MusicianList.Frame.HighlightSongRow(rowFrame, isHighlighted)
	if isHighlighted == nil then
		isHighlighted = rowFrame.hasMouseOver or rowFrame.hasChildMouseOver or false
	end
	if isHighlighted == rowFrame.isHighlighted then return end
	if isHighlighted then
		if highlightedRowFrame ~= nil and highlightedRowFrame ~= rowFrame then
			MusicianList.Frame.HighlightSongRow(highlightedRowFrame, false)
		end
		highlightedRowFrame = rowFrame
		rowFrame.isHighlighted = true

		rowFrame.title.text:SetPoint('BOTTOMRIGHT', -76, 4)

		rowFrame.title.deleteButton:Show()
		rowFrame.title.renameButton:Show()
		rowFrame.title.linkButton:Show()
		rowFrame.title.previewButton:Show()
		rowFrame.title.playButton:Show()
		rowFrame.duration:Hide()
		rowFrame.background:SetColorTexture(.6, 0, 0, 1)
	else
		highlightedRowFrame = nil
		rowFrame.isHighlighted = false

		rowFrame.title.text:SetPoint('BOTTOMRIGHT', -34, 4)

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
