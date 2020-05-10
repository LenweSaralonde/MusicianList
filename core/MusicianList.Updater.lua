MusicianList.Updater = LibStub("AceAddon-3.0"):NewAddon("MusicianListUpdater", "AceEvent-3.0")

local MODULE_NAME = "ListUpdater"
Musician.AddModule(MODULE_NAME)

--- Perform updates from v1 to v4, if necessary
-- @param onComplete (function)
local function updateTo4(onComplete)
	local LibDeflate = LibStub:GetLibrary("LibDeflate")

	-- Version 1 => 2
	-- ==============

	if MusicianList_Storage.version == 1 then

		local invalidIds = {}

		local songData, id
		for id, songData in pairs(MusicianList_Storage.data) do
			Musician.Utils.Debug(MODULE_NAME, "Updating song to MUS4 format", id)

			-- Check for invalid ID
			local validId = MusicianList.GetSongId(songData.name)
			if validId ~= id then
				invalidIds[id] = validId
			end

			-- Trim song name
			songData.name = strtrim(songData.name)

			-- Remove unused indexes
			songData.index = nil

			-- Add song format
			local chunk = LibDeflate:DecompressDeflate(songData.chunks[1])
			if chunk ~= nil then
				local format = string.sub(chunk, 1, 4)
				songData.format = format -- Keep a trace of the original song format

				-- Convert to new format
				if format ~= 'MUS4' then
					chunk = 'MUS4' .. string.sub(chunk, 5)
					songData.chunks[1] = LibDeflate:CompressDeflate(chunk, { level = 9 })
				end
			end
		end

		-- Fix invalid IDs
		local validId
		for id, validId in pairs(invalidIds) do
			MusicianList_Storage.data[validId] = MusicianList_Storage.data[id]
			MusicianList_Storage.data[id] = nil
		end

		-- Add demo songs
		MusicianList.RestoreDemoSongs(false)

		-- Increment version number
		MusicianList_Storage.version = 2
	end

	-- Version 2 => 3
	-- ==============

	if MusicianList_Storage.version == 2 then
		-- Remove songs corrupted by the CurseForge packager

		local checkSong = function(songData)
			local compressedChunk
			for _, compressedChunk in pairs(songData.chunks) do
				local chunk = LibDeflate:DecompressDeflate(compressedChunk)
				if chunk == nil then
					return false
				end
			end
			return true
		end

		local songData, id
		for id, songData in pairs(MusicianList_Storage.data) do
			Musician.Utils.Debug(MODULE_NAME, "Checking compressed song data", songData.name)
			if not(checkSong(songData)) then
				Musician.Utils.Debug(MODULE_NAME, "Data corrupted: deleting song", songData.name)
				MusicianList_Storage.data[id] = nil
			end
		end

		-- Restore demo songs if needed
		MusicianList.RestoreDemoSongs(false)

		-- Increment version number
		MusicianList_Storage.version = 3
	end

	-- Version 3 => 4
	-- ==============

	if MusicianList_Storage.version == 3 then
		-- Increment song version from MUS4 to MUS5
		local songData
		for _, songData in pairs(MusicianList_Storage.data) do
			Musician.Utils.Debug(MODULE_NAME, "Updating song to MUS5 format", songData.name)
			songData.format = "MUS5"
			local chunk = LibDeflate:DecompressDeflate(songData.chunks[1])
			chunk = "MUS5" .. string.sub(chunk, 5)
			songData.chunks[1] = LibDeflate:CompressDeflate(chunk, { level = 9 })
		end

		-- Increment version number
		MusicianList_Storage.version = 4
	end

	MusicianList.Updater.UpdateDB(onComplete)
end

