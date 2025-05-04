---@diagnostic disable: undefined-global
local ENV = _ENV
GLOBAL.setfenv(1, GLOBAL)

local AddStategraphPostInit = ENV.AddStategraphPostInit

local actionhandlers = {
    ActionHandler(ACTIONS.DIG, "burrow_dig"),
    ActionHandler(ACTIONS.PICK, "burrow_pick"),
    ActionHandler(ACTIONS.DROP, "burrow_drop"),
    ActionHandler(ACTIONS.PICKUP, "burrow_pickup"),
    ActionHandler(ACTIONS.ATTACK, "burrow_attack"),
}

local events = {
    EventHandler("death", function(inst)
        inst:RemoveTag("burrowed")
		inst.sg:GoToState("death")
	end),
	EventHandler("locomote", function(inst, data)
        if inst.sg:HasStateTag("busy") or inst:HasTag("busy") then
            return
        end
        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        if is_moving and not should_move then
            inst.sg:GoToState("burrow_pst")
        elseif not is_moving and should_move then
            inst.sg:GoToState("burrow_loop")
        elseif data.force_idle_state and not (is_moving or should_move or inst.sg:HasStateTag("idle")) then
            inst.sg:GoToState("idle")
		end
    end),

    EventHandler("knockback", function(inst, data)
        if inst:HasTag("burrowed") then
            inst:RemoveTag("burrowed")
        end

        inst.SoundEmitter:KillSound("move")
        inst.sg:GoToState((data.forcelanded or inst.components.inventory:EquipHasTag("heavyarmor") or inst:HasTag("heavybody")) and "knockbacklanded" or "knockback", data)
    end),

    EventHandler("startstarving", function(inst)
        inst.sg:GoToState("resurface")
        inst.components.talker:Say("Me hungy :(")
    end),
}

