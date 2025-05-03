local prefs = {}

table.insert(prefs, CreatePrefabSkin("wurrow_skins", {
	base_prefab = "wurrow",
	type = "base",
	build_name_override = "wurrow",
	rarity = "Character",
	skin_tags = {"BASE", "WURROW"},
	bigportrait_anim = {build = "bigportraits/wurrow.xml", symbol = "wurrow_skins_oval.tex"},
	skins = {ghost_skin = "ghost_wurrow_build", normal_skin = "wurrow"},
}))

return unpack(prefs)