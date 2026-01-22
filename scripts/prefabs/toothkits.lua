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

return Toothkits("toothkit_flint", "flint", 5, 5),
	   Toothkits("toothkit_stinger", "stinger", 7, 7),
	   Toothkits("toothkit_calcite", "calcite", 8, 8),
	   Toothkits("toothkit_bone", "bone", 25, 25),
	   Toothkits("toothkit_thulecite", "thulecite", 10, 10),
	   Toothkits("toothkit_brightshade", "brightshade", 5, 5),
	   Toothkits("toothkit_dreadstone", "dreadstone", 5, 5),
	   Toothkits("toothkit_moonglass", "moonglass", 2, 2),
	   Toothkits("toothkit_scrap", "scrap", 100, 100)