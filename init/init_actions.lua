AddAction("BURROW", "Burrow", function(act)
    if act.doer ~= nil and act.doer:HasTag("wurrow")
        and not act.doer:HasTag("burrowed") and inst.components.hunger:GetPercent() >= 0.2 then
        return true
    end
end)

AddAction("RESURFACE", "Resurface", function(act)
    if act.doer ~= nil and act.doer:HasTag("wurrow") and act.doer:HasTag("burrowed") then
        return true
    end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURROW, function(inst, action)
    return action.invobject == nil and inst:HasTag("wurrow") and "burrow"
end))

AddStategraphActionHandler("wurrow", GLOBAL.ActionHandler(GLOBAL.ACTIONS.RESURFACE, function(inst, action)
    return action.invobject == nil and inst:HasTag("wurrow") and "resurface"
end))

AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURROW, "burrow"))

AddComponentAction("BURROW_RCLICK", "Burrow", function(doer, actions, _right)
    if doer.prefab == "wurrow" then
        table.insert(actions, GLOBAL.ACTIONS.BURROW)
    end
end)

AddComponentAction("RESURFACE_RCLICK", "Resurface", function(doer, actions, _right)
    if doer.prefab == "wurrow" then
        table.insert(actions. GLOBAL.ACTIONS.RESURFACE)
    end
end)

AddStategraphState ("wilson", GLOBAL.State{
    name = "burrow",
    tags = { "doing", "busy" },

    onenter = function(inst)

        if inst:HasTag("scarytoprey") then
            inst:RemoveTag("scarytoprey")
        end

        inst.components.locomotor:Stop()
        inst.DynamicShadow:Enable(false)
        inst.AnimState:PlayAnimation("jump", false)
        local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end
    end,

    timeline = {
        GLOBAL.TimeEvent(15 * GLOBAL.FRAMES, function(inst)
			inst.Physics:Stop()
        end),
        GLOBAL.FrameEvent(17, function(inst)
            GLOBAL.SpawnAt("dirt_puff", inst)
        end),
        GLOBAL.TimeEvent(17 * GLOBAL.FRAMES, function(inst)
            inst.components.hunger:DoDelta(-5)
        end)
        -- GLOBAL.TimeEvent(18 * GLOBAL.FRAMES, function(inst)
        --     inst.Light:Enable(false)
        -- end),
    },

    events = {
        GLOBAL.EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.components.moisture.inherentWaterproofness = 1000

                inst:AddTag("burrowed")
                inst:AddTag("bear_trap_immune")
                inst:AddTag("bat")
                inst:AddTag("batvision")

                inst.components.combat.damagemultiplier = 8.16
                inst.sg:GoToState("idle")

                local treasure_config = TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Treasure"]
                local frequency = TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Treasure_Frequency"]

                if treasure_config == 1 then
                    if not inst.components.timer:TimerExists("treasure_drop") then
                        inst.components.timer:StartTimer("treasure_drop", frequency)
                    else
                        inst.components.timer:ResumeTimer("treasure_drop")
                    end
                end

                if inst.components.sandstormwatcher then
                    inst.components.sandstormwatcher:SetSandstormSpeedMultiplier(1)
                end

                inst.components.hunger.burnratemodifiers:SetModifier(inst, 2, "burrowingpenalty")
                inst.components.temperature.mintemp = 6
                inst.components.temperature.maxtemp = 63
            end
        end)
    },
})

AddStategraphState("wilson_client", GLOBAL.State{
    name = "burrow",
    tags = { "doing", "busy" },
    server_states = { "burrow", "resurface" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("jump")
        
        inst:PerformPreviewBufferedAction()
        inst.sg:SetTimeout(2)
    end,

    onupdate = function(inst)
        if inst.sg:ServerStateMatches() then
            if inst.entity:FlattenMovementPrediction() then
                inst.sg:GoToState("idle", "noanim")
            end
        elseif inst.bufferedaction == nil then
            inst.sg:GoToState("idle")
        end
    end,

    ontimeout = function(inst)
        inst:ClearBufferedAction()
        inst.sg:GoToState("idle")
    end
})