MusicianList.Locale.fr = Musician.Utils.DeepCopy(MusicianList.Locale.en)
local msg = MusicianList.Locale.fr

msg.SAVING_SONG = "Enregistrement de {name}..."
msg.LOADING_SONG = "Chargement de {name}..."
msg.DONE_LOADING = "Chargement terminé."
msg.DONE_SAVING = "Enregistrement terminé."
msg.SONG_DELETED = "{name} supprimé."
msg.NO_SONG = "Aucun morceau dans la liste."

msg.LINK_PLAY = "►"
msg.LINK_DELETE = "X"

msg.ERR_OUTDATED_MUSICIAN_VERSION = "Votre version de Musician est obsolète et ne peut pas être utilisée avec MusicianList. Mettez à jour l'add-on Musician."
msg.ERR_OUTDATED_MUSICIANLIST_VERSION = "Votre version de MusicianList est obsolète et ne peut plus être utilisée. Veuillez la mettre à jour."
msg.ERR_NO_SONG_TO_SAVE = "Aucun morceau à enregistrer."
msg.ERR_SONG_NOT_FOUND = "Morceau non trouvé."
msg.ERR_CANNOT_SAVE_NOW = "Le morceau ne peut pas être enregistré pour le moment."
msg.ERR_CANNOT_LOAD_NOW = "Le morceau ne peut pas être chargé pour le moment."

if ( GetLocale() == "frFR" ) then
	MusicianList.Msg = msg
end
