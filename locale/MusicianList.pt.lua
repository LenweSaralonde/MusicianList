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

local msg = MusicianList.InitLocale("pt", "Português", "ptBR")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

--- Chat commands
msg.COMMAND_SAVE = "Salve a música atual na lista"
msg.COMMAND_SAVE_PARAMS = "[** <nome da música> **]"
msg.COMMAND_LOAD = "Carregue uma música da lista"
msg.COMMAND_LOAD_PARAMS = "{** <nome da música> ** || ** <música #> **}"
msg.COMMAND_PLAY = "Carregue e reproduza uma música da lista ou reproduza / pare a música atual"
msg.COMMAND_PLAY_OLD = "Carregue e reproduza uma música da lista ou toque a música atual"
msg.COMMAND_PLAY_PARAMS = "[{** <nome da música> ** || ** <música #> **}]"
msg.COMMAND_PREVIEW = "Carregue e pré-visualize uma música da lista ou pré-visualize / pare de pré-visualizar a música atual"
msg.COMMAND_PREVIEW_OLD = "Carregue e visualize uma música da lista ou visualize a música atual"
msg.COMMAND_PREVIEW_PARAMS = "[{** <nome da música> ** || ** <música #> **}]"
msg.COMMAND_LIST = "Mostrar lista de músicas"
msg.COMMAND_DELETE = "Exclua uma música da lista ou exclua a música atual"
msg.COMMAND_DELETE_PARAMS = "[{** <nome da música> ** || ** <música #> **}]"
msg.COMMAND_RENAME = "Renomeie uma música da lista ou renomeie a música atual"
msg.COMMAND_RENAME_PARAMS = "[** <música #> ** [** <novo nome> **]]"
msg.COMMAND_FIND = "Encontre uma música na lista"
msg.COMMAND_FIND_PARAMS = "** <nome da música> **"
msg.COMMAND_RESTORE_DEMO = "Restaurar músicas de demonstração"

--- Minimap button menu options
msg.MENU_LIST = "Lista de musicas"

--- Song list headers
msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "Título"
msg.HEADER_SONG_DURATION = "Tempo"
msg.HEADER_SONG_ACTIONS = "Ações"

--- Song actions
msg.ACTION_PLAY = "Carregue e jogue"
msg.ACTION_PREVIEW = "Carregar e visualizar"
msg.ACTION_LINK = "Postar link no chat"
msg.ACTION_RENAME = "Renomear"
msg.ACTION_DELETE = "Excluir"
msg.ACTION_SAVE = "Salvar na lista"

--- Popups
msg.SAVE_SONG_AS = "Salvar música como:"
msg.RENAME_SONG = "Renomear música:"
msg.OVERWRITE_CONFIRM = "\"% s\" já existe. Substituir?"
msg.SAVING_SONG = "Salvando \"{name}\"…"
msg.LOADING_SONG = "Carregando \"{name}\"…"
msg.DONE_LOADING = "Carregamento completo."
msg.DONE_SAVING = "Concluído o salvamento."
msg.DELETE_CONFIRM = "Tem certeza de que deseja excluir \"% s\"?"
msg.SONG_DELETED = "\"{name}\" foi excluído."
msg.SONG_RENAMED = "\"{name}\" foi renomeado para \"{newName}\"."
msg.DEMO_SONGS_RESTORED = "As músicas de demonstração foram restauradas."

--- Main UI
msg.SONG_LIST = "Lista de musicas"
msg.FILTER_SONG = "Filtro"
msg.SONG_LIST_EMPTY = "A lista de músicas está vazia."
msg.IMPORT_A_SONG = "Importar uma música"
msg.NO_SONG_FOUND = "Nenhuma música encontrada."
msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON = "Importar música para a lista"

--- Database update
msg.UPDATING_DB = "Atualizando MusicianList ..."
msg.UPDATING_DB_COMPLETE = "Atualização de MusicianList concluída."

--- Error messages
msg.ERR_OUTDATED_MUSICIAN_VERSION = "Sua versão de Musician está desatualizada e não pode ser usada com MusicianList. Atualize o complemento Musician."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "Sua versão de MusicianList está desatualizada e não pode mais ser usada. Por favor atualize."
msg.ERR_NO_SONG_TO_SAVE = "Nenhuma música para salvar."
msg.ERR_SONG_NAME_EMPTY = "O nome da música não pode estar vazio."
msg.ERR_SONG_NOT_FOUND = "Música não encontrada."
msg.ERR_CANNOT_SAVE_NOW = "A música não pode ser salva por enquanto."
msg.ERR_CANNOT_LOAD_NOW = "A música não pode ser carregada por enquanto."
