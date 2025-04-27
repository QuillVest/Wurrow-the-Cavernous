local assets = {
    Asset("ANIM", "anim/sewing_kit.zip"),
    Asset("ATLAS", "images/tooth_kit.xml"),
    Asset("IMAGE", "images/tooth_kit.tex"),
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

    MakeInventoryFloatable(inst, "small", 0.05, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst:AddComponent("finiteuses")
    -- inst.components.finiteuses:SetMaxUses(TUNING.SEWINGKIT_USES)
    -- inst.components.finiteuses:SetUses(TUNING.SEWINGKIT_USES)
    -- inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "tooth_kit"
    inst.components.inventoryitem.atlasname = "images/tooth_kit.xml"

    inst:AddComponent("shaver")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("tooth_kit", fn, assets)