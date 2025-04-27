---@diagnostic disable: undefined-global, syntax-error
local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset( "ANIM", "anim/beard_wurrow.zip" ),
    --Asset( "ANIM", "anim/harvest.zip" ),
}

local prefabs = {
    "wormlight",
}

TUNING.WURROW_HEALTH = 175
TUNING.WURROW_HUNGER = 225
TUNING.WURROW_SANITY = 125

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WURROW = {
	"slurper_pelt",
	"slurper_pelt",
}

------------------------------------------------------------------------------------------------------------

local function OnResetBeard(inst)
    inst.AnimState:ClearOverrideSymbol("beard")
    inst.Light:Enable(false)
end

local BEARD_DAYS = { 4, 8, 12 }
local BEARD_BITS = { 1, 1, 1 }

local function OnGrowShortBeard(inst, skinname)
    inst.Light:Enable(false)
    if skinname == nil then
        inst.AnimState:OverrideSymbol("beard", "beard_wurrow", "beard_short")
    else
        inst.AnimState:OverrideSkinSymbol("beard", skinname, "beard_short" )
    end
    inst.components.beard.bits = BEARD_BITS[1]
end

local function OnGrowMediumBeard(inst, skinname)
    inst.Light:Enable(true)
	inst.Light:SetRadius(2)
	inst.Light:SetFalloff(.5)
	inst.Light:SetIntensity(0.9)
	inst.Light:SetColour(128/255,255/255,255/255)
    if skinname == nil then
        inst.AnimState:OverrideSymbol("beard", "beard_wurrow", "beard_medium")
    else
        inst.AnimState:OverrideSkinSymbol("beard", skinname, "beard_medium" )
    end
    inst.components.beard.bits = BEARD_BITS[1]
end

local function OnGrowLongBeard(inst, skinname)
    inst.Light:Enable(false)
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

local function ReticuleTargetFn(inst)
    return ControllerReticle_Blink_GetPosition(inst, inst.CanDig)
end

local function CanBurrow(inst)
    return true
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right and useitem == nil then
        local candig = inst.CanDig(pos)
        if candig and inst:HasTag("burrowed") then
            return { ACTIONS.RESURFACE }
        elseif candig and inst.replica.hunger:GetPercent() >= 0.2 then
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

-- local function Wurrow_OnStormLevelChanged(inst, data)
--     local in_sandstorm = data ~= nil and data.stormtype == STORM_TYPES.SANDSTORM and data.level > 0
--     if in_sandstorm then 
--         if not inst:HasTag("wurrow_insandstorm") then 
--             inst:AddTag("wurrow_insandstorm")
--         end
--         if inst.components.locomotor ~= nil then
--             inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wurrow_sandstorm", 1.25)
--         end
--         if inst.components.combat ~= nil then 
--             inst.components.combat.externaldamagetakenmultipliers:SetModifier("wurrow_sandstorm", 0.8)
--         end
--     else
--         if inst:HasTag("wurrow_insandstorm") then 
--             inst:RemoveTag("wurrow_insandstorm")
--         end
--         if inst.components.locomotor ~= nil then
--             inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wurrow_sandstorm")
--         end
--         if inst.components.combat ~= nil then 
--             inst.components.combat.externaldamagetakenmultipliers:RemoveModifier("wurrow_sandstorm")
--         end
--     end
-- end

------------------------------------------------------------------------------------------------------------

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WURROW
end
local prefabs = FlattenTree(start_inv, true)

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wurrow_speed_mod", 1)
    inst.Light:Enable(false)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wurrow_speed_mod")
   inst.Light:Enable(false)
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

-- local function shaved (inst)
--     if inst.components.beard then
--         inst.components.beard:Reset()
--     end
-- end

local function CustomSanityFn(inst, dt)
    if TheWorld.state.isday and not TheWorld:HasTag("cave") then
        return -(5 / (TUNING.SEG_TIME * 2))
    end
    return 0
end

------------------------------------------------------------------------------------------------------------

local function burrow_treasure(inst)
	inst.components.lootdropper:PickRandomLoot()
	inst.components.lootdropper:DropLoot()
end

local function burrow(inst)
    local treasure_config = TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Treasure"]

    if inst:HasTag("burrowed") then
        if treasure_config == 1 then
			local frequency = TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Treasure_Frequency"]
			inst.components.timer:StartTimer("treasure_drop", frequency)
		end
    end
