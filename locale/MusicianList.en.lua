MusicianList.Locale.en = {}
local msg = MusicianList.Locale.en

msg.COMMAND_SAVE = "Save the current song in the list"
msg.COMMAND_SAVE_PARAMS = "[ **<song name>** ]"
msg.COMMAND_LOAD = "Load a song from the list"
msg.COMMAND_LOAD_PARAMS = "{ **<song name>** || **<song #>** }"
msg.COMMAND_PLAY = "Load and play a song from the list or play the current song"
msg.COMMAND_PLAY_PARAMS = "[ { **<song name>** || **<song #>** } ]"
msg.COMMAND_LIST = "Show song list"
msg.COMMAND_DELETE = "Delete a song from the list or delete the current song"
msg.COMMAND_DELETE_PARAMS = "[ { **<song name>** || **<song #>** } ]"
msg.COMMAND_FIND = "Find a song in the list"
msg.COMMAND_FIND_PARAMS = "**<keyword 1>** [ **<keyword 2>** ] [ … **<keyword n>** ]"

msg.MENU_LIST = "Song list"
msg.MENU_SAVE = "Save into list"
msg.MENU_DELETE = "Delete from list"

msg.SAVING_SONG = "Saving \"{name}\"…"
msg.LOADING_SONG = "Loading \"{name}\"…"
msg.DONE_LOADING = "Done loading."
msg.DONE_SAVING = "Done saving."
msg.SONG_DELETED = "\"{name}\" has been deleted."

msg.NO_SONG = "No song in list."
msg.NO_SONG_FOUND = "No song found."
msg.SONG_LIST = "Song list"
msg.FOUND_SONG_LIST = "Found songs"

msg.LINK_PLAY = "►"
msg.LINK_DELETE = "X"

msg.ERR_OUTDATED_MUSICIAN_VERSION = "Your version of Musician is outdated and can't be used with MusicianList. Please update Musician addon."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "Your version of MusicianList is outdated and can no longer be used. Please update."
msg.ERR_NO_SONG_TO_SAVE = "No song to save."
msg.ERR_SONG_NOT_FOUND = "Song not found."
msg.ERR_CANNOT_SAVE_NOW = "Song cannot be saved for now."
msg.ERR_CANNOT_LOAD_NOW = "Song cannot be loaded for now."

MusicianList.Msg = msg
