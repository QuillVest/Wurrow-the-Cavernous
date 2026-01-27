local function Toothkits(name, anim, max, min)
	local assets = {
		Asset("ANIM", "anim/toothkits.zip"),
	}

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		inst:AddTag("toothkit")

		MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst, "small", 0.05, {0.75, 0.4, 0.75})

		inst.AnimState:SetBuild("toothkits")
		inst.AnimState:SetBank("toothkits")
		inst.AnimState:PlayAnimation(anim)

		inst.entity:SetPristine()
		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(max)
        inst.components.finiteuses:SetUses(min)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

		MakeHauntableLaunch(inst)

		return inst
	end

	return Prefab(name, fn, assets)
end

local function Wagpunk_Toothkit(name, anim, max, min)
	local assets = {
		Asset("ANIM", "anim/toothkits.zip"),
	}

	local SWAP_DATA_BROKEN = { bank = "toothkits", anim = "scrap_broken" }
	local SWAP_DATA        = { bank = "toothkits", anim = "scrap" }

	local function OnBroken(inst)
		inst.AnimState:PlayAnimation("scrap_broken")
		inst.components.floater:SetSwapData(SWAP_DATA_BROKEN)
		inst:RemoveTag("toothkit")
		inst:AddTag("broken")
	end

	local function OnRepaired(inst)
		inst.AnimState:PlayAnimation("scrap")
		inst.components.floater:SetSwapData(SWAP_DATA)
		inst:RemoveTag("broken")
		inst:AddTag("toothkit")
	end

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		inst:AddTag("toothkit")
		inst:AddTag("show_broken_ui")

		MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst, "small", 0.05, {0.75, 0.4, 0.75})

		inst.AnimState:SetBuild("toothkits")
		inst.AnimState:SetBank("toothkits")
		inst.AnimState:PlayAnimation(anim)

		inst.entity:SetPristine()
		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(max)
        inst.components.finiteuses:SetUses(min)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

		MakeForgeRepairable(inst, FORGEMATERIALS.WAGPUNK, OnBroken, OnRepaired)
		MakeHauntableLaunch(inst)

		return inst
	end

	return Prefab(name, fn, assets)
end

return Toothkits("toothkit_stinger", "stinger", 3, 3),
	   Toothkits("toothkit_flint", "flint", 6, 6),
	   Toothkits("toothkit_calcite", "calcite", 8, 8),
	   Toothkits("toothkit_bone", "bone", 50, 50),
	   Toothkits("toothkit_thulecite", "thulecite", 15, 15),
	   Toothkits("toothkit_brightshade", "brightshade", 5, 5),
	   Toothkits("toothkit_dreadstone", "dreadstone", 5, 5),
	   Toothkits("toothkit_moonglass", "moonglass", 1, 1),
	   Wagpunk_Toothkit("toothkit_scrap", "scrap", 10, 10)