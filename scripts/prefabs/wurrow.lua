---@diagnostic disable: undefined-global, syntax-error
local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset( "ANIM", "anim/beard_wurrow.zip" ),
}

local prefabs =
{
    "wormlight",
    "wormlight_lesser",
}

------------------------------------------------------------------------------------------------------------

local function OnResetBeard(inst)
    inst.AnimState:ClearOverrideSymbol("beard")
end

local BEARD_DAYS = { 4, 8, 12 }
local BEARD_BITS = { 1, 1, 1 }

local function OnGrowShortBeard(inst, skinname)
    if skinname == nil then
        inst.AnimState:OverrideSymbol("beard", "beard_wurrow", "beard_short")
    else
        inst.AnimState:OverrideSkinSymbol("beard", skinname, "beard_short" )
    end
    inst.components.beard.bits = BEARD_BITS[1]
end

local function OnGrowMediumBeard(inst, skinname)
    if skinname == nil then
        inst.AnimState:OverrideSymbol("beard", "beard_wurrow", "beard_medium")
    else
        inst.AnimState:OverrideSkinSymbol("beard", skinname, "beard_medium" )
    end
    inst.components.beard.bits = BEARD_BITS[1]
end

local function OnGrowLongBeard(inst, skinname)
    if skinname == nil then
        inst.AnimState:OverrideSymbol("beard", "beard_wurrow", "beard_long")
    else
        inst.AnimState:OverrideSkinSymbol("beard", skinname, "beard_long" )
    end
    inst.components.beard.bits = BEARD_BITS[1]
end

------------------------------------------------------------------------------------------------------------

local function CanDig(pt)
    return TheWorld.Map:IsPassableAtPoint(pt:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local function CanTunnelToCave(pt)
    return true
end

local function ReticuleTargetFn(inst)
    return ControllerReticle_Blink_GetPosition(inst, inst.CanDig)
end

local function CanBurrow(inst)
    return true
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right and useitem == nil then
        local candig
        if inst.checkingmapactions then
            candig = inst.CanTunnelToCave(inst:GetPosition())
        else
            candig = inst.CanDig(pos)
        end
        if candig then
            return { ACTIONS.BURROW }
        end
    end
    return {}
end

local function OnSetOwner(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
    end
end

------------------------------------------------------------------------------------------------------------

TUNING.WURROW_HEALTH = 175
TUNING.WURROW_HUNGER = 225
TUNING.WURROW_SANITY = 125

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WURROW = {
	"slurper_pelt",
	"slurper_pelt",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WURROW
end
local prefabs = FlattenTree(start_inv, true)

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wurrow_speed_mod", 1)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wurrow_speed_mod")
end

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end

local function CustomSanityFn(inst, dt)
    if TheWorld.state.isday and not TheWorld:HasTag("cave") then
        return -(5 / (TUNING.SEG_TIME * 2))
    end
    return 0
end

------------------------------------------------------------------------------------------------------------

local common_postinit = function(inst) 
	inst:AddTag("monster")
	inst:AddTag("worm")
	inst:AddTag("nowormholesanityloss")
	inst:AddTag("cavedweller")
	inst:AddTag("nightvision")
    inst:AddTag("wurrow")
	inst:AddTag("bearded")
    inst:AddTag("acidrainimmune")

	inst.MiniMapEntity:SetIcon( "wurrow.tex" )

    inst.CanBurrow = CanBurrow
    inst.CanDig = CanDig
    inst.CanTunnelToCave = CanTunnelToCave

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true
end

------------------------------------------------------------------------------------------------------------

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	inst.components.combat.shouldavoidaggrofn = function(attacker, inst) return attacker.prefab ~= 'worm' end
	inst.components.combat.shouldavoidaggrofn = function(attacker, inst) return attacker.prefab ~= 'worm_boss' end

    inst:AddComponent("acidinfusible")
    inst.components.acidinfusible:SetFXLevel(1)
    inst.components.acidinfusible:SetMultipliers(TUNING.ACID_INFUSION_MULT.BERSERKER)

	inst.soundsname = "wormwood"
	
	inst.components.health:SetMaxHealth(TUNING.WURROW_HEALTH)
	inst.components.hunger:SetMax(TUNING.WURROW_HUNGER)
	inst.components.sanity:SetMax(TUNING.WURROW_SANITY)
	
    inst.components.combat.damagemultiplier = 1
	
	inst.components.hunger.hungerrate = 1.5 * TUNING.WILSON_HUNGER_RATE

	inst.components.foodaffinity:AddPrefabAffinity("unagi", TUNING.AFFINITY_15_CALORIES_LARGE)

	local foodaffinity = inst.components.foodaffinity
	foodaffinity:AddPrefabAffinity  ("wormlight",            1.0)
	foodaffinity:AddPrefabAffinity  ("wormlight_lesser",     1.0)
	foodaffinity:AddPrefabAffinity  ("cutlichen",            1.0)

	inst.components.eater:SetDiet({ FOODTYPE.VEGGIE, FOODTYPE.BERRY, FOODTYPE.SEEDS, FOODTYPE.MEAT })
	if inst.components.eater ~= nil then
        inst.components.eater:SetStrongStomach(true)
        inst.components.eater:SetCanEatRawMeat(true)
    end

	inst:AddComponent("beard")
    inst.components.beard.onreset = OnResetBeard
    inst.components.beard.prize = "wormlight"
    inst.components.beard.is_skinnable = true
    inst.components.beard:AddCallback(BEARD_DAYS[1], OnGrowShortBeard)
    inst.components.beard:AddCallback(BEARD_DAYS[2], OnGrowMediumBeard)
    inst.components.beard:AddCallback(BEARD_DAYS[3], OnGrowLongBeard)
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload

	inst.components.sanity.custom_rate_fn = CustomSanityFn
    
	inst.components.sanity:SetLightDrainImmune(true)
	
	inst.components.sanity.no_moisture_penalty = true
	
	inst.components.sanity:AddSanityAuraImmunity("worm")
	inst.components.sanity:AddSanityAuraImmunity("worm_boss")
end

return MakePlayerCharacter("wurrow", prefabs, assets, common_postinit, master_postinit, prefabs)
