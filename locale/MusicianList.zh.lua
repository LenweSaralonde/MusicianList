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

local msg = MusicianList.InitLocale("zh", "中文", "zhCN")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

--- Chat commands
msg.COMMAND_SAVE = "将当前音乐保存进播放列表"
msg.COMMAND_SAVE_PARAMS = "[ **<音乐名>** ]"
msg.COMMAND_LOAD = "载入播放列表中的音乐"
msg.COMMAND_LOAD_PARAMS = "{ **<音乐名>** || **<音乐编号>** }"
msg.COMMAND_PLAY = "从播放列表中载入并播放音乐或播放/停止当前音乐"
msg.COMMAND_PLAY_OLD = "从播放列表中载入并播放音乐或播放当前音乐"
msg.COMMAND_PLAY_PARAMS = "[ { **<音乐名>** || **<音乐编号>** } ]"
msg.COMMAND_PREVIEW = "从播放列表中载入并预览音乐或预览/停止预览当前音乐"
msg.COMMAND_PREVIEW_OLD = "从播放列表中载入并预览音乐或预览当前音乐"
msg.COMMAND_PREVIEW_PARAMS = "[ { **<音乐名>** || **<音乐编号>** } ]"
msg.COMMAND_LIST = "显示播放列表"
msg.COMMAND_DELETE = "从播放列表中删除音乐或删除当前音乐"
msg.COMMAND_DELETE_PARAMS = "[ { **<音乐名>** || **<音乐编号>** } ]"
msg.COMMAND_RENAME = "重命名播放列表中的音乐或删除当前音乐"
msg.COMMAND_RENAME_PARAMS = "[ **<音乐编号>** [ **<新名称>** ] ]"
msg.COMMAND_FIND = "在播放列表中查找音乐"
msg.COMMAND_FIND_PARAMS = "**<音乐名>**"
msg.COMMAND_RESTORE_DEMO = "恢复示例音乐"

--- Minimap button menu options
msg.MENU_LIST = "播放列表"

--- Song list headers
msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "标题"
msg.HEADER_SONG_DURATION = "时间"
msg.HEADER_SONG_ACTIONS = "动作"

--- Song actions
msg.ACTION_PLAY = "载入并播放"
msg.ACTION_PREVIEW = "载入并预览"
msg.ACTION_LINK = "将链接粘贴到聊天框"
msg.ACTION_RENAME = "重命名"
msg.ACTION_DELETE = "删除"
msg.ACTION_SAVE = "保存到播放列表"

--- Popups
msg.SAVE_SONG_AS = "将音乐保存为："
msg.RENAME_SONG = "重命名音乐："
msg.OVERWRITE_CONFIRM = "\"%s\"已存在，覆盖吗？"
msg.SAVING_SONG = "正在保存 \"{name}\"…"
msg.LOADING_SONG = "正在载入 \"{name}\"…"
msg.DONE_LOADING = "载入完成。"
msg.DONE_SAVING = "保存完成"
msg.DELETE_CONFIRM = "你确定要删除 \"%s\"吗？"
msg.SONG_DELETED = "\"{name}\" 已被删除。."
msg.SONG_RENAMED = "\"{name}\" 已被重命名为 \"{newName}\"。"
msg.DEMO_SONGS_RESTORED = "已恢复为示例音乐。"

--- Main UI
msg.SONG_LIST = "播放列表"
msg.FILTER_SONG = "过滤器"
msg.SONG_LIST_EMPTY = "播放列表为空。"
msg.IMPORT_A_SONG = "导入音乐"
msg.NO_SONG_FOUND = "没有找到音乐"
msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON = "将音乐导入至歌单"

--- Database update
msg.UPDATING_DB = "MusicianList正在更新…"
msg.UPDATING_DB_COMPLETE = "MusicianList更新完成。"

--- Error messages
msg.ERR_OUTDATED_MUSICIAN_VERSION = "你的Musician已过期，不能和MusicianList一起使用，请升级你的Musician插件。"
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "你的MusicianList已过期并无法继续使用，请升级。"
msg.ERR_NO_SONG_TO_SAVE = "没有可以保存的音乐。"
msg.ERR_SONG_NAME_EMPTY = "音乐名不能为空。"
msg.ERR_SONG_NOT_FOUND = "没有找到音乐。"
msg.ERR_CANNOT_SAVE_NOW = "音乐现在无法保存。"
msg.ERR_CANNOT_LOAD_NOW = "音乐现在无法载入。"
