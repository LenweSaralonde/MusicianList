max_line_length = false

exclude_files = {}

ignore = {
	-- Ignore global writes/accesses/mutations on anything prefixed with "Musician".
	-- This is the standard prefix for all of our global frame names and mixins.
	"11./^Musician",

	-- Ignore unused self. This would popup for Mixins and Objects
	"212/self",

	-- Ignore unused event. This would popup for event handlers
	"212/event",
}

globals = {
	"Musician",
	"MusicianList",

	-- Globals

	-- AddOn Overrides
}

read_globals = {
	-- Libraries
	"LibStub",

	-- 3rd party add-ons
}

std = "lua51+wow"

stds.wow = {
	-- Globals that we mutate.
	globals = {
		"StaticPopupDialogs"
	},

	-- Globals that we access.
	read_globals = {
		-- Lua function aliases and extensions
		"strsplit",
		"strtrim",
		"strlower",
		"ceil",
		"floor",
		"min",
		"max",
		"abs",
		"tAppendAll",

		bit = {
			fields = {
				"bor"
			}
		},

		-- Global Functions
		C_Timer = {
			fields = {
				"After"
			}
		},

		C_AddOns = {
			fields = {
				"GetAddOnMetadata",
			}
		},

		"hooksecurefunc",
		"debugprofilestop",
		"GetAddOnMetadata",
		"CreateFrame",
		"ChatEdit_FocusActiveWindow",
		"GetLocale",
		"StaticPopup_Show",
		"ChatEdit_LinkItem",
		"CreateColor",
		"GameTooltip_SetTitle",
		"PlaySound",
		"SearchBoxTemplate_OnLoad",
		"SearchBoxTemplate_OnTextChanged",

		-- Global Mixins and UI Objects
		GameTooltip = {
			fields = {
				"GetOwner",
				"SetOwner",
				"Show",
				"Hide",
			}
		},
		SOUNDKIT = {
			fields = {
				"U_CHAT_SCROLL_BUTTON"
			}
		},

		"UIParent",

		-- Global Constants
		"WOW_PROJECT_ID",
		"WOW_PROJECT_MAINLINE",
		"STATICPOPUPS_NUMDIALOGS",
		"YES",
		"NO",
		"ACCEPT",
		"CANCEL",
	},
}