--- Perform updates from v4 to v5, if necessary
-- Update songs in MUS5 format to MUS6
-- @param onComplete (function)
local function updateTo5(onComplete)
	local LibDeflate = LibStub:GetLibrary("LibDeflate")

	-- Create updater frame
	local updaterFrame = CreateFrame("Frame", "MusicianListUpdater5Frame", UIParent, "MusicianDialogTemplate")
	updaterFrame:SetWidth(500)
	updaterFrame:SetHeight(90)

	local titleLabel = updaterFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	titleLabel:SetWidth(updaterFrame:GetWidth() - 30)
	titleLabel:SetText(MusicianList.Msg.UPDATING_DB)
	titleLabel:SetPoint("TOP", 0, -15)

	local songLabel = updaterFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	songLabel:SetWidth(updaterFrame:GetWidth() - 30)
	songLabel:SetHeight(30)
	songLabel:SetPoint("TOP", titleLabel, "BOTTOM", 0, 0)

	local progressBarBackground = updaterFrame:CreateTexture(nil, "BACKGROUND")
	progressBarBackground:SetWidth(updaterFrame:GetWidth() - 30)
	progressBarBackground:SetHeight(10)
	progressBarBackground:SetColorTexture(0, 0, 0, .75)
	progressBarBackground:SetPoint("BOTTOM", 0, 15)

	local progressBar = updaterFrame:CreateTexture(nil, "ARTWORK")
	progressBar:SetWidth(0)
	progressBar:SetHeight(10)
	progressBar:SetColorTexture(1, 1, 1, 1)
	progressBar:SetPoint("LEFT", progressBarBackground, "LEFT")

	updaterFrame:Show()

	local songIds = {}
	local cumulatedChunkCount = {}
	local songId, songData
	local totalChunkCount = 0
	for songId, songData in pairs(MusicianList_Storage.data) do
		table.insert(songIds, songId)
		table.insert(cumulatedChunkCount, totalChunkCount + #songData.chunks)
		totalChunkCount = totalChunkCount + #songData.chunks
	end

	local setProgression = function(songIndex, step, stepProgression)
		local prevSongChunkCount = cumulatedChunkCount[songIndex - 1] or 0
		local songChunkCount = cumulatedChunkCount[min(#songIds, songIndex)] - prevSongChunkCount
		local songProgressionRange = songChunkCount / totalChunkCount

		local songProgression = 0
		if step == 1 then
			songProgression = stepProgression * .1
		elseif step == 2 then
			songProgression = .1 + stepProgression * .8
		elseif step == 3 then
			songProgression = .9 + stepProgression * .1
		end

		local progression = prevSongChunkCount / totalChunkCount + songProgression * songProgressionRange

		progressBar:SetWidth(progression * progressBarBackground:GetWidth())
	end

	local currentSongIndex = 0
	local currentStep
	local currentSong
	local currentSongChunkIndex
	local currentTrackIndex
	local currentNoteIndex
	local cursor
	local trackCount
	local songNoteCount
	local songNoteIndex
	local trackNoteCount
	local trackInstruments
	local trackNoteIndex
	local updatedChunks
	local rawSongData
	local newSongData

	local updaterWorker
	updaterWorker = function(elapsed)

		-- Proceed with new song
		-- =====================

		if currentStep == nil then
			currentSongIndex = currentSongIndex + 1
			setProgression(currentSongIndex, 1, 0)

			-- No more song to proceed: we're done!
			if songIds[currentSongIndex] == nil then
				Musician.Worker.Remove(updaterWorker)
				MusicianList_Storage.version = 5
				updaterFrame:Hide()
				MusicianList.Updater.UpdateDB(onComplete)
				Musician.Utils.Print(MusicianList.Msg.UPDATING_DB_COMPLETE)
				return
			-- Processing new song
			else
				currentSong = MusicianList_Storage.data[songIds[currentSongIndex]]
				Musician.Utils.Debug(MODULE_NAME, "Updating song to MUS6 format", currentSong.name)
				songLabel:SetText(currentSong.name)
				rawSongData = ''
				newSongData = ''
				currentSongChunkIndex = 0
				currentStep = 1
				return
			end

		-- Step 1: uncompress song chunk
		-- =============================

		elseif currentStep == 1 then
			currentSongChunkIndex = currentSongChunkIndex + 1

			-- Last chunk has been uncompressed: go to step 2
			if currentSong.chunks[currentSongChunkIndex] == nil then
				currentStep = 2
				cursor = 1
				return
			end

			setProgression(currentSongIndex, 1, currentSongChunkIndex / #currentSong.chunks)

			rawSongData = rawSongData .. LibDeflate:DecompressDeflate(currentSong.chunks[currentSongChunkIndex])

			-- Skip to next song if the song is already in MUS6 format
			if currentSongChunkIndex == 1 and string.sub(rawSongData, 1, 4) == 'MUS6' then
				currentStep = nil
			end

			-- Fix instrument IDs in track options
			local trackOptionId, trackOptions
			for trackOptionId, trackOptions in pairs(currentSong.tracks) do
				-- MUS5 drum kit had ID 129, now use GM Power drum kit ID (144)
				if trackOptions.instrument == 129 then
					trackOptions.instrument = 144
				end
			end

			return

		-- Step 2: Update track information in header
		-- ==========================================
		elseif currentStep == 2 then

			setProgression(currentSongIndex, 1, 1)

			-- Header (4)
			newSongData = 'MUS6'
			cursor = cursor + 4

			-- Duration (3)
			newSongData = newSongData .. string.sub(rawSongData, cursor, cursor + 2)
			cursor = cursor + 3

			-- Number of tracks (1)
			local trackCount = Musician.Utils.UnpackNumber(string.sub(rawSongData, cursor, cursor))
			newSongData = newSongData .. string.sub(rawSongData, cursor, cursor)
			cursor = cursor + 1

			-- Track information: instrument (1), channel (1), note count (2)
			local trackIndex
			trackNoteCount = {}
			trackInstruments = {}
			songNoteCount = 0
			for trackIndex = 1, trackCount do

				-- Instrument (1)
				local instrument = Musician.Utils.UnpackNumber(string.sub(rawSongData, cursor, cursor))

				-- MUS5 drum kit had ID 129, now use GM Power drum kit ID (144)
				if instrument == 129 then
					instrument = 144
				end

				trackInstruments[trackIndex] = instrument

				newSongData = newSongData .. Musician.Utils.PackNumber(instrument, 1)
				cursor = cursor + 1

				-- Channel (1)
				newSongData = newSongData .. string.sub(rawSongData, cursor, cursor)
				cursor = cursor + 1

				-- Note count (2)
				trackNoteCount[trackIndex] = Musician.Utils.UnpackNumber(string.sub(rawSongData, cursor, cursor + 1))
				songNoteCount = songNoteCount + trackNoteCount[trackIndex]
				newSongData = newSongData .. string.sub(rawSongData, cursor, cursor + 1)
				cursor = cursor + 2
			end

			currentTrackIndex = 1
			currentNoteIndex = 1
			songNoteIndex = 1
			currentStep = 3
			return

		-- Step 3: Update notes
		-- ====================

		elseif currentStep == 3 then

			-- No more track to process: go to next step
			if trackNoteCount[currentTrackIndex] == nil then
				-- Append the rest of the raw song data
				newSongData = newSongData .. string.sub(rawSongData, cursor, #rawSongData)
				updatedChunks = {}
				cursor = 1
				currentStep = 4
				setProgression(currentSongIndex, 2, 1)
				return
			end

			setProgression(currentSongIndex, 2, songNoteIndex / songNoteCount)

			-- Process 36 notes per cycle
			local notesTodo = min(36, trackNoteCount[currentTrackIndex] - currentNoteIndex + 1)
			local i
			for i = 1, notesTodo do

				-- Key (1)
				local key = Musician.Utils.UnpackNumber(string.sub(rawSongData, cursor, cursor))

				-- Fix MIDI key number for melodic tracks
				if key ~= 0xFF and trackInstruments[currentTrackIndex] < 128 then
					key = key - 12
				end

				newSongData = newSongData .. Musician.Utils.PackNumber(key, 1)
				cursor = cursor + 1

				-- This is not a spacer (key 0xFF)
				if key ~= 0xFF then
					-- Time (2)
					newSongData = newSongData .. string.sub(rawSongData, cursor, cursor + 1)
					cursor = cursor + 2

					-- Duration (1)
					newSongData = newSongData .. string.sub(rawSongData, cursor, cursor)
					cursor = cursor + 1
				end

				-- Proceed with next note
				currentNoteIndex = currentNoteIndex + 1
				songNoteIndex = songNoteIndex + 1
			end

			-- No more note to process: go to next track
			if currentNoteIndex > trackNoteCount[currentTrackIndex] then
				currentNoteIndex = 1
				currentTrackIndex = currentTrackIndex + 1
				return
			end

			return

		-- Step 4: compress song chunk
		-- ===========================

		elseif currentStep == 4 then
			local to = min(#newSongData, cursor + MusicianList.CHUNK_SIZE - 1)
			local chunk = string.sub(newSongData, cursor, to)
			setProgression(currentSongIndex, 3, cursor / #newSongData)

			local compressedChunk = LibDeflate:CompressDeflate(chunk, { level = 9 })
			table.insert(updatedChunks, compressedChunk)

			if to == #newSongData then
				currentSong.chunks = updatedChunks
				currentSong.format = "MUS6"
				currentStep = nil
				setProgression(currentSongIndex, 3, 1)
			else
				cursor = cursor + MusicianList.CHUNK_SIZE
			end
		end
	end

	Musician.Worker.Set(updaterWorker)
end

--- Update database
-- @param onComplete (function) Run when update process is complete
function MusicianList.Updater.UpdateDB(onComplete)
	if MusicianList_Storage.version < 4 then
		updateTo4(onComplete)
	elseif MusicianList_Storage.version == 4 then
		updateTo5(onComplete)
	else
		onComplete()
	end
end