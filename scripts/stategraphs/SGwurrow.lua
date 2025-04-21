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
        tags = { "idle", "canrotate", "noattack", "burrowed" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("idle", true)
            end,
    },

    State {
        name = "burrow_pre",
            tags = { "moving", "canrotate", "noattack", "invisible", "burrowed" },

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
            tags = { "moving", "canrotate", "noattack", "burrowed" },

            onenter = function(inst)
                -- inst.AddTag("burrowed")
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
            tags = { "canrotate", "noattack", "burrowed" },

            onenter = function(inst)
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("walk_pst")
            end,

            events = {
                EventHandler("animover", function(inst)
                    inst.sg:GoToState("resurface")               
                end),
            },
    },
}
return StateGraph("wurrow", states, events, "idle")