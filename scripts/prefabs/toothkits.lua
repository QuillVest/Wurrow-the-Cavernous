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

return Toothkits("toothkit_flint", "idle_whetstone", 4, 4),
	   Toothkits("toothkit_marble", "idle_grindstone", 6, 6),
	   Toothkits("toothkit_calcite", "idle_forceps", 5, 5),
	   Toothkits("toothkit_thulecite", "idle_chisel", 8, 8),
	   Toothkits("toothkit_brightshade", "idle_sandpaper", 3, 3),
	   Toothkits("toothkit_dreadstone", "idle_toothbrush", 3, 3)