local function WurrowRecipe(name, ingredients, tech, config, filters)
	if config == nil then
		config = {}
	end	

	config.nounlock = config.nounlock == nil and true or config.nounlock

	AddCharacterRecipe(name, ingredients, tech, config, filters)
end

WurrowRecipe("pocketsand",
    {Ingredient("messagebottleempty", 1),
    Ingredient("unearthed_soil", 1)},
    GLOBAL.TECH.SCIENCE_ONE,
    {builder_tag = "wurrow", nounlock=false},
    {"WEAPONS"}
)

WurrowRecipe("toothkit_flint",
    {Ingredient("flint", 2),
    Ingredient("cutstone", 1),
    Ingredient("rope", 2)},
    GLOBAL.TECH.SCIENCE_ONE,
    {builder_tag = "wurrow", nounlock=false},
    {"TOOLS"}
)

WurrowRecipe("toothkit_marble",
    {Ingredient("marble", 3),
    Ingredient("log", 1)},
    GLOBAL.TECH.SCIENCE_TWO,
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