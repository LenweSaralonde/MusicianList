MusicianList.Frame = LibStub("AceAddon-3.0"):NewAddon("MusicianList.Frame", "AceEvent-3.0")

local totalSongs = 0

local highlightedRowFrame

local MAGNETIC_EDGES_RANGE = 20

local NORMAL_SONG_COLOR = CreateColor(1, 1, 1)
local PLAYED_SONG_COLOR = CreateColor(0.7, 0.7, 0.7)

--- Handle magnetic edges
--
local function magneticEdges()

	local frame = MusicianListFrame
	local anchor = MusicianFrame

	local anchorTop, anchorBottom, anchorLeft, anchorRight =
	anchor:GetTop(), anchor:GetBottom(), anchor:GetLeft(), anchor:GetRight()
	local frameTop, frameBottom, frameLeft, frameRight =
	frame:GetTop(), frame:GetBottom(), frame:GetLeft(), frame:GetRight()

	-- The positions might be nil
	if anchorTop == nil or anchorBottom == nil or anchorLeft == nil or anchorRight == nil or
		frameTop == nil or frameBottom == nil or frameLeft == nil or frameRight == nil
	then
		return
	end

	local isTopSticky = abs(anchorBottom - frameTop) <= MAGNETIC_EDGES_RANGE
	local isBottomSticky = abs(anchorTop - frameBottom) <= MAGNETIC_EDGES_RANGE
	local isLeftSticky = abs(anchorRight - frameLeft) <= MAGNETIC_EDGES_RANGE
	local isRightSticky = abs(anchorLeft - frameRight) <= MAGNETIC_EDGES_RANGE

	local isLeftAligned = abs(anchorLeft - frameLeft) <= MAGNETIC_EDGES_RANGE
	local isRightAligned = abs(anchorRight - frameRight) <= MAGNETIC_EDGES_RANGE
	local isTopAligned = abs(anchorTop - frameTop) <= MAGNETIC_EDGES_RANGE
	local isBottomAligned = abs(anchorBottom - frameBottom) <= MAGNETIC_EDGES_RANGE

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

--- Handle magnetic edges on drag stop
--
local function onMagneticDragStop()
	if MusicianFrame:IsVisible() and MusicianListFrame:IsVisible() then
		magneticEdges()
	end
end

--- Clamp main frame dimensions
--
local function clampSize()
	local width, height = MusicianListFrame:GetSize()
	local minWidth, minHeight = 160, 160
	local maxWidth, maxHeight = UIParent:GetWidth() / MusicianListFrame:GetScale(),
		UIParent:GetHeight() / MusicianListFrame:GetScale()
	MusicianListFrame:SetSize(
		max(minWidth, min(maxWidth, width)),
		max(minHeight, min(maxHeight, height))
	)
end

--- Get song row frame by index
-- @param index (int)
-- @return rowFrame (Frame)
local function getRowFrame(index)
	return _G['MusicianListSong' .. index]
end

