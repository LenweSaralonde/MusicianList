MusicianList.Locale.en = {}
local msg = MusicianList.Locale.en

msg.COMMAND_SAVE = "Save the current song in the list"
msg.COMMAND_SAVE_PARAMS = "[ **<song name>** ]"
msg.COMMAND_LOAD = "Load a song from the list"
msg.COMMAND_LOAD_PARAMS = "{ **<song name>** || **<song #>** }"
msg.COMMAND_PLAY = "Load and play a song from the list or play the current song"
msg.COMMAND_PLAY_PARAMS = "[ { **<song name>** || **<song #>** } ]"
msg.COMMAND_PREVIEW = "Load and preview a song from the list or preview the current song"
msg.COMMAND_PREVIEW_PARAMS = "[ { **<song name>** || **<song #>** } ]"
msg.COMMAND_LIST = "Show song list"
msg.COMMAND_DELETE = "Delete a song from the list or delete the current song"
msg.COMMAND_DELETE_PARAMS = "[ { **<song name>** || **<song #>** } ]"
msg.COMMAND_RENAME = "Rename a song in the list or rename the current song"
msg.COMMAND_RENAME_PARAMS = "[ **<song #>** [ **<new name>** ] ]"
msg.COMMAND_FIND = "Find a song in the list"
msg.COMMAND_FIND_PARAMS = "**<song name>**"

msg.MENU_LIST = "Song list"
msg.MENU_SAVE = "Save into list"

msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "Title"
msg.HEADER_SONG_DURATION = "Time"
msg.HEADER_SONG_ACTIONS = "Actions"

msg.ACTION_PLAY = "Load and play"
msg.ACTION_PREVIEW = "Load and preview"
msg.ACTION_RENAME = "Rename"
msg.ACTION_DELETE = "Delete"

msg.SAVE_SONG_AS = "Save song as:"
msg.RENAME_SONG = "Rename song:"
msg.OVERWRITE_CONFIRM = "\"%s\" already exists. Overwrite?"
msg.SAVING_SONG = "Saving \"{name}\"…"
msg.LOADING_SONG = "Loading \"{name}\"…"
msg.DONE_LOADING = "Done loading."
msg.DONE_SAVING = "Done saving."
msg.DELETE_CONFIRM = "Are you sure you would like to delete \"%s\"?"
msg.SONG_DELETED = "\"{name}\" has been deleted."
msg.SONG_RENAMED = "\"{name}\" has been renamed into \"{newName}\"."

msg.SONG_LIST = "Song list"
msg.FILTER_SONG = "Filter"
msg.SONG_LIST_EMPTY = "Song list is empty."
msg.IMPORT_A_SONG = "Import a song"
msg.NO_SONG_FOUND = "No song found."

msg.ERR_OUTDATED_MUSICIAN_VERSION = "Your version of Musician is outdated and can't be used with MusicianList. Please update Musician addon."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "Your version of MusicianList is outdated and can no longer be used. Please update."
msg.ERR_NO_SONG_TO_SAVE = "No song to save."
msg.ERR_SONG_NAME_EMPTY = "Song name can't be empty."
msg.ERR_SONG_NOT_FOUND = "Song not found."
msg.ERR_CANNOT_SAVE_NOW = "Song cannot be saved for now."
msg.ERR_CANNOT_LOAD_NOW = "Song cannot be loaded for now."

MusicianList.Msg = msg
