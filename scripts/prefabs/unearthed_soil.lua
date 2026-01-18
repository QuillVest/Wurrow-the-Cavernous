local assets = {
    Asset("ANIM", "anim/unearthed_soil.zip"),
}

local function dirt(inst)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("unearthed_soil")
    inst.AnimState:SetBuild("unearthed_soil")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.05, {0.75, 0.4, 0.75})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("furgel")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("unearthed_soil", dirt, assets)