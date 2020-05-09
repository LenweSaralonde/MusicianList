MusicianList.Frame = LibStub("AceAddon-3.0"):NewAddon("MusicianList.Frame", "AceEvent-3.0")

local totalSongs = 0

local isDragging = false

--- Handle magnetic edges
--
function magneticEdges()
	local isTopSticky = abs(MusicianFrame:GetBottom() - MusicianListFrame:GetTop()) <= 20
	local isBottomSticky = abs(MusicianFrame:GetTop() - MusicianListFrame:GetBottom()) <= 20
	local isLeftSticky = abs(MusicianFrame:GetLeft() - MusicianListFrame:GetLeft()) <= 20
	local isRightSticky = abs(MusicianFrame:GetRight() - MusicianListFrame:GetRight()) <= 20

	local isTopLeftSticky = isTopSticky and isLeftSticky
	local isTopRightSticky = isTopSticky and isRightSticky
	local isBottomLeftSticky = isBottomSticky and isLeftSticky
	local isBottomRightSticky = isBottomSticky and isRightSticky

	MusicianListFrame:ClearAllPoints()

	if isTopLeftSticky then
		MusicianListFrame:SetPoint('TOPLEFT', MusicianFrame, 'BOTTOMLEFT', 0, 0)
	end

	if isTopRightSticky then
		MusicianListFrame:SetPoint('TOPRIGHT', MusicianFrame, 'BOTTOMRIGHT', 0, 0)
	end

	if isBottomLeftSticky then
		MusicianListFrame:SetPoint('BOTTOMLEFT', MusicianFrame, 'TOPLEFT', 0, 0)
	end

	if isBottomRightSticky then
		MusicianListFrame:SetPoint('BOTTOMRIGHT', MusicianFrame, 'TOPRIGHT', 0, 0)
	end
end

--- Handle magnetic edges on frame move or resize
--
function magneticEdgesOnMove()
	if MusicianFrame:IsVisible() and MusicianListFrame:IsVisible() then
		magneticEdges()
	end
end

--- Handle magnetic edges on drag start
--
function onMagneticDragStart()
	isDragging = true
	magneticEdgesOnMove()
end

--- Handle magnetic edges on drag stop
--
function onMagneticDragStop()
	isDragging = false
	magneticEdgesOnMove()
end

--- Init
--
MusicianList.Frame.Init = function()
	MusicianList.Frame:RegisterMessage(MusicianList.Events.ListUpdate, MusicianList.Frame.SetData)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadProgress, MusicianList.Frame.OnProgress)
	MusicianList.Frame:RegisterMessage(Musician.Events.SongImportStart, MusicianList.Frame.DisableButtons)
	MusicianList.Frame:RegisterMessage(Musician.Events.SongImportComplete, MusicianList.Frame.EnableButtons)
	MusicianList.Frame:RegisterMessage(Musician.Events.SourceSongLoaded, function()
		MusicianList.Frame.Filter()
	end)

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

	-- Handle magnetic edges
	MusicianListFrame:HookScript('OnDragStart', onMagneticDragStart)
	MusicianListFrame:HookScript('OnDragStop', onMagneticDragStop)
	MusicianFrame:HookScript('OnDragStart', onMagneticDragStart)
	MusicianFrame:HookScript('OnDragStop', onMagneticDragStop)
	MusicianListFrameResizeButton:HookScript('OnMouseDown', onMagneticDragStart)
	MusicianListFrameResizeButton:HookScript('OnMouseUp', onMagneticDragStop)
	MusicianFrame:HookScript('OnShow', magneticEdges)
	MusicianFrame:HookScript('OnUpdate', function()
		if isDragging then
			magneticEdgesOnMove()
		end
	end)
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

--- OnProgress
-- @param filter (string)
-- @param song (MusicianSong)
-- @param progression (number)
MusicianList.Frame.OnProgress = function(event, song, progression)
	local rowFrame
	for _, rowFrame in pairs({ MusicianListFrameSongContainer:GetChildren() }) do
		if song.savedId == rowFrame.song.id then
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
		rowFrame.title.previewButton:Show()
		rowFrame.title.playButton:Show()
		rowFrame.duration:Hide()
		rowFrame.background:SetColorTexture(.6, 0, 0, 1)
	else
		rowFrame.title.deleteButton:Hide()
		rowFrame.title.renameButton:Hide()
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
