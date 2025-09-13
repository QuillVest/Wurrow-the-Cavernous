local assets = {
    Asset("ANIM", "anim/unearthed_soil.zip"),
    Asset("ATLAS", "images/inventoryimages/unearthed_soil.xml"),
    Asset("IMAGE", "images/inventoryimages/unearthed_soil.tex"),
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
    inst.components.inventoryitem.imagename = "unearthed_soil"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/unearthed_soil.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("unearthed_soil", dirt, assets)