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
msg.COMMAND_SAVE = "Сохранить текущую песню в списке"
msg.COMMAND_SAVE_PARAMS = "[** <название песни> **]"
msg.COMMAND_LOAD = "Загрузить песню из списка"
msg.COMMAND_LOAD_PARAMS = "{** <название песни> ** || ** <песня №> **}"
msg.COMMAND_PLAY = "Загрузите и воспроизведите песню из списка или воспроизведите / остановите текущую песню"
msg.COMMAND_PLAY_OLD = "Загрузите и воспроизведите песню из списка или воспроизведите текущую песню"
msg.COMMAND_PLAY_PARAMS = "[{** <название песни> ** || ** <песня №> **}]"
msg.COMMAND_PREVIEW = "Загрузка и предварительный просмотр песни из списка или предварительный просмотр / остановка предварительного просмотра текущей песни"
msg.COMMAND_PREVIEW_OLD = "Загрузка и предварительный просмотр песни из списка или предварительный просмотр текущей песни"
msg.COMMAND_PREVIEW_PARAMS = "[{** <название песни> ** || ** <песня №> **}]"
msg.COMMAND_LIST = "Показать список песен"
msg.COMMAND_DELETE = "Удалить песню из списка или удалить текущую песню"
msg.COMMAND_DELETE_PARAMS = "[{** <название песни> ** || ** <песня №> **}]"
msg.COMMAND_RENAME = "Переименовать песню в списке или переименовать текущую песню"
msg.COMMAND_RENAME_PARAMS = "[** <песня №> ** [** <новое название> **]]"
msg.COMMAND_FIND = "Найдите песню в списке"
msg.COMMAND_FIND_PARAMS = "** <название песни> **"
msg.COMMAND_RESTORE_DEMO = "Восстановить демо-песни"

--- Minimap button menu options
msg.MENU_LIST = "Список песен"

--- Song list headers
msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "Заголовок"
msg.HEADER_SONG_DURATION = "Время"
msg.HEADER_SONG_ACTIONS = "Действия"

--- Song actions
msg.ACTION_PLAY = "Загрузи и играй"
msg.ACTION_PREVIEW = "Загрузить и просмотреть"
msg.ACTION_LINK = "Опубликовать ссылку в чате"
msg.ACTION_RENAME = "Переименовать"
msg.ACTION_DELETE = "Удалить"
msg.ACTION_SAVE = "Сохранить в списке"

--- Popups
msg.SAVE_SONG_AS = "Сохранить песню как:"
msg.RENAME_SONG = "Переименовать песню:"
msg.OVERWRITE_CONFIRM = "\"% s\" уже существует. Перезаписать?"
msg.SAVING_SONG = "Сохранение \"{name}\"…"
msg.LOADING_SONG = "Загрузка \"{name}\"…"
msg.DONE_LOADING = "Загрузка завершена."
msg.DONE_SAVING = "Готово сохранение."
msg.DELETE_CONFIRM = "Вы уверены, что хотите удалить \"% s\"?"
msg.SONG_DELETED = "\"{name}\" удалено."
msg.SONG_RENAMED = "\"{name}\" было переименовано в \"{newName}\"."
msg.DEMO_SONGS_RESTORED = "Восстановлены демо-композиции."

--- Main UI
msg.SONG_LIST = "Список песен"
msg.FILTER_SONG = "Фильтр"
msg.SONG_LIST_EMPTY = "Список песен пуст."
msg.IMPORT_A_SONG = "Импортировать песню"
msg.NO_SONG_FOUND = "Песня не найдена."
msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON = "Импортировать песню в список"

--- Database update
msg.UPDATING_DB = "Обновление списка музыкантов ..."
msg.UPDATING_DB_COMPLETE = "Обновление списка музыкантов завершено."

--- Error messages
msg.ERR_OUTDATED_MUSICIAN_VERSION = "Ваша версия Musician устарела и не может использоваться с MusicianList. Пожалуйста, обновите аддон \"Музыкант\"."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "Ваша версия MusicianList устарела и больше не может использоваться. Пожалуйста обновите."
msg.ERR_NO_SONG_TO_SAVE = "Нет песни для сохранения."
msg.ERR_SONG_NAME_EMPTY = "Название песни не может быть пустым."
msg.ERR_SONG_NOT_FOUND = "Песня не найдена."
msg.ERR_CANNOT_SAVE_NOW = "Песню пока нельзя сохранить."
msg.ERR_CANNOT_LOAD_NOW = "Песня пока не может быть загружена."
