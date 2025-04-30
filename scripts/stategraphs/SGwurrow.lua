---@diagnostic disable: undefined-global, syntax-error
require("stategraphs/commonstates")

local WALK_SPEED = 4
local RUN_SPEED = 6

local actionhandlers = {
    ActionHandler(ACTIONS.DIG, "burrow_harvesting"),
    ActionHandler(ACTIONS.PICK, "burrow_harvesting"),
    ActionHandler(ACTIONS.DROP, "burrow_grabbing"),
    ActionHandler(ACTIONS.PICKUP, "burrow_grabbing"),
    ActionHandler(ACTIONS.ATTACK, "burrow_attack"),
}

local events = {
    EventHandler("death", function(inst)
		inst.sg:GoToState("death")
	end),
	EventHandler("locomote", function(inst, data)
        if inst.sg:HasStateTag("busy") or inst:HasTag("busy") then
            return
        end
        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        if is_moving and not should_move then
            inst.sg:GoToState("burrow_post")
        elseif not is_moving and should_move then
            inst.sg:GoToState("burrowing")
        elseif data.force_idle_state and not (is_moving or should_move or inst.sg:HasStateTag("idle")) then
            inst.sg:GoToState("idle")
		end
    end),

    EventHandler("knockback", function(inst, data)
        if inst:HasTag("burrowed") then
            inst:RemoveTag("burrowed")
        end

        inst.SoundEmitter:KillSound("move")
		inst.AnimState:SetBank("wilson")
		inst.AnimState:SetBuild("wurrow")
        inst:SetStateGraph("SGwilson")
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
			inst.AnimState:SetBank("wilson")
			inst.AnimState:SetBuild("wurrow")

			inst.SoundEmitter:KillSound("move")
			inst:SetStateGraph("SGwilson")
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

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("idle_under", true)
        end,
    },

    State {
        name = "burrow_pre",
            tags = { "moving", "canrotate", "hiding", "nomorph" },

            onenter = function(inst)
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
        name = "burrowing",
            tags = { "moving", "canrotate", "hiding", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor.walkspeed = 4
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
                inst.sg:GoToState("burrowing")
            end),
        }
    },

    State {
        name = "burrow_post",
            tags = { "canrotate", "hiding", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")
            inst.SoundEmitter:KillSound("move")
        end,

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
         },
    },

    State {
        name = "resurface",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:SetBank("wilson")
            inst.AnimState:SetBuild("wurrow")
            inst.AnimState:PlayAnimation("jumpout")

            if inst:HasTag("burrowed") then
                inst:RemoveTag("burrowed")
            end
            if inst:HasTag("bat") then
                inst:RemoveTag("bat")
            end
            if inst:HasTag("batvision") then
                inst:RemoveTag("batvision")
            end
            if not inst:HasTag("scarytoprey") then
                inst:AddTag("scarytoprey")
            end

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
                inst:SetStateGraph("SGwilson")
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
        name = "burrow_grabbing",
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
        name = "burrow_harvesting",
        tags = { "doing", "busy", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("jumpout")
			inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(25 * FRAMES)
        end,

		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            -- TimeEvent(8 * FRAMES, function(inst)
            --     inst.AnimState:PlayAnimation("jumpout")
            -- end),
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
            inst.AnimState:SetBank("wilson")
            inst.AnimState:SetBuild("wurrow")
            inst.SoundEmitter:KillSound("move")
            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(60 * FRAMES)
        end,

        timeline = {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(11 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("jumpout")
            end),
            -- TimeEvent(6 * FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound("")
            -- end),
            TimeEvent(35 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.AnimState:SetBank("mole")
            inst.AnimState:SetBuild("mole_build")
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
                inst.AnimState:SetBank("mole")
                inst.AnimState:SetBuild("mole_build")
                inst.sg:GoToState("idle")
            end
        end,

        events = {
            EventHandler("animover", function(inst)
                inst.AnimState:SetBank("mole")
                inst.AnimState:SetBuild("mole_build")
                inst.sg:GoToState("idle")
            end),
        },
    },
}

return StateGraph("wurrow", states, events, "idle", actionhandlers)