--- Init
--
function MusicianList.Frame.Init()
	-- Main init
	MusicianListFrame:DisableEscape()

	-- Set the default anchor at the bottom of the Musician frame
	if not MusicianListFrame:IsUserPlaced() then
		MusicianListFrame:ClearAllPoints()
		MusicianListFrame:SetPoint("TOP", MusicianFrame, "BOTTOM")
	end

	-- Set default height for WoW Classic
	if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and not MusicianListFrame:IsUserPlaced() then
		MusicianListFrame:SetHeight(330)
	end

	-- Clamp frame size
	MusicianListFrame:HookScript("OnSizeChanged", clampSize)
	clampSize()

	-- Set texts
	MusicianListFrameTitle:SetText(MusicianList.Msg.SONG_LIST)
	MusicianListFrameHeaderSongIndex:SetText(MusicianList.Msg.HEADER_SONG_INDEX)
	MusicianListFrameHeaderSongTitle:SetText(MusicianList.Msg.HEADER_SONG_TITLE)
	MusicianListFrameHeaderSongDuration:SetText(MusicianList.Msg.HEADER_SONG_DURATION)

	-- Scroll frame
	MusicianListFrameScrollFrame:SetScript("OnSizeChanged", function(self)
		MusicianListFrameSongContainer:SetWidth(self:GetWidth())
	end)

	-- Song list empty button
	MusicianListFrameListEmptyImportButton:SetText(MusicianList.Msg.IMPORT_A_SONG)
	MusicianListFrameListEmptyImportButton.icon:SetText(MusicianList.Icons.CloudDown)
	MusicianListFrameListEmptyImportButton:HookScript("OnClick", function()
		MusicianFrame:Show()
	end)

	-- Resize button
	local resizeButton = MusicianListFrameResizeButton
	for _, texture in ipairs({ resizeButton:GetNormalTexture(), resizeButton:GetHighlightTexture(),
		resizeButton:GetPushedTexture() }) do
		texture:ClearAllPoints()
		texture:SetPoint("BOTTOMRIGHT", -10, 10)
		texture:SetSize(20, 20)
	end
	resizeButton.frameLevel = MusicianListFrame.searchBox:GetFrameLevel() + 100
	resizeButton:SetFrameLevel(resizeButton.frameLevel)
	resizeButton:HookScript("OnMouseDown", function(self)
		self:SetButtonState("PUSHED", true)
		self:GetHighlightTexture():Hide()
		MusicianListFrame:StartSizing("BOTTOMRIGHT")
	end)
	resizeButton:HookScript("OnMouseUp", function(self)
		self:SetButtonState("NORMAL", false)
		self:GetHighlightTexture():Show()
		MusicianListFrame:StopMovingOrSizing()
	end)

	-- Search box
	SearchBoxTemplate_OnLoad(MusicianListFrameSearchBox)
	MusicianListFrameSearchBox.Instructions:SetText(MusicianList.Msg.FILTER_SONG)
	MusicianListFrameSearchBox.ReorderButtons = function(self)
		if #self:GetText() > 0 then
			resizeButton:SetFrameLevel(self:GetFrameLevel() - 1)
		else
			resizeButton:SetFrameLevel(resizeButton.frameLevel)
		end
	end
	MusicianListFrameSearchBox:HookScript("OnEditFocusGained", function(self)
		resizeButton:SetFrameLevel(self:GetFrameLevel() - 1)
	end)
	MusicianListFrameSearchBox:HookScript("OnEditFocusLost", function(self)
		self:ReorderButtons()
	end)
	MusicianListFrameSearchBox:HookScript("OnTextChanged", function(self, isUserInput)
		SearchBoxTemplate_OnTextChanged(self, isUserInput)
		MusicianList.Frame.Filter()
		self:ReorderButtons()
	end)

	-- Data refresh events
	MusicianList.Frame:RegisterMessage(MusicianList.Events.ListUpdate, MusicianList.Frame.SetData)

	-- Source import events
	MusicianList.Frame:RegisterMessage(Musician.Events.SongImportStart, function()
		MusicianList.Frame.DisableButtons()
	end)
	MusicianList.Frame:RegisterMessage(Musician.Events.SongImportComplete, function()
		MusicianList.Frame.EnableButtons()
	end)
	MusicianList.Frame:RegisterMessage(Musician.Events.SongImportFailed, function()
		if not Musician.importingSong or not Musician.importingSong.importing then
			MusicianFrameClearButton:Enable()
			MusicianFrameSource:Enable()
			Musician.Frame.SetLoadingProgressBar(nil)
			Musician.Frame.Clear()
		end
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
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongLoadComplete, function(event, song)
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
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongSaveComplete, function(event)
		Musician.Frame.SetLoadingProgressBar(nil)
		Musician.Frame.Clear()
		MusicianList.Frame.EnableButtons()
	end)
	MusicianList.Frame:RegisterMessage(MusicianList.Events.SongSaveProgress, function(event, _, _, progression)
		Musician.Frame.SetLoadingProgressBar(progression)
	end)

	-- Populate data
	MusicianList.Frame.SetData()

	-- Handle magnetic edges
	MusicianListFrame:HookScript('OnDragStop', onMagneticDragStop)
	MusicianFrame:HookScript('OnDragStop', onMagneticDragStop)
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
	MusicianList.Frame:RegisterMessage(Musician.Events.SongReceiveSuccessful, function(event, _, _, song, context)
		if context ~= Musician then return end
		local isDataOnly = song == nil
		if isDataOnly then
			MusicianListFrame:Show()
		end
	end)

	--- Gray out played songs
	--
	MusicianList.Frame:RegisterMessage(Musician.Events.StreamStart, function(event, song)
		if not song.isLiveStreamingSong then
			local id = MusicianList.GetSongId(song.name)
			local children = { MusicianListFrameSongContainer:GetChildren() }
			for _, rowFrame in ipairs(children) do
				if rowFrame.song ~= nil and rowFrame.song.id == id then
					rowFrame.title.text:SetTextColor(PLAYED_SONG_COLOR.r, PLAYED_SONG_COLOR.g, PLAYED_SONG_COLOR.b, PLAYED_SONG_COLOR.a)
					return
				end
			end
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
		if MusicianList.playedSongs[song.id] then
			rowFrame.title.text:SetTextColor(PLAYED_SONG_COLOR.r, PLAYED_SONG_COLOR.g, PLAYED_SONG_COLOR.b, PLAYED_SONG_COLOR.a)
		else
			rowFrame.title.text:SetTextColor(NORMAL_SONG_COLOR.r, NORMAL_SONG_COLOR.g, NORMAL_SONG_COLOR.b, NORMAL_SONG_COLOR.a)
		end
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
		GameTooltip:Show()
	elseif not hasMouseOver and GameTooltip:GetOwner() == rowFrame.title then
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

-- Widget functions
--

--- Button simple template OnLoad
--
function MusicianListButtonSimpleTemplate_OnLoad(button)
	button:SetScript("OnMouseDown", function(self)
		if self:IsEnabled() then
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
		end
	end)
	button:HookScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip_SetTitle(GameTooltip, self.tooltipText)
			GameTooltip:Show()
		end
	end)
	button:HookScript("OnLeave", function(self)
		if self.tooltipText then
			GameTooltip:Hide()
		end
	end)
