require("stategraphs/commonstates")

local burrow_state = Global.State{
    name = "burrow_pre",
    tags = { "start" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:Show("ARM_carry")
        inst.AnimState:Show("teleporter_worm")
        inst.AnimState:Hide("player")
    end,
    
    events = {
        GLOBAL.EventsHandler("animqueueover", function(inst)
            inst.sg:GoToState("idle")
        )
    }
}

local burrow_state_client = Global.State{
    name = "burrow_pre",
    server_state = { "burrow_pre" },
    forward_server_status = true,

    onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end
}

local actionhandlers = {
    ActionHandler(ACTIONS.USE_WEREFORM_SKILL,
      function(inst) return (inst:HasTag("worm") and "burrow_pre") or nil end),
  }

AddStategraphState("burrow_pre", burrow_state)
AddStategraphState("burrow_pre_client", burrow_state_client)
AddStategraphActionHandler("burrow_pre", GLOBAL.ActionHandler(Global.ACTIONS.HUG, "burrow_pre"))
AddStategraphActionHandler("burrow_pre_client", GLOBAL.ActionHandler(Global.ACTIONS.HUG, "burrow_pre"))

return StateGraph("wurrow", states, events, "idle", actionhandlers)