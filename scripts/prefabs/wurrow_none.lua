local assets =
{
	Asset( "ANIM", "anim/wurrow.zip" ),
	Asset( "ANIM", "anim/ghost_wurrow_build.zip" ),
}

local skins =
{
	normal_skin = "wurrow",
	ghost_skin = "ghost_wurrow_build",
}

return CreatePrefabSkin("wurrow_none",
{
	base_prefab = "wurrow",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"WURROW", "CHARACTER", "BASE"},
	build_name_override = "wurrow",
	rarity = "Character",
})