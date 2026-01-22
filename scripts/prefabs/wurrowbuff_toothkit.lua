---———————————————={ Stinger }=———————————————---
local function tkstinger_attach(inst, target)
	if target.components.combat ~= nil then
		inst:ListenForEvent("burrow", function()
			target.components.combat:SetDefaultDamage(136)
		end, target)
		inst:ListenForEvent("resurface", function()
			target.components.combat:SetDefaultDamage(10)
		end, target)
	end
end

local function tkstinger_detach(inst, target)
	if target.components.combat ~= nil and target:HasTag("burrowed") then
		target.components.combat:SetDefaultDamage(108.8)
	else
		target.components.combat:SetDefaultDamage(10)
	end
end

---———————————————={ Flint }=———————————————---
local function tkflint_attach(inst, target)
	if target.components.combat ~= nil then
		inst:ListenForEvent("burrow", function()
			target.components.combat:SetDefaultDamage(170)
		end, target)
		inst:ListenForEvent("resurface", function()
			target.components.combat:SetDefaultDamage(10)
		end, target)
	end
end

local function tkflint_detach(inst, target)
	if target.components.combat ~= nil and target:HasTag("burrowed") then
		target.components.combat:SetDefaultDamage(108.8)
	else
		target.components.combat:SetDefaultDamage(10)
	end
end

---———————————————={ Calcite }=———————————————---
local function tkcalcite_attach(inst, target)
	if target.components.combat ~= nil then
		inst:ListenForEvent("burrow", function()
			target.components.combat:SetDefaultDamage(204)
		end, target)
		inst:ListenForEvent("resurface", function()
			target.components.combat:SetDefaultDamage(10)
		end, target)
	end
end

local function tkcalcite_detach(inst, target)
	if target.components.combat ~= nil and target:HasTag("burrowed") then
		target.components.combat:SetDefaultDamage(108.8)
	else
		target.components.combat:SetDefaultDamage(10)
	end
end

---———————————————={ Bone }=———————————————---
local function tkbone_attach(inst, target)
	if target.components.combat ~= nil then
		inst:ListenForEvent("burrow", function()
			target.components.combat:SetDefaultDamage(204)
		end, target)
		inst:ListenForEvent("resurface", function()
			target.components.combat:SetDefaultDamage(10)
		end, target)
	end
end

local function tkbone_detach(inst, target)
	if target.components.combat ~= nil and target:HasTag("burrowed") then
		target.components.combat:SetDefaultDamage(108.8)
	else
		target.components.combat:SetDefaultDamage(10)
	end
end

---———————————————={ Thulecite }=———————————————---
local function tkthulecite_attach(inst, target)
	if target.components.combat ~= nil then
		inst:ListenForEvent("burrow", function()
			target.components.combat:SetDefaultDamage(238)
		end, target)
		inst:ListenForEvent("resurface", function()
			target.components.combat:SetDefaultDamage(10)
		end, target)
	end
end

local function tkthulecite_detach(inst, target)
	if target.components.combat ~= nil and target:HasTag("burrowed") then
		target.components.combat:SetDefaultDamage(108.8)
	else
		target.components.combat:SetDefaultDamage(10)
	end
end

---———————————————={ Brightshade }=———————————————---
local function tkbrightshade_attach(inst, target)
	if target.components.combat ~= nil then
		inst:ListenForEvent("burrow", function()
			target.components.combat:SetDefaultDamage(238)
		end, target)
		inst:ListenForEvent("resurface", function()
			target.components.combat:SetDefaultDamage(10)
		end, target)
	end
end

local function tkbrightshade_detach(inst, target)
	if target.components.combat ~= nil and target:HasTag("burrowed") then
		target.components.combat:SetDefaultDamage(108.8)
	else
		target.components.combat:SetDefaultDamage(10)
	end
end

---———————————————={ Dreadstone }=———————————————---
local function tkdreadstone_attach(inst, target)
	if target.components.combat ~= nil then
		inst:ListenForEvent("burrow", function()
			target.components.combat:SetDefaultDamage(238)
		end, target)
		inst:ListenForEvent("resurface", function()
			target.components.combat:SetDefaultDamage(10)
		end, target)
	end
end

local function tkdreadstone_detach(inst, target)
	if target.components.combat ~= nil and target:HasTag("burrowed") then
		target.components.combat:SetDefaultDamage(108.8)
	else
		target.components.combat:SetDefaultDamage(10)
	end
end

---———————————————={ Moonglass }=———————————————---
local function tkmoonglass_attach(inst, target)
	if target.components.combat ~= nil then
		inst:ListenForEvent("burrow", function()
			target.components.combat:SetDefaultDamage(272)
		end, target)
		inst:ListenForEvent("resurface", function()
			target.components.combat:SetDefaultDamage(10)
		end, target)
	end
end

local function tkmoonglass_detach(inst, target)
	if target.components.combat ~= nil and target:HasTag("burrowed") then
		target.components.combat:SetDefaultDamage(108.8)
	else
		target.components.combat:SetDefaultDamage(10)
	end
end

---———————————————={ Scrap }=———————————————---
local function tkscrap_attach(inst, target)
	if target.components.combat ~= nil then
		inst:ListenForEvent("burrow", function()
			target.components.combat:SetDefaultDamage(272)
		end, target)
		inst:ListenForEvent("resurface", function()
			target.components.combat:SetDefaultDamage(10)
		end, target)
	end
end

local function tkscrap_detach(inst, target)
	if target.components.combat ~= nil and target:HasTag("burrowed") then
		target.components.combat:SetDefaultDamage(108.8)
	else
		target.components.combat:SetDefaultDamage(10)
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

return
	MakeBuff("tkstinger", tkstinger_attach, nil, tkstinger_detach, 60),
	MakeBuff("tkflint", tkflint_attach, nil, tkflint_detach, 60),
	MakeBuff("tkcalcite", tkcalcite_attach, nil, tkcalcite_detach, 60),
	MakeBuff("tkbone", tkbone_attach, nil, tkbone_detach, 60),
	MakeBuff("tkthulecite", tkthulecite_attach, nil, tkthulecite_detach, 60),
	MakeBuff("tkbrightshade", tkbrightshade_attach, nil, tkbrightshade_detach, 60),
	MakeBuff("tkdreadstone", tkdreadstone_attach, nil, tkdreadstone_detach, 60),
	MakeBuff("tkmoonglass", tkmoonglass_attach, nil, tkmoonglass_detach, 60),
	MakeBuff("tkscrap", tkscrap_attach, nil, tkscrap_detach, 60)
