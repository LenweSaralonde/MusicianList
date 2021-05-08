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

local msg = MusicianList.InitLocale("es", "Español", "esES", "esMX")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

--- Chat commands
msg.COMMAND_SAVE = "Guarda la canción actual en la lista"
msg.COMMAND_SAVE_PARAMS = "[** <nombre de la canción> **]"
msg.COMMAND_LOAD = "Cargar una canción de la lista"
msg.COMMAND_LOAD_PARAMS = "{** <nombre de la canción> ** || ** <número de canción> **}"
msg.COMMAND_PLAY = "Cargue y reproduzca una canción de la lista o reproduzca / detenga la canción actual"
msg.COMMAND_PLAY_OLD = "Cargue y reproduzca una canción de la lista o reproduzca la canción actual"
msg.COMMAND_PLAY_PARAMS = "[{** <nombre de la canción> ** || ** <número de canción> **}]"
msg.COMMAND_PREVIEW = "Cargar y previsualizar una canción de la lista o previsualizar / dejar de previsualizar la canción actual"
msg.COMMAND_PREVIEW_OLD = "Cargue y obtenga una vista previa de una canción de la lista o una vista previa de la canción actual"
msg.COMMAND_PREVIEW_PARAMS = "[{** <nombre de la canción> ** || ** <número de canción> **}]"
msg.COMMAND_LIST = "Mostrar lista de canciones"
msg.COMMAND_DELETE = "Eliminar una canción de la lista o eliminar la canción actual"
msg.COMMAND_DELETE_PARAMS = "[{** <nombre de la canción> ** || ** <número de canción> **}]"
msg.COMMAND_RENAME = "Cambiar el nombre de una canción en la lista o cambiar el nombre de la canción actual"
msg.COMMAND_RENAME_PARAMS = "[** <número de canción> ** [** <nombre nuevo> **]]"
msg.COMMAND_FIND = "Encuentra una canción en la lista"
msg.COMMAND_FIND_PARAMS = "** <nombre de la canción> **"
msg.COMMAND_RESTORE_DEMO = "Restaurar canciones de demostración"

--- Minimap button menu options
msg.MENU_LIST = "Lista de canciones"

--- Song list headers
msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "Título"
msg.HEADER_SONG_DURATION = "Hora"
msg.HEADER_SONG_ACTIONS = "Comportamiento"

--- Song actions
msg.ACTION_PLAY = "Cargar y jugar"
msg.ACTION_PREVIEW = "Cargar y previsualizar"
msg.ACTION_LINK = "Publicar enlace en el chat"
msg.ACTION_RENAME = "Rebautizar"
msg.ACTION_DELETE = "Borrar"
msg.ACTION_SAVE = "Guardar en la lista"

--- Popups
msg.SAVE_SONG_AS = "Guardar canción como:"
msg.RENAME_SONG = "Cambiar el nombre de la canción:"
msg.OVERWRITE_CONFIRM = "\"% s\" ya existe. ¿Sobrescribir?"
msg.SAVING_SONG = "Guardando \"{name}\"…"
msg.LOADING_SONG = "Cargando \"{name}\"…"
msg.DONE_LOADING = "Terminado de cargar."
msg.DONE_SAVING = "Terminé de guardar."
msg.DELETE_CONFIRM = "¿Está seguro de que desea eliminar \"% s\"?"
msg.SONG_DELETED = "\"{name}\" se ha eliminado."
msg.SONG_RENAMED = "Se ha cambiado el nombre de \"{name}\" a \"{newName}\"."
msg.DEMO_SONGS_RESTORED = "Se han restaurado las canciones de demostración."

--- Main UI
msg.SONG_LIST = "Lista de canciones"
msg.FILTER_SONG = "Filtrar"
msg.SONG_LIST_EMPTY = "La lista de canciones está vacía."
msg.IMPORT_A_SONG = "Importar una cancion"
msg.NO_SONG_FOUND = "No se encontró ninguna canción."
msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON = "Importar canción a la lista"

--- Database update
msg.UPDATING_DB = "Actualizando MusicianList ..."
msg.UPDATING_DB_COMPLETE = "Actualización de MusicianList completa."

--- Error messages
msg.ERR_OUTDATED_MUSICIAN_VERSION = "Tu versión de Musician está desactualizada y no se puede usar con MusicianList. Actualiza el complemento Musician."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "Su versión de MusicianList está desactualizada y ya no se puede utilizar. Por favor actualice."
msg.ERR_NO_SONG_TO_SAVE = "No hay canción para guardar."
msg.ERR_SONG_NAME_EMPTY = "El nombre de la canción no puede estar vacío."
msg.ERR_SONG_NOT_FOUND = "Canción no encontrada."
msg.ERR_CANNOT_SAVE_NOW = "La canción no se puede guardar por ahora."
msg.ERR_CANNOT_LOAD_NOW = "La canción no se puede cargar por ahora."
