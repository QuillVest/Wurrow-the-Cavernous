local assets = {
    Asset("ANIM", "anim/wurrow_burrow.zip"),
}

local function fn()
	local inst = CreateEntity()

    inst.persists = false
    
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("wurrow_burrow")
    inst.AnimState:SetBuild("wurrow_burrow")
    inst.AnimState:PlayAnimation("mound_out")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    return inst
end

return Prefab("wurrow_burrow", fn, prefabs)