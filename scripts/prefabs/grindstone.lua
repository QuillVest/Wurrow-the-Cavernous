local assets =
{
    Asset("ANIM", "anim/grindstone.zip"),
    Asset("MINIMAP_IMAGE", "grindstone"),
}

local prefabs =
{
    "ash",
    "collapse_small",
}

local grindstone_assets =
{
    Asset("ANIM", "anim/grindstone.zip"),
    Asset("INV_IMAGE", "grindstone_kit"),
}

---

local IMAGERANGE = 5

local function GetImageNum(inst)
    return tostring(IMAGERANGE - math.ceil(inst.components.finiteuses:GetPercent() * IMAGERANGE) + 1)
end

local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT") or nil
end

local function OnHammered(inst, worker)
    if inst.components.burnable and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    if inst:HasTag("burnt") then
        inst.components.lootdropper:SpawnLootPrefab("ash")
    else
        inst.components.lootdropper:DropLoot()
    end

    -- if inst.components.inventoryitemholder ~= nil then
    --     inst.components.inventoryitemholder:TakeItem()
    -- end

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood") -- stone

    inst:Remove()
end

local function OnHit(inst, worker)
    if inst:HasTag("burnt") then return
    end

    inst.AnimState:PlayAnimation("hit")
end

-- local function OnTurnOn(inst)
--     if inst:HasTag("burnt") then return end

--     if inst.AnimState:IsCurrentAnimation("proximity_loop") or inst.AnimState:IsCurrentAnimation("place") or inst.AnimState:IsCurrentAnimation("use") then
--         inst.AnimState:PushAnimation("proximity_loop", true)
--     else
--         inst.AnimState:PlayAnimation("proximity_loop", true)
--     end

--     if not inst.SoundEmitter:PlayingSound("loop_sound") then
--         inst.SoundEmitter:PlaySound("rifts3/sawhorse/proximity_lp", "loop_sound")
--     end
-- end

-- local function OnTurnOff(inst)
--     if not inst:HasTag("burnt") then
--         inst.AnimState:PushAnimation("idle", false)
--         inst.SoundEmitter:KillSound("loop_sound")
--         inst.SoundEmitter:PlaySound("rifts3/sawhorse/proximity_lp_pst")
--     end
-- end

local function PlayIdle(inst, push)
    if inst:HasTag("burnt") then
        return
    end

    local anim = "idle"..inst:GetImageNum()

    if push then
        inst.AnimState:PushAnimation(anim, true)
    else
        inst.AnimState:PlayAnimation(anim, true)
    end
end

local function OnUsed(inst, data)
    inst:PlayIdle()
end

local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("rifts3/sawhorse/place")
    -- inst:PlayIdle(true)
end

local function OnFinished(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle6", true)
    end

    inst:RemoveTag("grindstone")
end

local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function OnLoad(inst, data)
    if data == nil then
        return
    end

    if data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

---

-- local function OnBladeGiven(inst, item, giver)
--     if inst.components.prototyper == nil or item.blade_tech_tree == nil or item.build_override == nil then
--         if inst.components.inventoryitemholder ~= nil then
--             inst.components.inventoryitemholder:TakeItem(giver)
--         end

--         return
--     end

--     inst.components.prototyper.trees = item.blade_tech_tree

--     inst.AnimState:AddOverrideBuild(item.build_override)
-- end

-- local function OnBladeTaken(inst, item, taker)
--     if inst.components.prototyper ~= nil then
--         inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.CARPENTRY_STATION
--     end

--     if item.build_override ~= nil then
--         inst.AnimState:ClearOverrideBuild(item.build_override)
--     end
-- end

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

    inst.OnUsed = OnUsed
    inst.PlayIdle = PlayIdle
    inst.GetImageNum = GetImageNum

    inst:AddComponent("hauntable")

    local inspectable = inst:AddComponent("inspectable")
    inspectable.getstatus = GetStatus

    inst:AddComponent("lootdropper")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.GRINDSTONE_MAX_USES)
    inst.components.finiteuses:SetUses(TUNING.GRINDSTONE_MAX_USES)
    inst.components.finiteuses:SetOnFinished(OnFinished)

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(2)
    workable:SetOnFinishCallback(OnHammered)
    workable:SetOnWorkCallback(OnHit)

    -- local inventoryitemholder = inst:AddComponent("inventoryitemholder")
    -- inventoryitemholder:SetAllowedTags({ "redgem", "bluegem", "purplegem", "greengem", "yellowgem", "orangegem", "opalpreciousgem" })
    -- inventoryitemholder:SetOnItemGivenFn(OnGemGiven)
    -- inventoryitemholder:SetOnItemTakenFn(OnGemTaken)

    inst:PlayIdle()

    MakeMediumBurnable(inst, nil, nil, true, "station_parts")
    MakeSmallPropagator(inst)

    inst:ListenForEvent("onbuilt", OnBuilt)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("grindstone", fn, assets, prefabs),
MakeDeployableKitItem("grindstone_kit", "grindstone", "grindstone", "grindstone", "kit", assets),
    MakePlacer("grindstone_placer", "grindstone", "grindstone", "idle")