MusicianList = LibStub("AceAddon-3.0"):NewAddon("MusicianList", "AceEvent-3.0")

local LibDeflate = LibStub:GetLibrary("LibDeflate")

local PROCESS_SAVE = "save"
local PROCESS_LOAD = "load"

local currentImportStep
local currentImportData
local importedSongData

local currentProcess

local MusicianCmd

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

	-- Hook Musician command
	MusicianCmd = SlashCmdList["MUSICIAN"]
	SlashCmdList["MUSICIAN"] = MusicianList.Command

	-- Hyperlinks
	--

	hooksecurefunc("ChatFrame_OnHyperlinkShow", function(self, link, text, button)
		local args = { strsplit(':', link) }
		if args[1] == "musicianlist" then
			-- Load song
			if args[2] == "load" then
				MusicianList.Load(args[3])
			-- Play song
			elseif args[2] == "play" then
				MusicianList.Load(args[3], true)
			-- Delete song
			elseif args[2] == "delete" then
				MusicianList.Delete(args[3])
			end
		end
	end)
end


--- Run command
-- @param command (string)
function MusicianList.Command(command)
	local cmdParts = { string.split(' ', strtrim(command)) }
	local cmd = strlower(cmdParts[1])
	local value = table.concat(cmdParts, ' ', 2)

	if cmd == 'save' then
		MusicianList.Save(value)
	elseif cmd == 'load' or cmd == 'play' then
		MusicianList.Load(value, cmd == 'play')
	elseif cmd == 'list' or cmd == 'songs' then
		MusicianList.List()
	elseif cmd == 'delete' or cmd == 'del' or cmd == 'remove' then
		MusicianList.Delete(value)
	else
		MusicianCmd(command) -- Fallback on Musician's base commands
	end
end

--- Get sorted song list
-- @return (table)
function MusicianList.GetSongList()
	local list = {}
	local song
	for _, song in pairs(MusicianList_Storage.data) do
		table.insert(list, song)
	end

	table.sort(list, function(a, b)
		return a.name < b.name
	end)

	return list
end

--- List songs
--
function MusicianList.List()
	local list = MusicianList.GetSongList()

	if #list == 0 then
		Musician.Utils.Print(MusicianList.Msg.NO_SONG)
		return
	end

	local i, song
	for i, song in pairs(list) do
		local row =
			Musician.Utils.Print(
				Musician.Utils.Highlight(Musician.Utils.GetLink("musicianlist", MusicianList.Msg.LINK_PLAY, "play", song.name), 'FF0000') .. ' ' ..
				Musician.Utils.PaddingZeros(i, floor(log10(#list) + 1)) .. '. ' ..
				Musician.Utils.Highlight(Musician.Utils.GetLink("musicianlist", '[' .. song.name .. ']', "load", song.name)) ..
				' (' .. Musician.Utils.FormatTime(song.cropTo - song.cropFrom, true) .. ') '
			-- .. ' [' .. Musician.Utils.Highlight(Musician.Utils.GetLink("musicianlist", MusicianList.Msg.LINK_DELETE, "delete", song.name), 'FF0000') .. '] '
			)
	end
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
		MusicianList_Storage.data[strlower(currentProcess.name)] = Musician.Utils.DeepCopy(currentProcess.savedData)
		Musician.Comm:SendMessage(MusicianList.Events.SongSaveComplete, currentProcess)
		currentProcess = nil

		Musician.Utils.Print(MusicianList.Msg.DONE_SAVING)
	else
		currentProcess.cursor = to + 1
	end
end

--- Save song
-- @param name (string)
function MusicianList.Save(name)

	if currentProcess or Musician.importingSong then
		MusicianList.PrintError(MusicianList.Msg.ERR_CANNOT_SAVE_NOW)
		return
	end

	if not(importedSongData) or not(Musician.sourceSong) then
		MusicianList.PrintError(MusicianList.Msg.ERR_NO_SONG_TO_SAVE)
		return
	end

	if name == nil or name == '' then
		name = Musician.sourceSong.name
	else
		name = strtrim(name)
	end

	Musician.Utils.Print(string.gsub(MusicianList.Msg.SAVING_SONG, "{name}", Musician.Utils.Highlight(name)))

	currentProcess = {
		['process'] = PROCESS_SAVE,
		['cursor'] = 1,
		['rawData'] = importedSongData,
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
-- @param nameOrIndex (string)
-- @param play (boolean) Play song after loading
function MusicianList.Load(nameOrIndex, play)

	if currentProcess or Musician.importingSong then
		MusicianList.PrintError(MusicianList.Msg.ERR_CANNOT_LOAD_NOW)
		return
	end

	nameOrIndex = strtrim(strlower(nameOrIndex))
	local name = nameOrIndex

	-- Song has not been found by name
	if not(MusicianList_Storage.data[nameOrIndex]) then
		-- Try to load by index
		local list = MusicianList.GetSongList()
		local index = tonumber(nameOrIndex)
		if index ~= nil and list[index] then
			name = strtrim(strlower(list[index].name))
		else
			MusicianList.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
			return
		end
	end

	currentProcess = {
		['process'] = PROCESS_LOAD,
		['cursor'] = 1,
		['play'] = play,
		['rawData'] = '',
		['name'] = name,
		['song'] = Musician.Song.create(),
		['savedData'] = MusicianList_Storage.data[name]
	}

	Musician.Utils.Print(string.gsub(MusicianList.Msg.LOADING_SONG, "{name}", Musician.Utils.Highlight(currentProcess.savedData.name)))

	currentProcess.song.importing = true
	Musician.Comm:SendMessage(MusicianList.Events.SongLoadStart, currentProcess)
	Musician.Comm:SendMessage(MusicianList.Events.SongLoadProgress, currentProcess, 0)
end


--- Delete song
-- @param nameOrIndex (string)
function MusicianList.Delete(nameOrIndex)

	if nameOrIndex == nil or nameOrIndex == '' then
		nameOrIndex = Musician.sourceSong.name
	else
		nameOrIndex = strtrim(strlower(nameOrIndex))
	end

	local name = nameOrIndex

	-- Song has not been found by name
	if not(MusicianList_Storage.data[nameOrIndex]) then
		-- Try to load by index
		local list = MusicianList.GetSongList()
		local index = tonumber(nameOrIndex)
		if index ~= nil and list[index] then
			name = strtrim(strlower(list[index].name))
		else
			MusicianList.PrintError(MusicianList.Msg.ERR_SONG_NOT_FOUND)
			return
		end
	end

	local oldName = MusicianList_Storage.data[name].name
	MusicianList_Storage.data[name] = nil
	Musician.Utils.Print(string.gsub(MusicianList.Msg.SONG_DELETED, "{name}", Musician.Utils.Highlight(oldName)))
end

function MusicianList.OnSongImportStart(event, song)
	if song ~= Musician.importingSong then
		return
	end
	currentImportStep = song.import.step
end

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

function MusicianList.OnSongImportFailed(event, song)
	-- Abort loading process if it failed for some reason
	if currentProcess and currentProcess.process == PROCESS_LOAD and song == currentProcess.song then
		currentProcess = nil
	end
end

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

--- Display an error message in the console
-- @param msg (string)
function MusicianList.PrintError(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 0, 0)
	PlaySoundFile("Sound\\interface\\Error.ogg")
end


