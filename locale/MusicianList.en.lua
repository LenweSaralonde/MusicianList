------------------------------------------------------------------------
-- Please read the localization guide in the Wiki:
-- https://github.com/LenweSaralonde/Musician/wiki/Localization
--
-- * Commented out msg lines need to be translated.
-- * Do not translate anything on the left hand side of the = sign.
-- * Do not translate placeholders in curly braces ({variable}).
-- * Keep the text as a single line. Use \n for carriage return.
-- * Escape double quotes (") with a backslash (\").
-- * Check the result in game to make sure your text fits the UI.
------------------------------------------------------------------------

local msg = MusicianList.InitLocale('en', "English", 'enUS', 'enGB')

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

--- Chat commands
msg.COMMAND_SAVE = "Save the current song in the list"
msg.COMMAND_SAVE_PARAMS = "[ **<song name>** ]"
msg.COMMAND_LOAD = "Load a song from the list"
msg.COMMAND_LOAD_PARAMS = "{ **<song name>** || **<song #>** }"
msg.COMMAND_PLAY = "Load and play a song from the list or play/stop the current song"
msg.COMMAND_PLAY_OLD = "Load and play a song from the list or play the current song"
msg.COMMAND_PLAY_PARAMS = "[ { **<song name>** || **<song #>** } ]"
msg.COMMAND_PREVIEW = "Load and preview a song from the list or preview/stop previewing the current song"
msg.COMMAND_PREVIEW_OLD = "Load and preview a song from the list or preview the current song"
msg.COMMAND_PREVIEW_PARAMS = "[ { **<song name>** || **<song #>** } ]"
msg.COMMAND_LIST = "Show song list"
msg.COMMAND_DELETE = "Delete a song from the list or delete the current song"
msg.COMMAND_DELETE_PARAMS = "[ { **<song name>** || **<song #>** } ]"
msg.COMMAND_RENAME = "Rename a song in the list or rename the current song"
msg.COMMAND_RENAME_PARAMS = "[ **<song #>** [ **<new name>** ] ]"
msg.COMMAND_FIND = "Find a song in the list"
msg.COMMAND_FIND_PARAMS = "**<song name>**"
msg.COMMAND_RESTORE_DEMO = "Restore demo songs"

--- Minimap button menu options
msg.MENU_LIST = "Song list"

--- Song list headers
msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "Title"
msg.HEADER_SONG_DURATION = "Time"
msg.HEADER_SONG_ACTIONS = "Actions"

--- Song actions
msg.ACTION_PLAY = "Load and play"
msg.ACTION_PREVIEW = "Load and preview"
msg.ACTION_LINK = "Post link in the chat"
msg.ACTION_RENAME = "Rename"
msg.ACTION_DELETE = "Delete"
msg.ACTION_SAVE = "Save in the list"

--- Popups
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
msg.DEMO_SONGS_RESTORED = "Demo songs have been restored."

--- Main UI
msg.SONG_LIST = "Song list"
msg.FILTER_SONG = "Filter"
msg.SONG_LIST_EMPTY = "Song list is empty."
msg.IMPORT_A_SONG = "Import a song"
msg.NO_SONG_FOUND = "No song found."
msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON = "Import song into the list"

--- Database update
msg.UPDATING_DB = "Updating MusicianList..."
msg.UPDATING_DB_COMPLETE = "MusicianList update complete."

--- Error messages
msg.ERR_OUTDATED_MUSICIAN_VERSION = "Your version of Musician is outdated and can't be used with MusicianList. Please update Musician addon."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "Your version of MusicianList is outdated and can no longer be used. Please update."
msg.ERR_NO_SONG_TO_SAVE = "No song to save."
msg.ERR_SONG_NAME_EMPTY = "Song name can't be empty."
msg.ERR_SONG_NOT_FOUND = "Song not found."
msg.ERR_CANNOT_SAVE_NOW = "Song cannot be saved for now."
msg.ERR_CANNOT_LOAD_NOW = "Song cannot be loaded for now."
