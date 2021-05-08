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

local msg = MusicianList.InitLocale("ru", "Русский", "ruRU")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

--- Chat commands
msg.COMMAND_SAVE = "Сохраните текущую песню в списке"
msg.COMMAND_SAVE_PARAMS = "[ **<название песни>** ]"
msg.COMMAND_LOAD = "Загрузите песню из списка"
msg.COMMAND_LOAD_PARAMS = "{ **<название песни>** || **<песня #>** }"
msg.COMMAND_PLAY = "Загрузка и воспроизведение песни из списка или воспроизведение/остановка текущей песни"
msg.COMMAND_PLAY_OLD = "Загрузить и воспроизвести песню из списка или воспроизведения текущей песни"
msg.COMMAND_PLAY_PARAMS = "[ { **<название песни>** || **<песня #>** } ]"
msg.COMMAND_PREVIEW = "Загрузка и предварительный просмотр песни из списка или предварительный просмотр/остановка предварительного просмотра текущей песни"
msg.COMMAND_PREVIEW_OLD = "Загрузка и предварительный просмотр песни из списка или предварительный просмотр текущей песни"
msg.COMMAND_PREVIEW_PARAMS = "[ { **<название песни>** || **<песня #>** } ]"
msg.COMMAND_LIST = "Показать список песен"
msg.COMMAND_DELETE = "Удалите песню из списка или удалите текущую песню"
msg.COMMAND_DELETE_PARAMS = "[ { **<название песни>** || **<песня #>** } ]"
msg.COMMAND_RENAME = "Переименуйте песню в списке или переименуйте текущую песню"
msg.COMMAND_RENAME_PARAMS = "[ **<песня #>** [ **<новое название>** ] ]"
msg.COMMAND_FIND = "Найдите песню в списке"
msg.COMMAND_FIND_PARAMS = "**<название песни>**"
msg.COMMAND_RESTORE_DEMO = "Восстановление демо-песен"

--- Minimap button menu options
msg.MENU_LIST = "Список песен"

--- Song list headers
msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "Заголовок"
msg.HEADER_SONG_DURATION = "Время"
msg.HEADER_SONG_ACTIONS = "Действия"

--- Song actions
msg.ACTION_PLAY = "Загрузка и прослушивание"
msg.ACTION_PREVIEW = "Загрузка и предварительный просмотр"
msg.ACTION_LINK = "Опубликовать ссылку в чате"
msg.ACTION_RENAME = "Переименовать"
msg.ACTION_DELETE = "Удалить"
msg.ACTION_SAVE = "Сохранить в списке"

--- Popups
msg.SAVE_SONG_AS = "Сохранить песню как:"
msg.RENAME_SONG = "Переименовать песню:"
msg.OVERWRITE_CONFIRM = "\"%s\" уже существует. Переписать?"
msg.SAVING_SONG = "Сохранить \"{name}\"…"
msg.LOADING_SONG = "Загрузить \"{name}\"…"
msg.DONE_LOADING = "Закончена загрузка."
msg.DONE_SAVING = "Закончено сохранение."
msg.DELETE_CONFIRM = "Вы уверены, что хотите удалить его \"%s\"?"
msg.SONG_DELETED = "\"{name}\" был удален."
msg.SONG_RENAMED = "\"{name}\" был переименован в \"{newName}\"."
msg.DEMO_SONGS_RESTORED = "Демо песни были восстановлены."

--- Main UI
msg.SONG_LIST = "Список песен"
msg.FILTER_SONG = "Фильтр"
msg.SONG_LIST_EMPTY = "Список песен пуст."
msg.IMPORT_A_SONG = "Импорт песни"
msg.NO_SONG_FOUND = "Песня не найдена."
msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON = "Импортировать песню в список"

--- Database update
msg.UPDATING_DB = "Обновление MusicianList..."
msg.UPDATING_DB_COMPLETE = "MusicianList обновление завершено."

--- Error messages
msg.ERR_OUTDATED_MUSICIAN_VERSION = "Ваша версия Musician устарела и не может быть использована вместе с MusicianList. Пожалуйста, обновите аддон Musician."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "Ваша версия MusicianList устарела и больше не может быть использована. Пожалуйста, обновите аддон."
msg.ERR_NO_SONG_TO_SAVE = "Нет песни, чтобы сохранить."
msg.ERR_SONG_NAME_EMPTY = "Название песни не может быть пустым."
msg.ERR_SONG_NOT_FOUND = "Песня не найдена."
msg.ERR_CANNOT_SAVE_NOW = "Песня не может быть сохранена на данный момент."
msg.ERR_CANNOT_LOAD_NOW = "Песня пока не может быть загружена."
