local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local AddAction = ENV.AddAction
local AddStategraphActionHandler = ENV.AddStategraphActionHandler
local AddSimPostInit = ENV.AddSimPostInit

---———————————————={ Burrowing }=———————————————---
AddAction("BURROW", "Burrow", function(act)
	if act.doer and act.doer:HasTag("wurrow") and not act.doer:HasTag("burrowed") and act.doer.components.hunger:GetPercent() >= 0.1 then
		return true
	end

	return false
end)

AddAction("RESURFACE", "Resurface", function(act)
	if act.doer and act.doer:HasTag("wurrow") and act.doer:HasTag("burrowed") then
		return true
	end

	return false
end)

local function AddToSGAC(action, state)
	AddStategraphActionHandler("wilson", ActionHandler(ACTIONS[action], state))
	AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS[action], state))
end

local actionhandlers = {
	RESURFACE = "resurface",
	BURROW = "burrow",
}

for action, state in pairs(actionhandlers) do
	AddToSGAC(action, state)
end

AddSimPostInit(function()
	if ACTIONS and ACTIONS.BURROW and ACTIONS.RESURFACE then
		ACTIONS.BURROW.invalid_hold_action = true
		ACTIONS.RESURFACE.invalid_hold_action = true
	end
end)

---———————————————={ Gel }=———————————————---
STRINGS.ACTIONS.APPLYGEL = "Apply Gel"
local APPLYGEL = AddAction("APPLYGEL", STRINGS.ACTIONS.APPLYGEL, function(act)
    if act.doer ~= nil and act.doer:HasTag("wurrow") then
		target.components.locomotor:SetExternalSpeedMultiplier(inst, "gel_ms", 1.1)
		return true
    end
end)

ACTIONS.APPLYGEL.id = "APPLYGEL"
ACTIONS.APPLYGEL.priority = 3
ACTIONS.APPLYGEL.rmb = true
ACTIONS.APPLYGEL.mount_valid = true

AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions)
    if doer:HasTag("wurrow") and inst.prefab == "slurtleslime" then
        table.insert(actions, ACTIONS.APPLYGEL)
    end
end, ENV.modname)

local gelaction = ActionHandler(ACTIONS.APPLYGEL, "domediumaction")
AddStategraphActionHandler("wilson", gelaction)
AddStategraphActionHandler("wilson_client", gelaction)

---———————————————={ Toothkits }=———————————————---
STRINGS.ACTIONS.SHARPEN = "Sharpen"
local SHARPEN = AddAction("SHARPEN", STRINGS.ACTIONS.SHARPEN, function(act)
    if act.doer ~= nil and act.doer:HasTag("wurrow") then
        act.doer:AddDebuff("buff_toothkit", "buff_toothkit")
		if act.invobject.components.finiteuses then
			act.invobject.components.finiteuses:Use(1)
		end
		return true
    end
end)

ACTIONS.SHARPEN.id = "SHARPEN"
ACTIONS.SHARPEN.priority = 3
ACTIONS.SHARPEN.rmb = true
ACTIONS.SHARPEN.mount_valid = true

AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions)
    if doer:HasTag("wurrow") and inst.prefab == "toothkit_flint" then
        table.insert(actions, ACTIONS.SHARPEN)
    end
end, ENV.modname)

local sharpener = ActionHandler(ACTIONS.SHARPEN, "dolongaction")
AddStategraphActionHandler("wilson", sharpener)
AddStategraphActionHandler("wilson_client", sharpener)