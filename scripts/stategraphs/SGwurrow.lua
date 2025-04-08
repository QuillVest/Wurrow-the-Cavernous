---@diagnostic disable: undefined-global
require("stategraphs/commonstates")

local events = {
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(nil, TUNING.BUNNYMAN_MAX_STUN_LOCKS),
    CommonHandlers.OnDeath(),
	CommonHandlers.OnSink(),
    CommonHandlers.OnFallInVoid(),
    EventHandler("burrowaway", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then 
            inst.sg:GoToState("burrowaway")
        end
    end),
    EventHandler("burrowto", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg.mem.queued_burrowto_data = data
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("burrowto", data)
            end
        end
    end),
    EventHandler("burrowarrive", function(inst, data)
        inst.sg:GoToState("burrowarrive", data)
    end),
}

local actionhandlers = {
    ActionHandler(ACTIONS.BURROW,
        function(inst, action)
            return action.invobject == nil and inst:HasTag("wurrow") and "burrow_enter"
        end),
    ActionHandler(ACTIONS.TUNNEL,
        function(inst, action)
            return action.invobject == nil and inst:HasTag("wurrow") and "burrowing"
        end),
}

local states = {
    State{
        name = "burrow_pre",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jumpin")
            inst.AnimState:PlayAnimation("despawn")
            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end
        end,

        timeline = {
            FrameEvent(10, function(inst)
                SpawnAt("shovel_dirt", inst)
            end),
            FrameEvent(30, function(inst)
                SpawnAt("shovel_dirt", inst)
            end),
            FrameEvent(40, function(inst)
                inst.sg:RemoveStateTag("busy")
            end)
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("busy") then
                inst.SoundEmitter:KillSound("rumble_lp")
            end
        end,

        events = {
            EventHandler("animover", 
                function(inst)
                    if inst.AnimState:AnimDone() and not inst:PerformBufferedAction() then
                        inst.sg:GoToState("burrowing")
                    end
                end)
        },
    },
        State{
            name = "burrowing",
            tags = { "moving", "canrotate", "dirt", "invisible" },
    
            onenter = function(inst)
                inst.components.health:SetInvincible(true)
                inst.DynamicShadow:Enable(false)
                inst.components.locomotor.walkspeed = 4
                inst.components.locomotor:SetSlowMultiplier( 1 )
                inst.components.locomotor:SetTriggersCreep(false)
                inst.components.locomotor.pathcaps = { ignorecreep = true, ignorebridges = true, }
                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation("walk_loop")
                if not inst.SoundEmitter:PlayingSound("walkloop") then
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/move", "walkloop")
                end
            end,
    
            timeline =
            {
                TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/dirt") end),
                TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/dirt") end),
                TimeEvent(20 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/dirt") end),
            },
    
            events =
            {
                EventHandler("animover", function(inst)
                    inst.sg.statemem.walking = true
                    inst.sg:GoToState("walk")
                end),
            },
    
            onexit = function(inst)
                if not inst.sg.statemem.walking then
                    inst.SoundEmitter:KillSound("walkloop")
                end
            end,
        },

    State{
        name = "burrow_out",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jumpout")
            local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil and buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
        end,
        
        onexit = function(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and not inst:PerformBufferedAction() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
}

return StateGraph("wurrow", states, events, "idle", actionhandlers)