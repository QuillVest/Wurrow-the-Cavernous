---@diagnostic disable: undefined-global, syntax-error
local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset( "ANIM", "anim/beard_wurrow.zip" ),
}

local prefabs = {
    "wormlight",
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
        elseif candig then
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
    local move_hunger_config = TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Drain_Move"]
	local still_hunger_config = TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Drain_Still"]
    local treasure_config = TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Treasure"]

    if inst:HasTag("burrowed") then
        --Burrow Treasure
        if treasure_config == 1 then
			local frequency = TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Treasure_Frequency"]
			inst.components.timer:StartTimer("treasure_drop", frequency)
		end
        --Burrow Hunger Drain
        if inst.sg:HasStateTag("burrowing") then
            inst.components.hunger:SetRate(move_hunger_config * TUNING.WILSON_HUNGER_RATE)
        else
            inst.components.hunger:SetRate(still_hunger_config * TUNING.WILSON_HUNGER_RATE)
        end
        --Burrow Exit
        if inst.components.hunger.current <= 0 and burrow_exit == 1 and inst.prefab == "wurrow" then
            SendModRPCToServer(GetModRPC("Wurrow", "Wurrow_Handler") )
            inst.components.talker:Say("I'm too hungry to burrow...")
        end
            --Burrow Temperature
            
            -- local insulation = {
            -- 	TUNING.INSULATION_SMALL,--60
            -- 	TUNING.INSULATION_MED,--120
            -- 	TUNING.INSULATION_MED_LARGE,--180
            -- 	TUNING.INSULATION_LARGE,--240
            -- }
        
            -- if inst.components.temperature ~= nil and temperature_config == 5 then
            -- 	inst.components.temperature.inherentinsulation = 0
            -- 	inst.components.temperature.inherentsummerinsulation = 0
                
            -- 	if inst.burrow_temperature ~= nil and inst.components.temperature:GetCurrent() < inst.burrow_temperature then
            -- 		inst.components.temperature:SetTemperature(inst.components.temperature:GetCurrent() + 2)
            -- 	elseif inst.burrow_temperature ~= nil and inst.components.temperature:GetCurrent() > inst.burrow_temperature then
            -- 		inst.components.temperature:SetTemperature(inst.components.temperature:GetCurrent() - 2)
            -- 	end
                
            -- elseif inst.components.temperature ~= nil and temperature_config ~= 0 then
            -- 	inst.components.temperature.inherentinsulation = insulation[temperature_config]
            -- 	inst.components.temperature.inherentsummerinsulation = insulation[temperature_config]
            -- else
            -- 	inst.components.temperature.inherentinsulation = 0
            -- 	inst.components.temperature.inherentsummerinsulation = 0
            -- end		
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

    inst:AddComponent("spell")
    inst.components.spell.spellname = "wormlight"

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

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("rocks", .75)
    inst.components.lootdropper:AddRandomLoot("flint", .75)
	inst.components.lootdropper:AddRandomLoot("goldnugget", .20)
	inst.components.lootdropper:AddRandomLoot("carrot", .20)
	inst.components.lootdropper:AddRandomLoot("nitre", .20)
	inst.components.lootdropper:AddRandomLoot("marble", .05)
	inst.components.lootdropper:AddRandomLoot("redgem", .01)
	inst.components.lootdropper:AddRandomLoot("bluegem", .01)
	
	local treasure_amount = TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Treasure_Amount"]
    inst.components.lootdropper.numrandomloot = treasure_amount

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", burrow_treasure)
end

return MakePlayerCharacter("wurrow", prefabs, assets, common_postinit, master_postinit, prefabs)
