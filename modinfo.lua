name = "Wurrow, the Cavernous"
description = "A friendly depths worm mutated by the miasma lingering in the caverns below."
author = "QuillVest"
version = "0.5"

forumthread = ""

api_version = 10

dst_compatible = true

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

all_clients_require_mod = true 

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
"character",
"wurrow",
}

configuration_options = {
    -- {
    --     name = "Health",
    --     label = "Health",
    --     hover = "Determines max health.",
    --     options = {
	-- 		{description="100", data = 100},
	-- 		{description="110", data = 110},
	-- 		{description="120", data = 120},
	-- 		{description="130", data = 130},
	-- 		{description="140", data = 140},
	-- 		{description="150", data = 150},
	-- 		{description="160", data = 160},
	-- 		{description="170", data = 170},
    --         {description="175", data = 175},
	-- 		{description="180", data = 180},
	-- 		{description="190", data = 190},
	-- 		{description="200", data = 200},
    --     },
    --     default = 175,
    -- },
	
	-- {
    --     name = "Hunger",
    --     label = "Hunger",
    --     hover = "Determines max hunger.",
    --     options = {
    --         {description="100", data = 100},
	-- 		{description="110", data = 110},
	-- 		{description="120", data = 120},
	-- 		{description="130", data = 130},
	-- 		{description="140", data = 140},
	-- 		{description="150", data = 150},
	-- 		{description="160", data = 160},
	-- 		{description="170", data = 170},
	-- 		{description="180", data = 180},
	-- 		{description="190", data = 190},
	-- 		{description="200", data = 200},
    --         {description="225", data = 225},
    --     },
    --     default = 225,
    -- },
	
	-- {
    --     name = "Sanity",
    --     label = "Sanity",
    --     hover = "Determines max sanity.",
    --     options = {
    --         {description="100", data = 100},
	-- 		{description="110", data = 110},
	-- 		{description="120", data = 120},
	-- 		{description="130", data = 130},
	-- 		{description="140", data = 140},
	-- 		{description="150", data = 150},
	-- 		{description="160", data = 160},
	-- 		{description="170", data = 170},
	-- 		{description="180", data = 180},
	-- 		{description="190", data = 190},
	-- 		{description="200", data = 200},
    --         {description="125", data = 125}, 
    --     },
    --     default = 125,
    -- },

    -- {
    --     name = "Burrow_Drain_Move",
    --     label = "Burrow Movement Drain",
    --     hover = "The hunger drain while burrowed and actively moving.",
    --     options = {
	-- 		{description="OFF", data = 1.00},
	-- 		{description="115%", data = 1.15},
	-- 		{description="125%", data = 1.25},
	-- 		{description="150%", data = 1.50},
	-- 		{description="175%", data = 1.75},
	-- 		{description="200%", data = 2.00},
	-- 		{description="225%", data = 2.25},
	-- 		{description="250%", data = 2.50},
	-- 		{description="275%", data = 2.75},
	-- 		{description="300%", data = 3.00},   
    --     },
    --     default = 2.00,
    -- },
	
	-- {
    --     name = "Burrow_Drain_Still",
    --     label = "Burrow Stationary Drain",
    --     hover = "The hunger drain while burrowed and not moving.",
    --     options = {	
    --         {description="OFF", data = 1.00},
	-- 		{description="115%", data = 1.15},
	-- 		{description="125%", data = 1.25},
	-- 		{description="150%", data = 1.50},
	-- 		{description="175%", data = 1.75},
	-- 		{description="200%", data = 2.00},
	-- 		{description="225%", data = 2.25},
	-- 		{description="250%", data = 2.50},
	-- 		{description="275%", data = 2.75},
	-- 		{description="300%", data = 3.00},  
    --     },
    --     default = 1.25,
    -- },

    {
        name = "Burrow_Treasure",
        label = "Burrow Treasure",
        hover = "Wurrow will dig up random treasures when burrowing.",
        options = {
            {description="OFF", data = 0},
			{description="ON", data = 1},
        },
        default = 1,
    },
	
	{
        name = "Treasure_Frequency",
        label = "Treasure Frequency",
        hover = "Determines how often treasure will be awarded when burrowing.",
        options = {
			{description="30 seconds", data = 30},
			{description="1 minute", data = 60},
			{description="2 minutes", data = 120},
			{description="3 minutes", data = 180},
        },
        default = 60,
    },
	
	{
        name = "Treasure_Amount",
        label = "Treasure Amount",
        hover = "Determines how much treasure Wurrow will be awarded when burrowing.",
        options = {
			{description="1", data = 1},
			{description="2", data = 2},
			{description="3", data = 3},
			{description="4", data = 4},
			{description="5", data = 5},
        },
        default = 1,
    },
}