end

------------------------------------------------------------------------------------------------------------

local common_postinit = function(inst)
	inst:AddTag("monster")
	inst:AddTag("worm")
	inst:AddTag("nowormholesanityloss")
    -- inst:AddTag("wet") --Doesn't currently do anything
	-- inst:AddTag("cavedweller")
	-- inst:AddTag("nightvision") --Not going to be used until I code the burrowing vision
    inst:AddTag("wurrow") --Might try to reduce the amount of tags by changing the depth worm aggro tag
	inst:AddTag("bearded")
    inst:AddTag("acidrainimmune")
    -- inst:AddTag("canbetrapped") --Will be used later for Wurrow to trigger traps and get stunned

    inst.stackmoisture = false

	inst.MiniMapEntity:SetIcon( "wurrow.tex" )

    inst.CanBurrow = CanBurrow
    inst.CanDig = CanDig

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

    inst:ListenForEvent("setowner", OnSetOwner)
end

------------------------------------------------------------------------------------------------------------

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

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

    -- inst:ListenForEvent("shave") = shaved

    inst.entity:AddLight()
	inst.Light:Enable(true)
	inst.Light:SetRadius(4)
	inst.Light:SetFalloff(.5)
	inst.Light:SetIntensity(0.9)
	inst.Light:SetColour(128/255,255/255,255/255)

	inst.OnLoad = onload
    inst.OnNewSpawn = onload

	inst.components.sanity.custom_rate_fn = CustomSanityFn

	inst.components.sanity:SetLightDrainImmune(true)

	inst.components.sanity.no_moisture_penalty = true

	inst.components.sanity:AddSanityAuraImmunity("worm")
	inst.components.sanity:AddSanityAuraImmunity("worm_boss")

    inst.count = 0

    -- if inst.HasTag:("burrowed") then
        inst:AddComponent("lootdropper")
    -- end
    inst.components.lootdropper:AddRandomLoot("farm_soil_debris", .80)
    inst.components.lootdropper:AddRandomLoot("flint", .20)
    inst.components.lootdropper:AddRandomLoot("rocks", .20)
	inst.components.lootdropper:AddRandomLoot("nitre", .10)
	inst.components.lootdropper:AddRandomLoot("marble", .075)
    inst.components.lootdropper:AddRandomLoot("goldnugget", .5)
	inst.components.lootdropper:AddRandomLoot("redgem", .01)
	inst.components.lootdropper:AddRandomLoot("bluegem", .01)

    inst:ListenForEvent("hungerdelta", burrow)
	
	local treasure_amount = TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Treasure_Amount"]
    inst.components.lootdropper.numrandomloot = treasure_amount

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", burrow_treasure)

    -- inst:ListenForEvent("stormlevel", Wurrow_OnStormLevelChanged)

    -- if inst.components.moisture and inst.stackmoisture == false then 
	-- 	local oldmt = inst.components.moisture.OnUpdate
	-- 	inst.components.moisture.OnUpdate = function(s, dt, ...)
	-- 		if oldmt ~= nil then 
	-- 			oldmt(s,dt,...)
	-- 		end
	-- 		if s.inst:HasTag("wurrow_insandstorm") and s.rate < 0 then 
	-- 			s:DoDelta(s.rate * 3 * dt)
	-- 			s.ratescale =
	-- 			(s.rate * 4 > .3 and RATE_SCALE.INCREASE_HIGH) or
	-- 			(s.rate * 4 > .15 and RATE_SCALE.INCREASE_MED) or
	-- 			(s.rate * 4 > .001 and RATE_SCALE.INCREASE_LOW) or
	-- 			(s.rate * 4 < -3 and RATE_SCALE.DECREASE_HIGH) or
	-- 			(s.rate * 4 < -1.5 and RATE_SCALE.DECREASE_MED) or
	-- 			(s.rate * 4 < -.001 and RATE_SCALE.DECREASE_LOW) or
	-- 			RATE_SCALE.NEUTRAL
	-- 		end
	-- 	end
	-- 	inst.stackmoisture = true
	-- end
end

return MakePlayerCharacter("wurrow", prefabs, assets, common_postinit, master_postinit, prefabs)
