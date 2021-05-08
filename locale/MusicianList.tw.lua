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

local msg = MusicianList.InitLocale("tw", "繁體中文", "zhTW")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

--- Chat commands
msg.COMMAND_SAVE = "將當前音樂保存進播放列表"
msg.COMMAND_SAVE_PARAMS = "[ **<音樂名>** ]"
msg.COMMAND_LOAD = "載入播放列表中的音樂"
msg.COMMAND_LOAD_PARAMS = "{ **<音樂名>** || **<音樂編號>** }"
msg.COMMAND_PLAY = "從播放列表中載入並播放音樂或播放/停止當前音樂"
msg.COMMAND_PLAY_OLD = "從播放列表中載入並播放音樂或播放當前音樂"
msg.COMMAND_PLAY_PARAMS = "[ { **<音樂名>** || **<音樂編號>** } ]"
msg.COMMAND_PREVIEW = "從播放列表中載入並預覽音樂或預覽/停止預覽當前音樂"
msg.COMMAND_PREVIEW_OLD = "從播放列表中載入並預覽音樂或預覽當前音樂"
msg.COMMAND_PREVIEW_PARAMS = "[ { **<音樂名>** || **<音樂編號>** } ]"
msg.COMMAND_LIST = "顯示播放列表"
msg.COMMAND_DELETE = "從播放列表中刪除音樂或刪除當前音樂"
msg.COMMAND_DELETE_PARAMS = "[ { **<音樂名>** || **<音樂編號>** } ]"
msg.COMMAND_RENAME = "重命名播放列表中的音樂或刪除當前音樂"
msg.COMMAND_RENAME_PARAMS = "[ **<音樂編號>** [ **<新名稱>** ] ]"
msg.COMMAND_FIND = "在播放列表中查找音樂"
msg.COMMAND_FIND_PARAMS = "**<音樂名>**"
msg.COMMAND_RESTORE_DEMO = "恢復示例音樂"

--- Minimap button menu options
msg.MENU_LIST = "播放列表"

--- Song list headers
msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "標題"
msg.HEADER_SONG_DURATION = "時間"
msg.HEADER_SONG_ACTIONS = "動作"

--- Song actions
msg.ACTION_PLAY = "載入並播放"
msg.ACTION_PREVIEW = "載入並預覽"
msg.ACTION_LINK = "將鏈接粘貼到聊天框"
msg.ACTION_RENAME = "重命名"
msg.ACTION_DELETE = "刪除"
msg.ACTION_SAVE = "保存到播放列表"

--- Popups
msg.SAVE_SONG_AS = "將音樂保存為："
msg.RENAME_SONG = "重命名音樂："
msg.OVERWRITE_CONFIRM = "\"%s\"已存在，覆蓋嗎？"
msg.SAVING_SONG = "正在保存 \"{name}\"…"
msg.LOADING_SONG = "正在載入 \"{name}\"…"
msg.DONE_LOADING = "載入完成。"
msg.DONE_SAVING = "保存完成"
msg.DELETE_CONFIRM = "你確定要刪除 \"%s\"嗎？"
msg.SONG_DELETED = "\"{name}\" 已被刪除。 ."
msg.SONG_RENAMED = "\"{name}\" 已被重命名為 \"{newName}\"。"
msg.DEMO_SONGS_RESTORED = "已恢復為示例音樂。"

--- Main UI
msg.SONG_LIST = "播放列表"
msg.FILTER_SONG = "過濾器"
msg.SONG_LIST_EMPTY = "播放列表為空。"
msg.IMPORT_A_SONG = "導入音樂"
msg.NO_SONG_FOUND = "沒有找到音樂"
msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON = "將音樂導入至歌單"

--- Database update
msg.UPDATING_DB = "MusicianList正在更新…"
msg.UPDATING_DB_COMPLETE = "MusicianList更新完成。"

--- Error messages
msg.ERR_OUTDATED_MUSICIAN_VERSION = "你的Musician已過期，不能和MusicianList一起使用，請升級你的Musician插件。"
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "你的MusicianList已過期並無法繼續使用，請升級。"
msg.ERR_NO_SONG_TO_SAVE = "沒有可以保存的音樂。"
msg.ERR_SONG_NAME_EMPTY = "音樂名不能為空。"
msg.ERR_SONG_NOT_FOUND = "沒有找到音樂。"
msg.ERR_CANNOT_SAVE_NOW = "音樂現在無法保存。"
msg.ERR_CANNOT_LOAD_NOW = "音樂現在無法載入。"
