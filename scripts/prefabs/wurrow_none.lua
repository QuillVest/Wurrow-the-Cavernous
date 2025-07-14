local prefabs = {}

table.insert(prefabs, CreatePrefabSkin("wurrow_none", {
	assets = {
		Asset( "ANIM", "anim/wurrow.zip" ),
		Asset( "ANIM", "anim/ghost_wurrow_build.zip" ),
		
		Asset( "IMAGE", "images/bigportraits/wurrow.tex" ),
		Asset( "ATLAS", "images/bigportraits/wurrow.xml" ),
	},
	
	rarity = "Character",
	type = "base",
	base_prefab = "wurrow",
	build_name_override = "wurrow",

	skins = {
		ghost_skin = "ghost_wurrow_build", 
		normal_skin = "wurrow",
	},

	skin_tags = { "BASE", "WURROW"},
}))

return unpack(prefabs)