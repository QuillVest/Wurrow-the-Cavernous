local function WurrowRecipe(name, ingredients, tech, config, filters)
	if config == nil then
		config = {}
	end	

	config.nounlock = config.nounlock == nil and true or config.nounlock

	AddCharacterRecipe(name, ingredients, tech, config, filters)
end

WurrowRecipe("pocketsand",
    {Ingredient("messagebottleempty", 1),
    Ingredient("spoiled_food", 5),
    Ingredient("cutgrass", 2)},
    GLOBAL.TECH.NONE,
    {builder_tag = "wurrow", nounlock=false},
    {"WEAPONS"}
)

---———————————————={ Toothkits }=———————————————---
WurrowRecipe("toothkit_stinger",
    {Ingredient("stinger", 8),
    Ingredient("cutgrass", 4)},
    GLOBAL.TECH.NONE,
    {builder_tag = "wurrow", nounlock=false},
    {"TOOLS"}
)

WurrowRecipe("toothkit_flint",
    {Ingredient("flint", 4),
    Ingredient("cutstone", 2),
    Ingredient("rope", 3)},
    GLOBAL.TECH.SCIENCE_ONE,
    {builder_tag = "wurrow", nounlock=false},
    {"TOOLS"}
)

WurrowRecipe("toothkit_calcite",
    {Ingredient("slurtle_shellpieces", 4),
    Ingredient("slurper_pelt", 2)},
    GLOBAL.TECH.SCIENCE_TWO,
    {builder_tag = "wurrow", nounlock=false},
    {"TOOLS"}
)

WurrowRecipe("toothkit_bone",
    {Ingredient("walrus_tusk", 1),
    Ingredient("fossil_piece", 6),
    Ingredient("boneshard", 4)},
    GLOBAL.TECH.SCIENCE_TWO,
    {builder_tag = "wurrow", nounlock=false},
    {"TOOLS"}
)

WurrowRecipe("toothkit_thulecite",
    {Ingredient("thulecite", 2),
    Ingredient("nightmarefuel", 4),
    Ingredient("purplegem", 1)},
    GLOBAL.TECH.ANCIENT_TWO,
    {builder_tag = "wurrow", nounlock=true, station_tag="ancient_station"},
    {"CRAFTING_STATION"}
)

WurrowRecipe("toothkit_brightshade",
    {Ingredient("purebrilliance", 2),
    Ingredient("moonglass", 3),
    Ingredient("lunarplant_husk", 2)},
    GLOBAL.TECH.LUNARFORGING_TWO,
    {builder_tag = "wurrow", nounlock=true, station_tag="lunar_forge"},
    {"CRAFTING_STATION"}
)

WurrowRecipe("toothkit_dreadstone",
    {Ingredient("horrorfuel", 2),
    Ingredient("dreadstone", 1),
    Ingredient("voidcloth", 2)},
    GLOBAL.TECH.SHADOWFORGING_TWO,
    {builder_tag = "wurrow", nounlock=true, station_tag="shadow_forge"},
    {"CRAFTING_STATION"}
)

WurrowRecipe("toothkit_moonglass",
    {Ingredient("moonglass", 6),
    Ingredient("moonrocknugget", 4)},
    GLOBAL.TECH.CELESTIAL_ONE,
    {builder_tag = "wurrow", nounlock=true},
    {"TOOLS"}
)

WurrowRecipe("toothkit_scrap",
    {Ingredient("wagpunk_bits", 4),
    Ingredient("trinket_6", 2),
    Ingredient("chestupgrade_stacksize", 1)},
    GLOBAL.TECH.SCIENCE_TWO,
    {builder_tag = "wurrow", nounlock=false},
    {"TOOLS"}
)

WurrowRecipe("grindstone_kit",
    {Ingredient("marble", 4),
    Ingredient("cutstone", 8),
    Ingredient("boards", 3)},
    GLOBAL.TECH.SCIENCE_ONE,
    {builder_tag = "wurrow", nounlock=false},
    {"STRUCTURES"}
)