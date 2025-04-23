---@diagnostic disable: undefined-global, syntax-error
require("stategraphs/commonstates")

local WALK_SPEED = 4
local RUN_SPEED = 6

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
        if data then
            inst:SetStateGraph("SGwilson")
            inst.sg:GoToState((data.forcelanded or inst.components.inventory:EquipHasTag("heavyarmor") or inst:HasTag("heavybody")) and "knockbacklanded" or "knockback", data)
        end
    end)
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
        tags = { "idle", "canrotate", "noattack" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("idle_under", true)
        end,
    },

    State {
        name = "burrow_pre",
            tags = { "moving", "canrotate", "noattack", "invisible" },

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
        tags = { "moving", "canrotate", "noattack" },

        onenter = function(inst)
            inst.components.locomotor.walkspeed = 4
            inst.AnimState:PlayAnimation("walk_loop")
            inst.components.locomotor:WalkForward()
        end,

        timeline = {
            TimeEvent(0*FRAMES,  SpawnMoveFx),
            TimeEvent(5*FRAMES,  SpawnMoveFx),
            TimeEvent(10*FRAMES, SpawnMoveFx),
            TimeEvent(15*FRAMES, SpawnMoveFx),
            TimeEvent(20*FRAMES, SpawnMoveFx),
            TimeEvent(25*FRAMES, SpawnMoveFx),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("burrowing")
            end),
        }
    },

    State {
        name = "burrow_post",
        tags = { "canrotate", "noattack" },

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
                inst.components.health:SetInvincible(false)
                inst.components.moisture.inherentWaterproofness = 0
                inst:SetStateGraph("SGwilson")
                inst.sg:GoToState("idle")
            end
        end),
        },
    },
    -- State = {
    --     name = "resurface",
    --     tags = { "doing", "busy" },
    --     server_states = { "burrow", "resurface" },
    
    --     onenter = function(inst)
    --         inst.components.locomotor:StopMoving()
    --         inst.AnimState:SetBank("wilson")
    --         inst.AnimState:SetBuild("wurrow")
    --         inst.AnimState:PlayAnimation("jumpout")
    
    --         inst:PerformPreviewBufferedAction()
    --         inst.sg:SetTimeout(2)
    --     end,
    
    --     onupdate = function(inst)
    --         if inst.sg:ServerStateMatches() then
    --             if inst.entity:FlattenMovementPrediction() then
    --                 inst.sg:GoToState("idle", "noanim")
    --             end
    --         elseif inst.bufferedaction == nil then
    --             inst.sg:GoToState("idle")
    --         end
    --     end,
    
    --     ontimeout = function(inst)
    --         inst:ClearBufferedAction()
    --         inst.sg:GoToState("idle")
    --     end
    -- },
}
return StateGraph("wurrow", states, events, "idle")