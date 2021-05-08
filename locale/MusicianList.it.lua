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

local msg = MusicianList.InitLocale("it", "Italiano", "itIT")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

--- Chat commands
msg.COMMAND_SAVE = "Salva il brano corrente nell'elenco"
msg.COMMAND_SAVE_PARAMS = "[** <nome del brano> **]"
msg.COMMAND_LOAD = "Carica una canzone dall'elenco"
msg.COMMAND_LOAD_PARAMS = "{** <nome del brano> ** || ** <song #> **}"
msg.COMMAND_PLAY = "Carica e riproduci un brano dall'elenco o riproduci / interrompi il brano corrente"
msg.COMMAND_PLAY_OLD = "Carica e riproduci un brano dall'elenco o riproduci il brano corrente"
msg.COMMAND_PLAY_PARAMS = "[{** <nome del brano> ** || ** <song #> **}]"
msg.COMMAND_PREVIEW = "Carica e visualizza in anteprima un brano dall'elenco o visualizza in anteprima / interrompi l'anteprima del brano corrente"
msg.COMMAND_PREVIEW_OLD = "Carica e visualizza l'anteprima di un brano dall'elenco o visualizza l'anteprima del brano corrente"
msg.COMMAND_PREVIEW_PARAMS = "[{** <nome del brano> ** || ** <song #> **}]"
msg.COMMAND_LIST = "Mostra l'elenco dei brani"
msg.COMMAND_DELETE = "Elimina un brano dall'elenco o elimina il brano corrente"
msg.COMMAND_DELETE_PARAMS = "[{** <nome del brano> ** || ** <song #> **}]"
msg.COMMAND_RENAME = "Rinomina un brano nell'elenco o rinomina il brano corrente"
msg.COMMAND_RENAME_PARAMS = "[** <song #> ** [** <new name> **]]"
msg.COMMAND_FIND = "Trova una canzone nell'elenco"
msg.COMMAND_FIND_PARAMS = "** <nome del brano> **"
msg.COMMAND_RESTORE_DEMO = "Ripristina brani demo"

--- Minimap button menu options
msg.MENU_LIST = "Lista delle canzoni"

--- Song list headers
msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "Titolo"
msg.HEADER_SONG_DURATION = "Tempo"
msg.HEADER_SONG_ACTIONS = "Azioni"

--- Song actions
msg.ACTION_PLAY = "Carica e gioca"
msg.ACTION_PREVIEW = "Carica e visualizza l'anteprima"
msg.ACTION_LINK = "Pubblica link nella chat"
msg.ACTION_RENAME = "Rinominare"
msg.ACTION_DELETE = "Elimina"
msg.ACTION_SAVE = "Salva nell'elenco"

--- Popups
msg.SAVE_SONG_AS = "Salva brano come:"
msg.RENAME_SONG = "Rinomina brano:"
msg.OVERWRITE_CONFIRM = "\"% s\" esiste già. Sovrascrivi?"
msg.SAVING_SONG = "Salvataggio di \"{name}\" ..."
msg.LOADING_SONG = "Caricamento di \"{name}\" ..."
msg.DONE_LOADING = "Caricamento fatto."
msg.DONE_SAVING = "Salvataggio completato."
msg.DELETE_CONFIRM = "Sei sicuro di voler eliminare \"% s\"?"
msg.SONG_DELETED = "\"{name}\" è stato eliminato."
msg.SONG_RENAMED = "\"{name}\" è stato rinominato in \"{newName}\"."
msg.DEMO_SONGS_RESTORED = "I brani dimostrativi sono stati ripristinati."

--- Main UI
msg.SONG_LIST = "Lista delle canzoni"
msg.FILTER_SONG = "Filtro"
msg.SONG_LIST_EMPTY = "L'elenco dei brani è vuoto."
msg.IMPORT_A_SONG = "Importa una canzone"
msg.NO_SONG_FOUND = "Nessun brano trovato."
msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON = "Importa la canzone nell'elenco"

--- Database update
msg.UPDATING_DB = "Aggiornamento dell'elenco dei musicisti in corso ..."
msg.UPDATING_DB_COMPLETE = "Aggiornamento MusicianList completato."

--- Error messages
msg.ERR_OUTDATED_MUSICIAN_VERSION = "La tua versione di Musician è obsoleta e non può essere utilizzata con MusicianList. Aggiorna il componente aggiuntivo Musician."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "La tua versione di MusicianList è obsoleta e non può più essere utilizzata. Per favore aggiornare."
msg.ERR_NO_SONG_TO_SAVE = "Nessuna canzone da salvare."
msg.ERR_SONG_NAME_EMPTY = "Il nome del brano non può essere vuoto."
msg.ERR_SONG_NOT_FOUND = "Canzone non trovata."
msg.ERR_CANNOT_SAVE_NOW = "La canzone non può essere salvata per ora."
msg.ERR_CANNOT_LOAD_NOW = "La canzone non può essere caricata per ora."
