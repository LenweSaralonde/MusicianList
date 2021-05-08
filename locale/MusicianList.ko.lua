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

local msg = MusicianList.InitLocale("ko", "한국어", "koKR")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

--- Chat commands
msg.COMMAND_SAVE = "목록에 현재 노래 저장"
msg.COMMAND_SAVE_PARAMS = "[** <노래 이름> **]"
msg.COMMAND_LOAD = "목록에서 노래 불러 오기"
msg.COMMAND_LOAD_PARAMS = "{** <노래 이름> ** || ** <노래 #> **}"
msg.COMMAND_PLAY = "목록에서 노래를로드 및 재생하거나 현재 노래를 재생 / 중지합니다."
msg.COMMAND_PLAY_OLD = "목록에서 노래를로드 및 재생하거나 현재 노래를 재생합니다."
msg.COMMAND_PLAY_PARAMS = "[{** <노래 이름> ** || ** <노래 #> **}]"
msg.COMMAND_PREVIEW = "목록에서 노래로드 및 미리보기 또는 현재 노래 미리보기 / 중지"
msg.COMMAND_PREVIEW_OLD = "목록에서 노래로드 및 미리보기 또는 현재 노래 미리보기"
msg.COMMAND_PREVIEW_PARAMS = "[{** <노래 이름> ** || ** <노래 #> **}]"
msg.COMMAND_LIST = "노래 목록보기"
msg.COMMAND_DELETE = "목록에서 노래를 삭제하거나 현재 노래를 삭제합니다."
msg.COMMAND_DELETE_PARAMS = "[{** <노래 이름> ** || ** <노래 #> **}]"
msg.COMMAND_RENAME = "목록에서 노래 이름 변경 또는 현재 노래 이름 변경"
msg.COMMAND_RENAME_PARAMS = "[** <노래 #> ** [** <새 이름> **]]"
msg.COMMAND_FIND = "목록에서 노래 찾기"
msg.COMMAND_FIND_PARAMS = "** <노래 이름> **"
msg.COMMAND_RESTORE_DEMO = "데모 곡 복원"

--- Minimap button menu options
msg.MENU_LIST = "노래 목록"

--- Song list headers
msg.HEADER_SONG_INDEX = "#"
msg.HEADER_SONG_TITLE = "표제"
msg.HEADER_SONG_DURATION = "시각"
msg.HEADER_SONG_ACTIONS = "행위"

--- Song actions
msg.ACTION_PLAY = "로드 앤 플레이"
msg.ACTION_PREVIEW = "로드 및 미리보기"
msg.ACTION_LINK = "채팅에 링크 게시"
msg.ACTION_RENAME = "이름 바꾸기"
msg.ACTION_DELETE = "지우다"
msg.ACTION_SAVE = "목록에 저장"

--- Popups
msg.SAVE_SONG_AS = "다음으로 노래 저장 :"
msg.RENAME_SONG = "노래 이름 변경 :"
msg.OVERWRITE_CONFIRM = "\"% s\"이 (가) 이미 존재합니다. 덮어 쓰시겠습니까?"
msg.SAVING_SONG = "\"{name}\"저장 중…"
msg.LOADING_SONG = "\"{name}\"로드 중…"
msg.DONE_LOADING = "로딩 완료."
msg.DONE_SAVING = "저장 완료."
msg.DELETE_CONFIRM = "\"% s\"을 (를) 삭제 하시겠습니까?"
msg.SONG_DELETED = "\"{name}\"이 삭제되었습니다."
msg.SONG_RENAMED = "\"{name}\"의 이름이 \"{newName}\"으로 변경되었습니다."
msg.DEMO_SONGS_RESTORED = "데모 곡이 복원되었습니다."

--- Main UI
msg.SONG_LIST = "노래 목록"
msg.FILTER_SONG = "필터"
msg.SONG_LIST_EMPTY = "노래 목록이 비어 있습니다."
msg.IMPORT_A_SONG = "노래 가져 오기"
msg.NO_SONG_FOUND = "노래가 없습니다."
msg.LINK_IMPORT_WINDOW_IMPORT_BUTTON = "목록으로 노래 가져 오기"

--- Database update
msg.UPDATING_DB = "MusicianList 업데이트 중 ..."
msg.UPDATING_DB_COMPLETE = "MusicianList 업데이트가 완료되었습니다."

--- Error messages
msg.ERR_OUTDATED_MUSICIAN_VERSION = "사용중인 Musician 버전이 오래되어 MusicianList와 함께 사용할 수 없습니다. Musician 애드온을 업데이트하십시오."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "MusicianList의 버전이 오래되어 더 이상 사용할 수 없습니다. 업데이트하십시오."
msg.ERR_NO_SONG_TO_SAVE = "저장할 노래가 없습니다."
msg.ERR_SONG_NAME_EMPTY = "노래 이름은 비워 둘 수 없습니다."
msg.ERR_SONG_NOT_FOUND = "노래를 찾을 수 없습니다."
msg.ERR_CANNOT_SAVE_NOW = "지금은 노래를 저장할 수 없습니다."
msg.ERR_CANNOT_LOAD_NOW = "지금은 노래를로드 할 수 없습니다."
