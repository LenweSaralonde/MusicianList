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

local msg = MusicianList.InitLocale("de", "Deutsch", "deDE")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

--- Chat commands
msg.COMMAND_SAVE = "Speicher das aktuelle Lied in der Liste"
msg.COMMAND_SAVE_PARAMS = "[** <Liedname> **]"
msg.COMMAND_LOAD = "Lade ein Lied aus der Liste"
msg.COMMAND_LOAD_PARAMS = "{** <Liedname> ** || ** <song #> **}"
msg.COMMAND_PLAY = "Lade oder speichere ein Lied aus der Liste / stoppe das aktuelle Lied"
msg.COMMAND_PLAY_OLD = "Lade oder speichere ein Lied aus der Liste oder spiele ein neues Lied ab"
msg.COMMAND_PLAY_PARAMS = "[{** <Liedname> ** || ** <song #> **}]"
msg.COMMAND_PREVIEW = "Laden und Vorschau eines Songs aus der Liste oder Vorschau / Beenden der Vorschau des aktuellen Songs"
msg.COMMAND_PREVIEW_OLD = "Laden ein Lied aus der Liste und zeige die Vorschau an, oder zeige eine Vorschau des aktuellen Liedes an"
msg.COMMAND_PREVIEW_PARAMS = "[{** <Liedname> ** || ** <song #> **}]"
msg.COMMAND_LIST = "Songliste anzeigen"
msg.COMMAND_DELETE = "Lösche ein Lied aus der Liste oder lösche das aktuelle Lied"
msg.COMMAND_DELETE_PARAMS = "[{** <Liedname> ** || ** <song #> **}]"
msg.COMMAND_RENAME = "Benenne ein Lied in der Liste um oder benenne das aktuelle Lied um"
msg.COMMAND_RENAME_PARAMS = "[** <song #> ** [** <neuer Name> **]]"
msg.COMMAND_FIND = "Finde ein Lied in der Liste"
msg.COMMAND_FIND_PARAMS = "** <Liedname> **"
msg.COMMAND_RESTORE_DEMO = "Demo Lieder wiederherstellen."

--- Minimap button menu options
msg.MENU_LIST = "Lieder Liste"

--- Song list headers
msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "Titel"
msg.HEADER_SONG_DURATION = "Zeit"
msg.HEADER_SONG_ACTIONS = "Aktionen"

--- Song actions
msg.ACTION_PLAY = "Laden und spielen"
msg.ACTION_PREVIEW = "Laden und Vorschau"
msg.ACTION_LINK = "Link im Chat posten"
msg.ACTION_RENAME = "Umbenennen"
msg.ACTION_DELETE = "Löschen"
msg.ACTION_SAVE = "Lied in Liste speichern"

--- Popups
msg.SAVE_SONG_AS = "Song speichern unter:"
msg.RENAME_SONG = "Lied umbenennen:"
msg.OVERWRITE_CONFIRM = "\"% s\" existiert bereits. Überschreiben?"
msg.SAVING_SONG = "Speichern von \"{name}\" ..."
msg.LOADING_SONG = "Laden von \"{name}\" ..."
msg.DONE_LOADING = "Laden beendet."
msg.DONE_SAVING = "Fertig speichern."
msg.DELETE_CONFIRM = "Bist du sicher dass du \"% s\" löschen möchten?"
msg.SONG_DELETED = "\"{name}\" wurde gelöscht."
msg.SONG_RENAMED = "\"{name}\" wurde in \"{newName}\" umbenannt."
msg.DEMO_SONGS_RESTORED = "Demo-Songs wurden wiederhergestellt."

--- Main UI
msg.SONG_LIST = "Lieder Liste"
msg.FILTER_SONG = "Filter"
msg.SONG_LIST_EMPTY = "Die Songliste ist leer."
msg.IMPORT_A_SONG = "Importiere ein Lied"
msg.NO_SONG_FOUND = "Kein Lied gefunden."
msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON = "Song in die Liste importieren"

--- Database update
msg.UPDATING_DB = "Aktualisieren der MusicianList ..."
msg.UPDATING_DB_COMPLETE = "MusicianList Update abgeschlossen."

--- Error messages
msg.ERR_OUTDATED_MUSICIAN_VERSION = "Deine Version von Musician ist veraltet und kann nicht mit MusicianList verwendet werden. Aktualisiere bitte Musician."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "Deine Version von MusicianList ist veraltet und kann nicht mehr verwendet werden. Bitte aktualisieren."
msg.ERR_NO_SONG_TO_SAVE = "Kein Lied zum Speichern."
msg.ERR_SONG_NAME_EMPTY = "Der Songname darf nicht leer sein."
msg.ERR_SONG_NOT_FOUND = "Lied wurde nicht gefunden."
msg.ERR_CANNOT_SAVE_NOW = "Song kann vorerst nicht gespeichert werden."
msg.ERR_CANNOT_LOAD_NOW = "Song kann vorerst nicht geladen werden."
