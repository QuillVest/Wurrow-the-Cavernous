local assets = {
    Asset("ANIM", "anim/sewing_kit.zip"),
    Asset("ATLAS", "images/inventoryimages/toothkit_flint.xml"),
    Asset("IMAGE", "images/inventoryimages/toothkit_flint.tex"),
}

local function fn(inst)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sewing_kit")
    inst.AnimState:SetBuild("sewing_kit")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.05, {0.75, 0.4, 0.75})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "toothkit_flint"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/toothkit_flint.xml"

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(10)
    inst.components.finiteuses:SetUses(10)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("toothkit_flint", fn, assets)