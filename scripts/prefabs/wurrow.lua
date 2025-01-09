local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

SetSharedLootTable("wurrow",
{
    { "wormlight",  1.00 },
})

TUNING.WURROW_HEALTH = 175
TUNING.WURROW_HUNGER = 225
TUNING.WURROW_SANITY = 125

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WURROW = {
	"wormlight_lesser",
	"wormlight_lesser",
	"wormlight_lesser",
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

local WURROW_COLORCUBES =
{
    day = resolvefilepath("images/color_cubes/bat_vision_on_cc.tex"),
    dusk = resolvefilepath("images/color_cubes/bat_vision_on_cc.tex"),
    night = resolvefilepath("images/color_cubes/bat_vision_on_cc.tex"),
    full_moon = "images/color_cubes/fungus_cc.tex",
}

local function WurrowEnterLight(inst)
end

local function WurrowEnterDark(inst)
end

local function CheckLight(inst)
	if inst:IsInLight() then
		if inst.updatewathomvisiontask == nil then
			inst.updatewathomvisiontask = inst:DoTaskInTime(1, function()
				inst.components.playervision:SetCustomCCTable(nil)
				inst.components.playervision:ForceNightVision(false)
				inst:RemoveTag("WurrowInDark")
				
				if inst.updatewathomvisiontask ~= nil then
					inst.updatewathomvisiontask:Cancel()
				end
			end)
		end
	else	
		if inst.updatewathomvisiontask ~= nil then
			inst.updatewathomvisiontask:Cancel()
		end
				
		inst.updatewathomvisiontask = nil
		inst.components.playervision:SetCustomCCTable(WURROW_COLORCUBES)
		inst.components.playervision:ForceNightVision(true)
		inst:AddTag("WurrowInDark")
	end
end

local common_postinit = function(inst) 
	inst:AddTag("monster")
	inst:AddTag("worm")
	inst:AddTag("nowormholesanityloss")
	inst:AddTag("cavedweller")
	inst:AddTag("nightvision")
	inst.MiniMapEntity:SetIcon( "wurrow.tex" )

	inst:DoPeriodicTask(.3, CheckLight)
	inst:ListenForEvent("enterdark", WurrowEnterDark)
	inst:ListenForEvent("enterlight", WurrowEnterLight)
end

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	inst.components.combat.shouldavoidaggrofn = function(attacker, inst) return attacker.prefab ~= 'worm' end
	inst.components.combat.shouldavoidaggrofn = function(attacker, inst) return attacker.prefab ~= 'worm_boss' end

	inst:DoPeriodicTask(.3, CheckLight)
	inst:ListenForEvent("enterdark", WurrowEnterDark)
	inst:ListenForEvent("enterlight", WurrowEnterLight)

	inst.soundsname = "wormwood"
	
	inst.components.health:SetMaxHealth(TUNING.WURROW_HEALTH)
	inst.components.hunger:SetMax(TUNING.WURROW_HUNGER)
	inst.components.sanity:SetMax(TUNING.WURROW_SANITY)
	
    inst.components.combat.damagemultiplier = 1
	
	inst.components.hunger.hungerrate = 1.5 * TUNING.WILSON_HUNGER_RATE

	inst.components.foodaffinity:AddPrefabAffinity("unagi", TUNING.AFFINITY_15_CALORIES_LARGE)

	local foodaffinity = inst.components.foodaffinity
	foodaffinity:AddFoodtypeAffinity(FOODTYPE.MEAT,        1.333)
	foodaffinity:AddPrefabAffinity  ("wormlight",            1.0)
	foodaffinity:AddPrefabAffinity  ("wormlight_lesser",     1.0)
	foodaffinity:AddPrefabAffinity  ("cutlichen",            1.0)

	inst.components.eater:SetDiet({ FOODTYPE.VEGGIE, FOODTYPE.BERRY, FOODTYPE.SEEDS, FOODTYPE.MEAT })
	if inst.components.eater ~= nil then
        inst.components.eater:SetStrongStomach(true)
        inst.components.eater:SetCanEatRawMeat(true)
    end
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload

	inst.components.sanity.custom_rate_fn = CustomSanityFn
    
	inst.components.sanity:SetLightDrainImmune(true)
	
	inst.components.sanity.no_moisture_penalty = true
	
	inst.components.sanity:AddSanityAuraImmunity("worm")
	inst.components.sanity:AddSanityAuraImmunity("worm_boss")
end

return MakePlayerCharacter("wurrow", prefabs, assets, common_postinit, master_postinit, prefabs)
