local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),

    Asset("ANIM", "anim/wurrow.zip"),
    Asset("ANIM", "anim/ghost_wurrow_build.zip"),
    Asset("ANIM", "anim/wurrow_lure.zip"),
    Asset("ANIM", "anim/wurrow_animations.zip"),
}

local prefabs = {
    "wormlight",
    "wurrow_lure_fx",
    "wurrow_lure"
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WURROW
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

---———————————————=[ Lure Functions ]=———————————————---

---———————————————={ Miscellaneous Functions }=———————————————---
local function onbecamehuman(inst)
    inst.Light:Enable(false)
end

local function onbecameghost(inst)
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
        return -(10 / (TUNING.SEG_TIME * 2))
    end
    return 0
end

---———————————————={ Burrow Functions }=———————————————---
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
        elseif candig and inst.replica.hunger:GetPercent() >= 0.1 then
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

local function burrow_treasure(inst, data)
    local frequency = TUNING.WURROW_MODCONFIGDATA["Treasure_Frequency"]

    if data.name == "treasure_drop" then
        inst.components.lootdropper:DropLoot()
        if inst:HasTag("burrowed") then
            inst.components.timer:StartTimer("treasure_drop", frequency)
        end
    end
end

local function wurrow_handslot_dirt(inst)
    local inventory = inst.components.inventory
    
    local handdirt = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if handdirt then
        handdirt.components.equippable.un_unequipable = nil
        handdirt:Remove()
    end
end

local function DisallowBoatHopping(inst, speedmult)
    if inst:HasTag("burrowed") then
        return 0
    end
    return nil
end

---———————————————={ Burrow Vision }=———————————————---
local WURROW_COLOURCUBES = {
    day = resolvefilepath("images/colour_cubes/bat_vision_on_cc.tex"),
    dusk = resolvefilepath("images/colour_cubes/bat_vision_on_cc.tex"),
    night = resolvefilepath("images/colour_cubes/bat_vision_on_cc.tex"),
    full_moon = "images/colour_cubes/fungus_cc.tex",
}

local function WurrowEnterLight(inst)
end

local function WurrowEnterDark(inst)
end

local function CheckLight(inst)
	if inst:IsInLight() and not inst:HasTag("burrowed") then
		if inst.updatewurrowvisiontask == nil then
			inst.updatewurrowvisiontask = inst:DoTaskInTime(0, function()
				inst.components.playervision:SetCustomCCTable(nil)
				inst.components.playervision:ForceNightVision(false)
                inst:RemoveTag("wurrowindark")

				if inst.updatewurrowvisiontask ~= nil then
					inst.updatewurrowvisiontask:Cancel()
				end
			end)
		end
	else
		if inst.updatewurrowvisiontask ~= nil then
			inst.updatewurrowvisiontask:Cancel()
		end

		inst.updatewurrowvisiontask = nil
        if inst:HasTag("burrowed") then
		    inst.components.playervision:SetCustomCCTable(WURROW_COLOURCUBES)
		    inst.components.playervision:ForceNightVision(true)
            inst:AddTag("wurrowindark")
        end
    end
end

---———————————————={ Common Postinit }=———————————————---
local common_postinit = function(inst)
	inst:AddTag("monster")
	inst:AddTag("worm")
	inst:AddTag("nowormholesanityloss")
    inst:AddTag("wet") --Doesn't currently do anything
	inst:AddTag("cavedweller")
    inst:AddTag("nightvision")
    inst:AddTag("wurrow") --Might try to reduce the amount of tags by changing the depth worm aggro tag
    inst:AddTag("acidrainimmune")
    inst:AddTag("gelable")

    inst:DoPeriodicTask(.3, CheckLight)
	inst:ListenForEvent("enterdark", WurrowEnterDark)
	inst:ListenForEvent("enterlight", WurrowEnterLight)

    inst.stackmoisture = false

	inst.MiniMapEntity:SetIcon( "wurrow.tex" )

    inst.CanBurrow = CanBurrow
    inst.CanDig = CanDig

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

    inst:ListenForEvent("setowner", OnSetOwner)

    if TheNet:GetServerGameMode() == "quagmire" then
		inst:AddTag("quagmire_shopper")
	end
end

---———————————————={ Master Postinit }=———————————————---
local master_postinit = function(inst)
    inst._lurefx = SpawnPrefab("wurrowlure_flowering")
    inst._lurefx.entity:SetParent(inst.entity)
    inst._lurefx.Follower:FollowSymbol(inst.GUID, "headbase", nil, nil, nil, true)
    
    inst.highlightchildren = { inst._lurefx }

    inst:DoPeriodicTask(.3, CheckLight)
	inst:ListenForEvent("enterdark", WurrowEnterDark)
	inst:ListenForEvent("enterlight", WurrowEnterLight)

    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst:AddComponent("acidinfusible")
    inst.components.acidinfusible:SetFXLevel(1)
    inst.components.acidinfusible:SetMultipliers(TUNING.ACID_INFUSION_MULT.BERSERKER)

	inst.soundsname = "wormwood"

	inst.components.health:SetMaxHealth(TUNING.WURROW_HEALTH)
	inst.components.hunger:SetMax(TUNING.WURROW_HUNGER)
	inst.components.sanity:SetMax(TUNING.WURROW_SANITY)

	if inst.components.eater ~= nil then
        inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODTYPE.VEGGIE, FOODTYPE.BERRY, FOODTYPE.SEEDS, FOODTYPE.MEAT })
        inst.components.eater:SetStrongStomach(true)
        inst.components.eater:SetCanEatRawMeat(true)
    end

    inst.components.foodaffinity:AddPrefabAffinity("unagi", TUNING.AFFINITY_15_CALORIES_LARGE)

	local foodaffinity = inst.components.foodaffinity
	foodaffinity:AddPrefabAffinity  ("wormlight",            1.0)
	foodaffinity:AddPrefabAffinity  ("wormlight_lesser",     1.0)
	foodaffinity:AddPrefabAffinity  ("cutlichen",            1.0)

	inst.OnLoad = onload
    inst.OnNewSpawn = onload

	inst.components.sanity.custom_rate_fn = CustomSanityFn

	inst.components.sanity:SetLightDrainImmune(true)

	inst.components.sanity.no_moisture_penalty = true

	inst.components.sanity:AddSanityAuraImmunity("worm")
	inst.components.sanity:AddSanityAuraImmunity("worm_boss_piece")

    inst.count = 0

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("flint", .50)
    inst.components.lootdropper:AddRandomLoot("rocks", .40)
	inst.components.lootdropper:AddRandomLoot("nitre", .25)
	inst.components.lootdropper:AddRandomLoot("marble", .25)
    inst.components.lootdropper:AddRandomLoot("goldnugget", .20)
    inst.components.lootdropper:AddRandomLoot("moonrocknugget", .15)
	inst.components.lootdropper:AddRandomLoot("redgem", .03)
    inst.components.lootdropper:AddRandomLoot("bluegem", .03)
    inst.components.lootdropper:AddRandomLoot("purplegem", .01)
	inst.components.lootdropper:AddRandomLoot("dreadstone", .005)
    -- inst.components.lootdropper:AddRandomLoot("yellowgem", .01) --Desert biomes only
    -- inst.components.lootdropper:AddRandomLoot("orangegem", .01) --Ruins biomes only
    -- inst.components.lootdropper:AddRandomLoot("greengem", .01) --Ruins biomes only
    -- inst.components.lootdropper:AddRandomLoot("moonglass", .01) --Lunar biomes only
    -- inst.components.lootdropper:AddRandomLoot("fossil_piece", .01) --Caves only

    inst.components.locomotor.hop_distance_fn = DisallowBoatHopping
	
	local treasure_amount = TUNING.WURROW_MODCONFIGDATA["Treasure_Amount"]
    inst.components.lootdropper.numrandomloot = treasure_amount

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", burrow_treasure)
end

return MakePlayerCharacter("wurrow", prefabs, assets, common_postinit, master_postinit)
