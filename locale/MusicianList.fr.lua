MusicianList.Locale.fr = Musician.Utils.DeepCopy(MusicianList.Locale.en)
local msg = MusicianList.Locale.fr

msg.COMMAND_SAVE = "Enregistrer le morceau actuel dans la liste"
msg.COMMAND_SAVE_PARAMS = "[ **<nom morceau>** ]"
msg.COMMAND_LOAD = "Charger un morceau depuis la liste"
msg.COMMAND_LOAD_PARAMS = "{ **<nom morceau>** || **<n° morceau>** }"
msg.COMMAND_PLAY = "Charger et jouer un morceau de la liste ou jouer/arrêter le morceau actuel"
msg.COMMAND_PLAY_OLD = "Charger et jouer un morceau de la liste ou jouer le morceau actuel"
msg.COMMAND_PLAY_PARAMS = "[ { **<nom morceau>** || **<n° morceau>** } ]"
msg.COMMAND_PREVIEW = "Charger et écouter un aperçu d'un morceau de la liste ou jouer/arrêter l'aperçu du morceau actuel"
msg.COMMAND_PREVIEW_OLD = "Charger et écouter un aperçu d'un morceau de la liste ou aperçu du morceau actuel"
msg.COMMAND_PREVIEW_PARAMS = "[ { **<nom morceau>** || **<n° morceau>** } ]"
msg.COMMAND_LIST = "Afficher la liste des morceaux"
msg.COMMAND_DELETE = "Supprimer un morceau de la liste ou supprimer le morceau actuel"
msg.COMMAND_DELETE_PARAMS = "[ { **<nom morceau>** || **<n° morceau>** } ]"
msg.COMMAND_RENAME = "Renommer un morceau de la liste ou renommer le morceau actuel"
msg.COMMAND_RENAME_PARAMS = "[ **<n° morceau>** [ **<nouveau nom>** ] ]"
msg.COMMAND_FIND = "Chercher un morceau dans la liste"
msg.COMMAND_FIND_PARAMS = "**<nom morceau>**"
msg.COMMAND_RESTORE_DEMO = "Restaurer les morceaux de démonstration"

msg.MENU_LIST = "Liste des morceaux"

msg.HEADER_SONG_INDEX = "N°"
msg.HEADER_SONG_TITLE = "Titre"
msg.HEADER_SONG_DURATION = "Durée"
msg.HEADER_SONG_ACTIONS = "Actions"

msg.ACTION_PLAY = "Charger et jouer"
msg.ACTION_PREVIEW = "Charger et aperçu"
msg.ACTION_RENAME = "Renommer"
msg.ACTION_DELETE = "Supprimer"
msg.ACTION_SAVE = "Enregistrer dans la liste"

msg.SAVE_SONG_AS = "Enregistrer le morceau sous :"
msg.RENAME_SONG = "Renommer le morceau :"
msg.OVERWRITE_CONFIRM = "\"%s\" existe déjà. Écraser ?"
msg.SAVING_SONG = "Enregistrement de \"{name}\"…"
msg.LOADING_SONG = "Chargement de \"{name}\"…"
msg.DONE_LOADING = "Chargement terminé."
msg.DONE_SAVING = "Enregistrement terminé."
msg.DELETE_CONFIRM = "Êtes vous sûr(e) de vouloir supprimer \"%s\" ?"
msg.SONG_DELETED = "\"{name}\" a été supprimé."
msg.SONG_RENAMED = "\"{name}\" a été renommé en \"{newName}\"."
msg.DEMO_SONGS_RESTORED = "Les morceaux de démonstration ont été restaurés."

msg.SONG_LIST = "Liste des morceaux"
msg.FILTER_SONG = "Filtrer"
msg.SONG_LIST_EMPTY = "La liste de morceaux est vide."
msg.IMPORT_A_SONG = "Importer un morceau"
msg.NO_SONG_FOUND = "Aucun morceau trouvé."

msg.UPDATING_DB = "Mise à jour de MusicianList..."
msg.UPDATING_DB_COMPLETE = "Mise à jour de MusicianList terminée."

msg.ERR_OUTDATED_MUSICIAN_VERSION = "Votre version de Musician est obsolète et ne peut pas être utilisée avec MusicianList. Mettez à jour l'add-on Musician."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "Votre version de MusicianList est obsolète et ne peut plus être utilisée. Veuillez la mettre à jour."
msg.ERR_NO_SONG_TO_SAVE = "Aucun morceau à enregistrer."
msg.ERR_SONG_NAME_EMPTY = "Le nom du morceau ne peut être vide."
msg.ERR_SONG_NOT_FOUND = "Morceau non trouvé."
msg.ERR_CANNOT_SAVE_NOW = "Le morceau ne peut pas être enregistré pour le moment."
msg.ERR_CANNOT_LOAD_NOW = "Le morceau ne peut pas être chargé pour le moment."

if ( GetLocale() == "frFR" ) then
	MusicianList.Msg = msg
end
