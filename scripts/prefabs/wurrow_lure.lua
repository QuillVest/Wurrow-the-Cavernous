local assets = {
    Asset("ANIM", "anim/wurrow_lure.zip"),
}

local function WurrowLure()
    local inst = CreateEntity()

    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("wurrow_lure")
    inst.AnimState:SetBuild("wurrow_lure")
    inst.AnimState:PlayAnimation("idle_flowering", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("wurrow_lure", WurrowLure, assets)