local function gel_attach(inst, target)
	if target.components.combat ~= nil then
		inst:ListenForEvent("burrow", function()
            if TheWorld:HasTag("cave") then
			    target.components.locomotor:SetExternalSpeedMultiplier(target, "gel_ms", 1.10)
				-- target.components.locomotor.walkspeed = 8.4
            else
                target.components.locomotor:SetExternalSpeedMultiplier(target, "gel_ms", 1.05)
				-- target.components.locomotor.walkspeed = 7.5
            end
		end, target)
		inst:ListenForEvent("resurface", function()
			target.components.locomotor:RemoveExternalSpeedMultiplier(target, "gel_ms")
		end, target)
	end
end

local function gel_detach(target)
	if target.components.combat ~= nil and target:HasTag("burrowed") then
		target.components.locomotor:RemoveExternalSpeedMultiplier(target, "gel_ms")
    end
end

local function OnTimerDone(inst, data)
	if data.name == "buffover" then
		inst.components.debuff:Stop()
	end
end

local function MakeBuff(name, onattachedfn, onextendedfn, ondetachedfn, duration)
	local function OnAttached(inst, target)
		inst.entity:SetParent(target.entity)
		inst.Transform:SetPosition(0, 0, 0)
		inst:ListenForEvent("death", function()
			inst.components.debuff:Stop()
		end, target)

		if onattachedfn ~= nil then
			onattachedfn(inst, target)
		end
	end

	local function OnExtended(inst, target)
		inst.components.timer:StopTimer("buffover")
		inst.components.timer:StartTimer("buffover", duration)

		if onextendedfn ~= nil then
			onextendedfn(inst, target)
		end
	end

	local function OnDetached(inst, target)
		if ondetachedfn ~= nil then
			ondetachedfn(inst, target)
		end
		
		inst:Remove()
	end

	local function fn()
		local inst = CreateEntity()

		if not TheWorld.ismastersim then
			inst:DoTaskInTime(0, inst.Remove)
			return inst
		end

		inst.entity:AddTransform()

		inst.entity:Hide()
		inst.persists = false

		inst:AddTag("CLASSIFIED")

		inst:AddComponent("debuff")
		inst.components.debuff:SetAttachedFn(OnAttached)
		inst.components.debuff:SetDetachedFn(OnDetached)
		inst.components.debuff:SetExtendedFn(OnExtended)
		inst.components.debuff.keepondespawn = true

		inst:AddComponent("timer")
		inst.components.timer:StartTimer("buffover", duration)
		inst:ListenForEvent("timerdone", OnTimerDone)

		return inst
	end

	return Prefab("buff_"..name, fn)
end

return MakeBuff("gelled", gel_attach, nil, gel_detach, 60)