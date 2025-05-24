local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local AddAction = ENV.AddAction
local AddStategraphActionHandler = ENV.AddStategraphActionHandler

AddAction("BURROW", "Burrow", function(act)
	if act.doer and act.doer:HasTag("wurrow") and not act.doer:HasTag("burrowed") and inst.components.hunger:GetPercent() >= 0.2 then
		return true
	end
end)

AddAction("RESURFACE", "Resurface", function(act)
	if act.doer and act.doer:HasTag("wurrow") and act.doer:HasTag("burrowed") then
		return true
	end
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