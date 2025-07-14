require("wurrow_strings")

local inits = {
    "init_actions",
	"init_assets",
	"init_prefabs",
	"init_wurrow",
	"init_recipes",
}

local stategraphs = {
    "wilson",
}

local components = {
	"carefulwalker",
}

for _, v in pairs(inits) do
	modimport("init/"..v)
end

for _, v in pairs(stategraphs) do
    modimport("postinit/stategraphs/"..v)
end

for _, v in pairs(components) do
    modimport("postinit/components/"..v)
end

TUNING.WURROW_HEALTH = 175
TUNING.WURROW_HUNGER = 225
TUNING.WURROW_SANITY = 125

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WURROW = {
	"slurper_pelt",
    "slurper_pelt",
    "slurper_pelt",
}

TUNING.CHARACTER_PREFAB_MODCONFIGDATA = {}
--- Stat Settings
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Health"] = GetModConfigData("Health")
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Hunger"] = GetModConfigData("Hunger")
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Sanity"] = GetModConfigData("Sanity")
--- Burrowing Settings
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Drain_Move"] = GetModConfigData("Burrow_Drain_Move")
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Drain_Still"] = GetModConfigData("Burrow_Drain_Still")
--- Treasure Settings
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Treasure"] = GetModConfigData("Burrow_Treasure")
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Treasure_Frequency"] = GetModConfigData("Treasure_Frequency")
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Treasure_Amount"] = GetModConfigData("Treasure_Amount")

------------------------------------------------------------------------------------------------------------
--- Courtesy of ADM ---
local WURROW_BURROWED_ACTIONS = {
    "BURROW",
    "RESURFACE",
    "WALKTO",
    "ATTACK",
    "DIG",
    "DROP",
    "PICK",
    "PICKUP",
}

local LocoMotor = require("components/locomotor")

local OldPushAction = LocoMotor.PushAction
function LocoMotor:PushAction(bufferedaction, ...)
    if self.inst.prefab == "wurrow" and self.inst:HasTag("burrowed") and bufferedaction and not table.contains(WURROW_BURROWED_ACTIONS, bufferedaction.action.id) then
        self.inst.sg:GoToState("resurface", bufferedaction)
        return
    end
    
    return OldPushAction(self, bufferedaction, ...)
end

--- MISCELLANEOUS FUNCTIONS ---
AddComponentPostInit("playeractionpicker", function(self)
	if self.inst.prefab == "wurrow" then
		local old = self.GetRightClickActions
		self.GetRightClickActions = function(self, position, target)
				if target and self.inst:HasTag("burrowed") and target:HasTag(GLOBAL.ACTIONS.DIG.id.."_workable") then
					return self:SortActionList({ GLOBAL.ACTIONS.DIG }, target)
				end
			return old(self, position, target)
		end
	end
end)

--- Courtesy of Ilaskus ---
AddPrefabPostInit("worm", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    if inst.components.combat then
        inst.components.combat:AddNoAggroTag("wurrow")
    end
end)

AddPrefabPostInit("worm_boss", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    if inst.components.combat then
        inst.components.combat:AddNoAggroTag("wurrow")
    end
end)