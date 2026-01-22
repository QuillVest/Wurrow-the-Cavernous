require("wurrow_strings")

local inits = {
    "init_actions",
	"init_assets",
	"init_prefabs",
	"init_wurrow",
	"init_recipes",
    "init_tunings",
}

local stategraphs = {
    "wilson",
}

local components = {
	"carefulwalker",
}

local prefabs = {
    "slurtleslime",
}

modimport("compatibilities/announcement_strings.lua")

for _, v in pairs(inits) do
	modimport("init/"..v)
end

for _, v in pairs(stategraphs) do
    modimport("postinit/stategraphs/"..v)
end

for _, v in pairs(components) do
    modimport("postinit/components/"..v)
end

for _, v in pairs(prefabs) do
    modimport("postinit/prefabs/"..v)
end

---———————————————={ Miscellanous Functions }=———————————————---
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

--- Courtesy of ADM
local WURROW_BURROWED_ACTIONS = {
    "BURROW",
    "RESURFACE",
    "WALKTO",
    "ATTACK",
    "DIG",
    "DROP",
    "PICK",
    "PICKUP",
    "LOOKAT",
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

--- Courtesy of Ilaskus
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