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

AddAction("APPLYGEL", STRINGS.ACTIONS.APPLYGEL, function(act)
    if act.doer ~= nil and act.doer:HasTag("wurrow") then
        act.doer:AddDebuff("buff_gelled", "buff_gelled")
		act.invobject:Remove()
		-- if act.invobject.stackable ~= nil and act.invobject.stackable:IsStack() then
        -- 	act.invobject:Get():Remove()
    	-- else
        -- 	act.invobject:Remove()
    	-- end
		return true
    end
end)

-- ACTIONS.APPLYGEL.strfn = function(act, ...)
--     local gels = act.invobject
--     return gels and (
--         gels:HasTag("slurtleslime") and "GENERIC"
-- 		or gels:HasTag("unearthed_soil" and "SOIL"))
-- end

-- STRINGS.ACTIONS.APPLYGEL = {
-- 	GENERIC = "Apply Gel",
-- 	SOIL = "Rub Soil",
-- }

ACTIONS.APPLYGEL.id = "APPLYGEL"
ACTIONS.APPLYGEL.priority = 3
ACTIONS.APPLYGEL.rmb = true
ACTIONS.APPLYGEL.mount_valid = true

AddComponentAction("INVENTORY", "furgel", function(inst, doer, actions)
    if doer:HasTag("wurrow") then
        table.insert(actions, ACTIONS.APPLYGEL)
    end
end, ENV.modname)

local gelhandler = ActionHandler(ACTIONS.APPLYGEL, "dolongaction")
AddStategraphActionHandler("wilson", gelhandler)
AddStategraphActionHandler("wilson_client", gelhandler)

---———————————————={ Toothkits }=———————————————---
STRINGS.ACTIONS.SHARPEN = "Sharpen"
AddAction("SHARPEN", STRINGS.ACTIONS.SHARPEN, function(act)
    if act.doer ~= nil and act.doer:HasTag("wurrow") then
		local debuffMap = {
			toothkit_flint = "buff_tkflint",
			toothkit_marble = "buff_tkmarble",
			toothkit_calcite = "buff_tkcalcite",
			toothkit_thulecite = "buff_tkthulecite",
			toothkit_electric = "buff_tkelectric",
			toothkit_brightshade = "buff_tkbrightshade",
			toothkit_dreadstone = "buff_tkdreadstone",
		}

		local debuff = debuffMap[act.invobject.prefab]
		act.doer:AddDebuff(debuff, debuff)

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
    if doer:HasTag("wurrow") and inst:HasTag("toothkit") then
        table.insert(actions, ACTIONS.SHARPEN)
    end
end, ENV.modname)

local sharpener = ActionHandler(ACTIONS.SHARPEN, "dolongaction")
AddStategraphActionHandler("wilson", sharpener)
AddStategraphActionHandler("wilson_client", sharpener)