local assets =
{
    Asset("ANIM", "anim/grindstone.zip"),
    Asset("MINIMAP_IMAGE", "grindstone"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1.25)
    inst:SetPhysicsRadiusOverride(0.5)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.MiniMapEntity:SetIcon("grindstone.png")

    inst:AddTag("structure")
    inst:AddTag("grindstone")

    inst.AnimState:SetBank("grindstone")
    inst.AnimState:SetBuild("grindstone")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    local hauntable = inst:AddComponent("hauntable")
    hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    local inspectable = inst:AddComponent("inspectable")
    inspectable.getstatus = GetStatus

    inst:AddComponent("lootdropper")

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(2)
    workable:SetOnFinishCallback(OnHammered)
    workable:SetOnWorkCallback(OnHit)

    local inventoryitemholder = inst:AddComponent("inventoryitemholder")
    inventoryitemholder:SetAllowedTags({ "redgem", "bluegem", "purplegem", "greengem", "yellowgem", "orangegem", "opalpreciousgem" })
    inventoryitemholder:SetOnItemGivenFn(OnGemGiven)
    inventoryitemholder:SetOnItemTakenFn(OnGemTaken)

    MakeMediumBurnable(inst, nil, nil, true, "station_parts")
    MakeSmallPropagator(inst)

    inst:ListenForEvent("onbuilt", OnBuilt)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("grindstone", fn, assets, prefabs),
    MakePlacer("grindstone_placer", "grindstone", "grindstone", "idle")