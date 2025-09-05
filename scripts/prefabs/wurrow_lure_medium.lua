local assets = {
    Asset("ANIM", "anim/wurrow_lure_medium.zip"),
}

local function fn(inst)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("wurrow_lure_medium")
    inst.AnimState:SetBuild("wurrow_lure_medium")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wurrow_lure", fn, assets)