local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local events = {
	EventHandler("startstarving", function(inst)
		if inst:HasTag("burrowed") then
			inst.sg:GoToState("resurface")
			inst.components.talker:Say("Me hungy :(")
		end
	end),
}

local function SpawnMoveFx(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("mole_move_fx").Transform:SetPosition(x, y, z)
end

local states = {
---———————————————={ Burrow Locomotion }=———————————————---
	State{
		name = "burrow_pre",
		tags = {"moving", "canrotate", "hiding", "nomorph"},
		
		onenter = function(inst)
			inst.components.hunger.burnratemodifiers:SetModifier(inst, 4, "burrowingpenalty")
			inst.AnimState:PlayAnimation("walk_pre")
			inst.components.locomotor:WalkForward()
		end,
		
		events = {
			EventHandler("animover", function(inst)
				local x, y, z = inst.Transform:GetWorldPosition()
    			if TheWorld.Map:GetTileAtPoint(x, y, z) == WORLD_TILES.FARMING_SOIL then
					inst.sg:GoToState("burrow_loop_till")
				else
				inst.sg:GoToState("burrow_loop")
				end
			end),
		}
	},
	
	State{
		name = "burrow_loop",
		tags = {"moving", "canrotate", "hiding", "nomorph"},

		onenter = function(inst)
			local treasure_config = TUNING.WURROW_MODCONFIGDATA["Burrow_Treasure"]
			local frequency = TUNING.WURROW_MODCONFIGDATA["Treasure_Frequency"]

			if treasure_config == 1 then
				if not inst.components.timer:TimerExists("treasure_drop") then
					inst.components.timer:StartTimer("treasure_drop", frequency)
				else
					inst.components.timer:ResumeTimer("treasure_drop")
				end
			end

			inst.AnimState:PlayAnimation("walk_loop")
			inst.components.locomotor:WalkForward()
		end,

		timeline = {
			TimeEvent(1 * FRAMES, 	SpawnMoveFx),
			TimeEvent(6 * FRAMES, 	SpawnMoveFx),
			TimeEvent(11 * FRAMES, 	SpawnMoveFx),
			TimeEvent(16 * FRAMES, 	SpawnMoveFx),
			TimeEvent(21 * FRAMES, 	SpawnMoveFx),
			TimeEvent(26 * FRAMES, 	SpawnMoveFx),
		},

		events = {
			EventHandler("animover", function(inst)
				local x, y, z = inst.Transform:GetWorldPosition()
    			if TheWorld.Map:GetTileAtPoint(x, y, z) == WORLD_TILES.FARMING_SOIL then
					inst.sg:GoToState("burrow_loop_till")
				else
				inst.sg:GoToState("burrow_loop")
				end
			end),
		}
	},

	State{
		name = "burrow_loop_till",
		tags = {"moving", "canrotate", "hiding", "nomorph"},
		
		onenter = function(inst)
			local treasure_config = TUNING.WURROW_MODCONFIGDATA["Burrow_Treasure"]
			local frequency = TUNING.WURROW_MODCONFIGDATA["Treasure_Frequency"]

			if treasure_config == 1 then
				if not inst.components.timer:TimerExists("treasure_drop") then
					inst.components.timer:StartTimer("treasure_drop", frequency)
				else
					inst.components.timer:ResumeTimer("treasure_drop")
				end
			end

			inst.AnimState:PlayAnimation("walk_loop")
			inst.components.locomotor:WalkForward()
			inst.components.locomotor.walkspeed = 4
		end,
		
		timeline = {
			FrameEvent(0, function(inst)
				SpawnAt("farm_soil", inst)
			end)
		},
		
		events = {
			EventHandler("animover", function(inst)
				local x, y, z = inst.Transform:GetWorldPosition()
    			if TheWorld.Map:GetTileAtPoint(x, y, z) == WORLD_TILES.FARMING_SOIL then
					inst.sg:GoToState("burrow_loop_till")
				else
				inst.sg:GoToState("burrow_loop")
				end
			end),
		}
	},
	
	State {
		name = "burrow_pst",
		tags = {"canrotate", "hiding", "nomorph"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("walk_pst")
			inst.SoundEmitter:KillSound("move")
			inst.components.locomotor:StopMoving()
		end,
		
		events = {
			EventHandler("animover", function(inst)

			if inst.components.timer:TimerExists("treasure_drop") and not inst.components.timer:IsPaused("treasure_drop") then
				inst.components.timer:PauseTimer("treasure_drop")
			end

			inst.components.hunger.burnratemodifiers:SetModifier(inst, 2, "burrowingpenalty")
				inst.sg:GoToState("idle")
			end),
		},
	},
	
	State {
		name = "burrow_idle",
		tags = {"idle", "canrotate"},
		
		onenter = function(inst)
			-- if inst.sg.lasttags and not inst.sg.lasttags["busy"] then
			-- 	inst.components.locomotor:StopMoving()
			-- else
			-- 	inst.components.locomotor:Stop()
			-- 	inst.components.locomotor:Clear()
			-- end
			inst:ClearBufferedAction()
			
			local drownable = inst.components.drownable
			if drownable then
				local fallingreason = drownable:GetFallingReason()
				
				if fallingreason == FALLINGREASON.OCEAN then
					inst.sg:GoToState("sink_fast")
					return
				elseif fallingreason == FALLINGREASON.VOID then
					inst.sg:GoToState("abyss_fall")
					return
				end
			end
		end,
	},
	
---———————————————={ Burrow / Resurface }=———————————————---
	State{
		name = "burrow",
		tags = {"doing", "busy"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("jump", false)
			inst.DynamicShadow:Enable(false)
			inst.components.locomotor:Stop()
			inst:RemoveTag("scarytoprey")
			inst.components.locomotor:SetTriggersCreep(false)

			if TheWorld:HasTag("cave") then
       			inst.components.locomotor.walkspeed = 7.5
    		else
				inst.components.locomotor.walkspeed = 6.9
			end
			
			local buffaction = inst:GetBufferedAction()
			if buffaction and buffaction.pos then
				inst:ForceFacePoint(buffaction:GetActionPoint():Get())
			end
		end,

		timeline = {
			TimeEvent(15 * FRAMES, function(inst)
				inst.Physics:Stop()
			end),
			FrameEvent(17, function(inst)
				local x, y, z = inst.Transform:GetWorldPosition()
				local platform = inst:GetCurrentPlatform()

				if not (platform ~= nil and TheWorld.Map:IsOceanTileAtPoint(x, y, z)) then
					SpawnAt("dirt_puff", inst)
				end
			end),
			TimeEvent(17 * FRAMES, function(inst)
				inst.components.hunger:DoDelta(-2.5)
			end),
			FrameEvent(21, function(inst)
				local x, y, z = inst.Transform:GetWorldPosition()
				local platform = inst:GetCurrentPlatform()
				
				if platform ~= nil and TheWorld.Map:IsOceanTileAtPoint(x, y, z) then
					platform.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
					platform:PushEvent("spawnnewboatleak", {pt = inst:GetPosition(), leak_size = "med_leak"})
					inst:ShowHUD(false)
				end
			end),
		},

		events = {
			EventHandler("animover", function(inst)
				local inventory = inst.components.inventory

				-- inst.AnimState:PlayAnimation("idle_flowering", true)

				if inst.AnimState:AnimDone() then
					inst:Hide()
					local x, y, z = inst.Transform:GetWorldPosition()
					local platform = inst:GetCurrentPlatform()

					if platform ~= nil and TheWorld.Map:IsOceanTileAtPoint(x, y, z) then
						inst:DoTaskInTime(1, function() inst.sg:GoToState("sink_instant") end)
						return
					end

					inst:PushEvent("dropallaggro")
					inventory:Equip(SpawnPrefab("wurrow_handslot"))
					inst.components.moisture.inherentWaterproofness = 1000

					inst.components.combat:SetDefaultDamage(108.8)
					inst:PushEvent("burrow")
					inst.components.hunger.burnratemodifiers:SetModifier(inst, 2, "burrowingpenalty")
					inst.components.temperature.mintemp = 3
					inst.components.temperature.maxtemp = 65
					inst:AddTag("burrowed")
					inst:AddTag("bear_trap_immune")

					if inst.components.sandstormwatcher then
						inst.components.sandstormwatcher:SetSandstormSpeedMultiplier(1)
					end

					inst.sg:GoToState("burrow_idle")
				end
			end)
		},
	},

	State {
		name = "resurface",
		tags = {"doing", "busy"},

		onenter = function(inst, ba)
			inst:Show()
			inst.AnimState:PlayAnimation("jumpout")
			inst.components.locomotor:StopMoving()
			inst.components.locomotor:SetTriggersCreep(true)
			inst:AddTag("scarytoprey")
			inst:RemoveTag("burrowed")
			inst:RemoveTag("bear_trap_immune")

			inst.components.locomotor.walkspeed = 6

			local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equip and equip.prefab == "wurrow_handslot" then 
				equip:Remove()
			end
			
			local buffaction = ba or inst:GetBufferedAction()
			inst.sg.statemem.retry_ba = ba
			
			if buffaction and buffaction.pos then
				inst:ForceFacePoint(buffaction:GetActionPoint():Get())
			end
		end,
		
		timeline = {
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
					inst.components.combat:SetDefaultDamage(10)
					inst.components.hunger.burnratemodifiers:RemoveModifier(inst, "burrowingpenalty")
					
					if inst.components.timer:TimerExists("treasure_drop") and not inst.components.timer:IsPaused("treasure_drop") then
						inst.components.timer:PauseTimer("treasure_drop")
					end
					
					if inst.components.sandstormwatcher then
						inst.components.sandstormwatcher:SetSandstormSpeedMultiplier(TUNING.SANDSTORM_SPEED_MOD)
					end
					
					inst.components.temperature.mintemp = TUNING.MIN_ENTITY_TEMP
					inst.components.temperature.maxtemp = TUNING.MAX_ENTITY_TEMP
					
					if inst.sg.statemem.retry_ba then
						inst.components.locomotor:PushAction(inst.sg.statemem.retry_ba)
					end
					
					if inst.sg.currentstate.name == "resurface" then
						inst.sg:GoToState("idle")
					end
				end
			end),
		},
	},

---———————————————={ Burrow Actions }=———————————————---
	State {
		name = "burrow_drop",
		tags = {"doing", "busy", "noattack"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.SoundEmitter:KillSound("move")
			inst.sg.statemem.action = inst.bufferedaction
			inst.sg:SetTimeout(10 * FRAMES)
		end,

		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			FrameEvent(3, function(inst)
				SpawnAt("shovel_dirt", inst)
			end),
			TimeEvent(6 * FRAMES, function(inst)
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
		tags = {"doing", "busy", "noattack"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.SoundEmitter:KillSound("move")
			inst.sg.statemem.action = inst.bufferedaction
			inst.sg:SetTimeout(10 * FRAMES)
		end,
		
		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			FrameEvent(3, function(inst)
				SpawnAt("shovel_dirt", inst)
			end),
			TimeEvent(6 * FRAMES, function(inst)
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
		tags = {"doing", "busy", "noattack"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.SoundEmitter:KillSound("move")
			inst.AnimState:PlayAnimation("wurrow_harvesting")
			inst.AnimState:PushAnimation("wurrow_harvesting")
			inst.sg.statemem.action = inst.bufferedaction
			inst.sg:SetTimeout(15 * FRAMES)
		end,
		
		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			TimeEvent(12 * FRAMES, function(inst)
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
		tags = {"doing", "busy", "noattack"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.SoundEmitter:KillSound("move")
			inst.AnimState:PlayAnimation("wurrow_harvesting")
			inst.AnimState:PushAnimation("wurrow_harvesting")
			inst.sg.statemem.action = inst.bufferedaction
			inst.sg:SetTimeout(15 * FRAMES)
		end,
		
		timeline = {
			TimeEvent(4 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			FrameEvent(6, function(inst)
				SpawnAt("dirt_puff", inst)
			end),
			TimeEvent(6 * FRAMES, function(inst)
				inst.components.hunger:DoDelta(-1)
			end),
			TimeEvent(10 * FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
			TimeEvent(10 * FRAMES, 	SpawnMoveFx),
			TimeEvent(12 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
			end),
			FrameEvent(15, function(inst)
				SpawnAt("shovel_dirt", inst)
			end),
		},

		events = {
			EventHandler("animover", function(inst)
	
				inst.sg:GoToState("idle")
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
		tags = {"doing", "busy", "noattack"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.SoundEmitter:KillSound("move")
			inst.sg.statemem.action = inst.bufferedaction
			inst.sg:SetTimeout(36 * FRAMES)
		end,
		
		timeline = {
			TimeEvent(9 * FRAMES, 	SpawnMoveFx),
			FrameEvent(14, function(inst)
				SpawnAt("dirt_puff", inst)
			end),
			TimeEvent(16 * FRAMES, function(inst)
				inst:Show()
			end),
			FrameEvent(16, function(inst)
				inst.sg:RemoveStateTag("noattack")
			end),
			TimeEvent(16 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("jumpout")
			end),
			FrameEvent(20, function(inst)
				inst.sg:RemoveStateTag("noattack")
			end),
			TimeEvent(26 * FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
			FrameEvent(32, function(inst)
				SpawnAt("shovel_dirt", inst)
			end),
			TimeEvent(36 * FRAMES, function(inst)
				inst:Hide()
			end),
			FrameEvent(36, function(inst)
				inst.sg:AddStateTag("noattack")
			end),
		},
		
		ontimeout = function(inst)
			inst:Hide()
			inst:PushEvent("dropallaggro")
			inst.sg:GoToState("idle", true)
		end,
		
		onexit = function(inst)
			if inst.bufferedaction == inst.sg.statemem.action then
				inst:ClearBufferedAction()
				inst:Hide()
				inst:PushEvent("dropallaggro")
				inst.sg:GoToState("idle")
			end
		end,
		
		events = {
			EventHandler("animover", function(inst)
				inst:PushEvent("dropallaggro")
				inst.sg:GoToState("idle")
			end),
		},
	},
}

ENV.AddStategraphPostInit("wilson", function(sg)
	for _, event in pairs(events) do
		sg.events[event.name] = event
	end
	
	for _, state in pairs(states) do
		sg.states[state.name] = state
	end
	
---———————————————={ Burrow Events }=———————————————---
	local oldlocomote = sg.events["locomote"].fn
	sg.events["locomote"].fn = function(inst, ...)
		if not inst:HasTag("burrowed") then
			return oldlocomote(inst, ...)
		end
		
		local is_idling = inst.sg:HasStateTag("idle")
		local is_moving = inst.sg:HasStateTag("moving")
		local should_move = inst.components.locomotor:WantsToMoveForward()
		
		if is_moving and not should_move then
			inst.sg:GoToState("burrow_pst")
		elseif is_idling and should_move then
			inst.sg:GoToState("burrow_pre")
		end
	end
	
	local olddeath = sg.events["death"].fn
	sg.events["death"].fn = function(inst, ...)
		if inst.prefab == "wurrow" then
			inst:Show()
			inst:RemoveTag("burrowed")
		end
		
		return olddeath(inst, ...)
	end
	
	local oldknockback = sg.events["knockback"].fn
	sg.events["knockback"].fn = function(inst, ...)
		if inst.prefab == "wurrow" then
			inst:Show()
			inst:RemoveTag("burrowed")
		end
		
		return oldknockback(inst, ...)
	end
	
---———————————————={ Burrow ActionHandlers }=———————————————---
	local burrow_attack = sg.actionhandlers[ACTIONS.ATTACK].deststate
	sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip and equip.prefab == "wurrow_handslot" and inst:HasTag("burrowed") then
			return "burrow_attack"
		end
		
		return burrow_attack(inst, action, ...)
	end
	
	local burrow_drop = sg.actionhandlers[ACTIONS.DROP].deststate
	sg.actionhandlers[ACTIONS.DROP].deststate = function(inst, action, ...)
		if inst:HasTag("burrowed") then
			return ("burrow_drop")
		end
		
		return burrow_drop(inst, action, ...)
	end
	
	local burrow_pickup = sg.actionhandlers[ACTIONS.PICKUP].deststate
	sg.actionhandlers[ACTIONS.PICKUP].deststate = function(inst, action, ...)
		if inst:HasTag("burrowed") then
			return ("burrow_pickup")
		end
		
		return burrow_pickup(inst, action, ...)
	end
	
	local burrow_pick = sg.actionhandlers[ACTIONS.PICK].deststate
	sg.actionhandlers[ACTIONS.PICK].deststate = function(inst, action, ...)
		if inst:HasTag("burrowed") then
			return ("burrow_pick")
		end
		
		return burrow_pick(inst, action, ...)
	end
	
	local burrow_dig = sg.actionhandlers[ACTIONS.DIG].deststate
	sg.actionhandlers[ACTIONS.DIG].deststate = function(inst, action, ...)
		if inst:HasTag("burrowed") then
			return ("burrow_dig")
		end
		
		return burrow_dig(inst, action, ...)
	end
	
	local oldidle = sg.states["idle"].onenter
	sg.states["idle"].onenter = function(inst, ...)
		if inst:HasTag("burrowed") then
			inst.sg:GoToState("burrow_idle")
		else
			oldidle(inst, ...)
		end
	end
end)

local states_client = {
	State{
		name = "burrow",
		tags = {"doing", "busy"},
		server_states = {"burrow", "resurface"},
		
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
	},
	
	State{
		name = "resurface",
		tags = {"doing", "busy"},
		
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("jumpout")
			
			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(2)
		end,
		
		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.sg:GoToState("idle")
		end
	},
}

ENV.AddStategraphPostInit("wilson_client", function(sg)
	for _, state in pairs(states_client) do
		sg.states[state.name] = state
	end
end)