local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local AddAction = ENV.AddAction
local AddStategraphActionHandler = ENV.AddStategraphActionHandler
local AddSimPostInit = ENV.AddSimPostInit

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
