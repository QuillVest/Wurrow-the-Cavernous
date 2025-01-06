PrefabFiles = {
	"wurrow",
	"wurrow_none",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/wurrow.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/wurrow.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/wurrow.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wurrow.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/wurrow_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wurrow_silho.xml" ),

    Asset( "IMAGE", "bigportraits/wurrow.tex" ),
    Asset( "ATLAS", "bigportraits/wurrow.xml" ),
	
	Asset( "IMAGE", "images/map_icons/wurrow.tex" ),
	Asset( "ATLAS", "images/map_icons/wurrow.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_wurrow.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_wurrow.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_wurrow.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_wurrow.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_wurrow.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_wurrow.xml" ),
	
	Asset( "IMAGE", "images/names_wurrow.tex" ),
    Asset( "ATLAS", "images/names_wurrow.xml" ),
	
	Asset( "IMAGE", "images/names_gold_wurrow.tex" ),
    Asset( "ATLAS", "images/names_gold_wurrow.xml" ),
}

AddMinimapAtlas("images/map_icons/wurrow.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

STRINGS.CHARACTER_TITLES.wurrow = "The Cavernous"
STRINGS.CHARACTER_NAMES.wurrow = "Wurrow"
STRINGS.CHARACTER_DESCRIPTIONS.wurrow = "*Loves the caves, hates the surface\n*Insatiable appetite for anything\n*No stranger to getting dirty\n*Blinded by bright things"
STRINGS.CHARACTER_QUOTES.wurrow = "\"Have you seen my lure?\""
STRINGS.CHARACTER_SURVIVABILITY.wurrow = "Grim"

STRINGS.CHARACTERS.WURROW = require "speech_wurrow"

STRINGS.NAMES.WURROW = "Wurrow"
STRINGS.SKIN_NAMES.wurrow_none = "Wurrow"

local skin_modes = {
    { 
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle", 
        scale = 0.75, 
        offset = { 0, -25 } 
    },
}

AddModCharacter("wurrow", "MALE", skin_modes)