end

--- Icon button simple template OnLoad
--
function MusicianListIconButtonSimpleTemplate_OnLoad(button)
	button:HookScript("OnEnter", function(self)
		local rowFrame = self:GetParent():GetParent()
		rowFrame.hasChildMouseOver = true
		MusicianList.Frame.HighlightSongRow(rowFrame)
	end)
	button:HookScript("OnLeave", function(self)
		local rowFrame = self:GetParent():GetParent()
		rowFrame.hasChildMouseOver = false
		C_Timer.After(0, function()
			MusicianList.Frame.HighlightSongRow(rowFrame)
		end)
	end)
end

--- Icon button template OnLoad
--
function MusicianListIconButtonTemplate_OnLoad(button)
	button:HookScript("OnMouseDown", function(self)
		if self:IsEnabled() then
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
		end
	end)
end

--- Standard button with text and icon template OnLoad
--
function MusicianListIconTextButtonTemplate_OnLoad(button)
	button:HookScript("OnEnter", function(self)
		if self:IsEnabled() then
			self.icon:SetFontObject(MusicianListFontIconsHighlight)
		end
	end)
	button:HookScript("OnLeave", function(self)
		if self:IsEnabled() then
			self.icon:SetFontObject(MusicianListFontIconsNormal)
		end
	end)
	button:HookScript("OnEnable", function(self)
		self.icon:SetFontObject(MusicianListFontIconsNormal)
	end)
	button:HookScript("OnDisable", function(self)
		self.icon:SetFontObject(MusicianListFontIconsDisable)
	end)
	button:HookScript("OnMouseDown", function(self)
		if self:IsEnabled() then
			if (not self.icon.oldPoint) then
				local point, _, _, x, y = self.icon:GetPoint(1)
				self.icon.oldPoint = point
				self.icon.oldX = x
				self.icon.oldY = y
			end
			local ox, oy = self:GetPushedTextOffset()
			self.icon:SetPoint(self.icon.oldPoint, self.icon.oldX + ox, self.icon.oldY + oy)
		end
	end)
	button:HookScript("OnMouseUp", function(self)
		if self:IsEnabled() then
			self.icon:SetPoint(self.icon.oldPoint, self.icon.oldX, self.icon.oldY)
		end
	end)
end

--- Song row template OnLoad
--
function MusicianListSongTemplate_OnLoad(row)
	-- Play button
	row.title.playButton:SetText(MusicianList.Icons.Play)
	row.title.playButton.tooltipText = MusicianList.Msg.ACTION_PLAY
	row.title.playButton:HookScript("OnClick", function(self)
		MusicianList.Load(row.song.id, MusicianList.LoadActions.Play)
	end)

	-- Preview button
	row.title.previewButton:SetText(MusicianList.Icons.Headphones)
	row.title.previewButton.tooltipText = MusicianList.Msg.ACTION_PREVIEW
	row.title.previewButton:HookScript("OnClick", function(self)
		MusicianList.Load(row.song.id, MusicianList.LoadActions.Preview)
	end)

	-- Link button
	row.title.linkButton:SetText(MusicianList.Icons.Export)
	row.title.linkButton.tooltipText = MusicianList.Msg.ACTION_LINK
	row.title.linkButton:HookScript("OnClick", function(self)
		MusicianList.Link(row.song.id)
	end)

	-- Rename button
	row.title.renameButton:SetText(MusicianList.Icons.Pencil)
	row.title.renameButton.tooltipText = MusicianList.Msg.ACTION_RENAME
	row.title.renameButton:HookScript("OnClick", function(self)
		MusicianList.Rename(row.song.id)
	end)

	-- Delete button
	row.title.deleteButton:SetText(MusicianList.Icons.Trash)
	row.title.deleteButton.tooltipText = MusicianList.Msg.ACTION_DELETE
	row.title.deleteButton:HookScript("OnClick", function(self)
		MusicianList.Delete(row.song.id)
	end)

	-- Title handlers
	row.title:HookScript("OnClick", function(self)
		MusicianList.Load(row.song.id)
	end)
	row.title:HookScript("OnEnter", function(self)
		row.hasMouseOver = true
		MusicianList.Frame.HighlightSongRow(row)
		MusicianList.Frame.SetRowTooltip(row, true)
	end)
	row.title:HookScript("OnLeave", function(self)
		row.hasMouseOver = false
		C_Timer.After(0, function()
			MusicianList.Frame.HighlightSongRow(row)
			MusicianList.Frame.SetRowTooltip(row, false)
		end)
	end)
end