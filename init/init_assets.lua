Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/wurrow.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/wurrow.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/wurrow.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wurrow.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/wurrow_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wurrow_silho.xml" ),

    Asset( "IMAGE", "bigportraits/wurrow.tex" ),
    Asset( "ATLAS", "bigportraits/wurrow.xml" ),
    Asset( "IMAGE", "bigportraits/wurrow_none.tex"),
    Asset( "ATLAS", "bigportraits/wurrow_none.xml"),

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

    Asset("IMAGE", "images/colour_cubes/bat_vision_on_cc.tex"),

    Asset("ATLAS", "images/wurrow_inventory.xml"),
    Asset("IMAGE", "images/wurrow_inventory.tex"),

    ---———————————————={ Animations }=———————————————---
    Asset("ANIM", "anim/bottle.zip"),
    Asset("ANIM", "anim/swap_gelblobbottle.zip"),
    Asset("ANIM", "anim/swap_bottle.zip"),

    Asset("ANIM", "anim/toothkits.zip"),
    Asset("ANIM", "anim/wurrow_lure.zip"),
}

AddMinimapAtlas("images/map_icons/wurrow.xml")

local ITEMS = {
	"toothkit_flint",
    "toothkit_marble",
    "toothkit_calcite",
    "toothkit_thulecite",
    "toothkit_brightshade",
    "toothkit_dreadstone",
    "unearthed_soil",
    "pocketsand",
}

for i, v in pairs(ITEMS) do
	RegisterInventoryItemAtlas("images/wurrow_inventory.xml", v..".tex")
end