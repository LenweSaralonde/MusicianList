MusicianList.LocaleBase = {}
local msg = MusicianList.LocaleBase

if Musician.LocalizationTeam then
	tAppendAll(Musician.LocalizationTeam, {
		{ 'de', Musician.DefaultTranslator },
		{ 'en', "LenweSaralonde" },
		{ 'es', Musician.DefaultTranslator },
		{ 'fr', "LenweSaralonde" },
		{ 'it', Musician.DefaultTranslator },
		{ 'ko', Musician.DefaultTranslator },
		{ 'pt', Musician.DefaultTranslator },
		{ 'ru', Musician.DefaultTranslator, "Hubbotu" },
		{ 'tw', Musician.DefaultTranslator },
		{ 'zh', "Grayson Blackclaw" },
	})
end