local function SpawnMoveFx(inst)
    SpawnPrefab("mole_move_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local states = {
    State{
        name = "death",
        tags = { "busy", "pausepredict", "nomorph" },

        onenter = function(inst)
			assert(inst.deathcause ~= nil, "Entered death state without cause.")

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()

            inst.SoundEmitter:KillSound("move")

			inst.SoundEmitter:KillSound("move")
			inst.sg:GoToState("death")

            inst.Light:Enable(false)
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)

			if inst.components.playercontroller ~= nil then
               inst.components.playercontroller:RemotePausePrediction()
			   inst.components.playercontroller:Enable(false)
            end

            inst.sg:ClearBufferedEvents()
        end,

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
                    inst:PushEvent(inst.ghostenabled and "makeplayerghost" or "playerdied", { skeleton = true })
                end
            end),
        },
    },

    State {
        name = "idle",
        tags = { "idle", "canrotate", "hiding", "nomorph" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("idle_under", true)
        end,
    },

    State {
        name = "burrow_pre",
            tags = { "moving", "canrotate", "hiding", "nomorph" },

            onenter = function(inst)
                inst.components.hunger.burnratemodifiers:SetModifier(inst, 4, "burrowingpenalty")
                inst.AnimState:PlayAnimation("walk_pre")
                inst.components.locomotor:WalkForward()
            end,

            events = {
                EventHandler("animover", function(inst)
                    inst.sg:GoToState("run")
                end),
            }
    },

    State {
        name = "burrow_loop",
            tags = { "moving", "canrotate", "hiding", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor.walkspeed = 5
            inst.AnimState:PlayAnimation("walk_loop")
            inst.components.locomotor:WalkForward()
        end,

        timeline = {
            TimeEvent(3*FRAMES,  SpawnMoveFx),
            TimeEvent(9*FRAMES, SpawnMoveFx),
            TimeEvent(15*FRAMES, SpawnMoveFx),
            TimeEvent(21*FRAMES, SpawnMoveFx),
            TimeEvent(27*FRAMES, SpawnMoveFx),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("burrow_loop")
            end),
        }
    },

    State {
        name = "burrow_pst",
            tags = { "canrotate", "hiding", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")
            inst.SoundEmitter:KillSound("move")
        end,

        events = {
            EventHandler("animover", function(inst)
            inst.components.hunger.burnratemodifiers:SetModifier(inst, 2, "burrowingpenalty")
                inst.sg:GoToState("idle")
            end),
         },
    },

    State {
        name = "resurface",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("jumpout")

            inst:RemoveTag("burrowed")
            inst:RemoveTag("bear_trap_immune")
            inst:RemoveTag("bat")
            inst:RemoveTag("batvision")

            local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil and buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
        end,

        timeline = {
            -- TimeEvent(10 * FRAMES, function(inst)
            --     if inst.components.beard then
            --         inst.Light:Enable(true)
            --     end
            -- end),
            FrameEvent(3, function(inst)
                SpawnAt("shovel_dirt", inst)
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(3, 0, 0)
                end
            end),
            TimeEvent(15 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(2, 0, 0)
                end
            end),
            TimeEvent(15.2 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    if inst.sg.statemem.isphysicstoggle then
                        ToggleOnPhysics(inst)
                    end
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                end
            end),
            TimeEvent(17 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(inst.sg.statemem.heavy and .5 or 1, 0, 0)
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.Physics:Stop()
            end),
        },

        events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.components.moisture.inherentWaterproofness = 0
                inst.components.combat.damagemultiplier = 1.0
                inst.sg:GoToState("idle")
                inst.components.hunger.burnratemodifiers:RemoveModifier(inst, "burrowingpenalty")

                if inst.components.timer:TimerExists("treasure_drop") and not inst.components.timer:IsPaused("treasure_drop") then
                    inst.components.timer:PauseTimer("treasure_drop")
                end

                if inst.components.sandstormwatcher then
                    inst.components.sandstormwatcher:SetSandstormSpeedMultiplier(TUNING.SANDSTORM_SPEED_MOD)
                end

                inst.components.temperature.mintemp = TUNING.MIN_ENTITY_TEMP
                inst.components.temperature.maxtemp = TUNING.MAX_ENTITY_TEMP
            end
        end),
        },
    },

    State {
        name = "burrow_drop",
        tags = { "doing", "busy", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.SoundEmitter:KillSound("move")
			inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(15 * FRAMES)
        end,

		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("jump")
            end),
            -- TimeEvent(6 * FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound("")
            -- end),
            TimeEvent(8 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
		},

		ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State {
        name = "burrow_pickup",
        tags = { "doing", "busy", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.SoundEmitter:KillSound("move")
			inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(15 * FRAMES)
        end,

		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("jumpout")
            end),
            -- TimeEvent(6 * FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound("")
            -- end),
            TimeEvent(8 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
		},

		ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State {
        name = "burrow_pick",
        tags = { "doing", "busy", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("wurrow_harvesting")
            inst.AnimState:PushAnimation("wurrow_harvesting")
			inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(25 * FRAMES)
        end,

		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            -- TimeEvent(6 * FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound("")
            -- end),
            TimeEvent(20 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
		},

		ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State {
        name = "burrow_dig",
        tags = { "doing", "busy", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("wurrow_harvesting")
            inst.AnimState:PushAnimation("wurrow_harvesting")
			inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(25 * FRAMES)
        end,

		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            -- TimeEvent(6 * FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound("")
            -- end),
            TimeEvent(20 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
		},

		ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State {
        name = "burrow_attack",
        tags = { "doing", "busy", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:KillSound("move")
            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(30 * FRAMES)
        end,

        timeline = {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            -- TimeEvent(6 * FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound("")
            -- end),
            TimeEvent(6 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("spearjab")
            end),
            TimeEvent(25 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
            end
        end,

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

AddStategraphPostInit("wilson", function(sg)
    for _, state in pairs(states) do
        sg.states[state.name] = state
    end
-- ATTACK --
    local burrowing_attack = sg.actionhandlers[ACTIONS.ATTACK].deststate
        sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equip == nil and inst:HasTag("burrowed") then
                return "burrowing_attack"
            end
            
            return burrowing_attack(inst, action, ...)
        end
-- DROP --
    local burrowing_drop = sg.actionhandlers[ACTIONS.DROP].deststate
        sg.actionhandlers[ACTIONS.DROP].deststate = function(inst, action, ...)
            if inst:HasTag("burrowed") then
                return ("burrowing_drop")
            end
        
            return burrowing_drop(inst, action, ...)
        end
-- PICKUP --
    local burrowing_pickup = sg.actionhandlers[ACTIONS.PICKUP].deststate
        sg.actionhandlers[ACTIONS.PICKUP].deststate = function(inst, action, ...)
            if inst:HasTag("burrowed") then
                return ("burrowing_pickup")
            end
        
            return burrowing_pickup(inst, action, ...)
        end
-- PICK --
    local burrowing_pick = sg.actionhandlers[ACTIONS.PICK].deststate
        sg.actionhandlers[ACTIONS.PICK].deststate = function(inst, action, ...)
            if inst:HasTag("burrowed") then
                return ("burrowing_pick")
            end
        
            return burrowing_pick(inst, action, ...)
        end
-- DIG --
    local burrowing_dig = sg.actionhandlers[ACTIONS.dig].deststate
        sg.actionhandlers[ACTIONS.dig].deststate = function(inst, action, ...)
            if inst:HasTag("burrowed") then
                return ("burrowing_dig")
            end
        
            return burrowing_dig(inst, action, ...)
        end

--- BURROWING ---
    local burrow_pre = sg.states["run_start"].onupdate
        sg.states["run_start"].onupdate = function(inst, ...)
            burrow_pre(inst, ...)

            if inst:HasTag("burrowed") and inst.AnimState:IsCurrentAnimation("run_pre") then
                inst.AnimState:PushAnimation("burrow_pre")
            end
        end
	
	local burrow_loop = sg.states["run"].onenter
        sg.states["run"].onenter = function(inst, ...)
            burrow_loop(inst, ...)

            if inst:HasTag("burrowed") and inst.AnimState:IsCurrentAnimation("run_loop") then
                inst.components.locomotor:SetTriggersCreep(false)
                inst.AnimState:PushAnimation("burrow_loop")
            end
        end
	
	local burrow_post = sg.states["run_stop"].onenter
        sg.states["run_stop"].onenter = function(inst, ...)
            burrow_post(inst, ...)

            if inst:HasTag("burrowed") and inst.AnimState:IsCurrentAnimation("run_pst") then
                inst.AnimState:PushAnimation("burrow_pst")
                inst.components.locomotor:SetTriggersCreep(true)
            end
        end
end)

return StateGraph("wurrow", states, events, "idle", actionhandlers)