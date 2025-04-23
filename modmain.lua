---@diagnostic disable: undefined-global, syntax-error
PrefabFiles = {
	"wurrow",
	"wurrow_none",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/wurrow.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/wurrow.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/wurrow.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wurrow.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/wurrow_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wurrow_silho.xml" ),

    Asset( "IMAGE", "bigportraits/wurrow.tex" ),
    Asset( "ATLAS", "bigportraits/wurrow.xml" ),

	Asset( "IMAGE", "images/map_icons/wurrow.tex" ),
	Asset( "ATLAS", "images/map_icons/wurrow.xml" ),

	Asset( "IMAGE", "images/avatars/avatar_wurrow.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_wurrow.xml" ),

	Asset( "IMAGE", "images/avatars/avatar_ghost_wurrow.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_wurrow.xml" ),

	Asset( "IMAGE", "images/avatars/self_inspect_wurrow.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_wurrow.xml" ),

	Asset( "IMAGE", "images/names_wurrow.tex" ),
    Asset( "ATLAS", "images/names_wurrow.xml" ),

	Asset( "IMAGE", "images/names_gold_wurrow.tex" ),
    Asset( "ATLAS", "images/names_gold_wurrow.xml" ),
}

AddMinimapAtlas("images/map_icons/wurrow.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

TUNING.CHARACTER_PREFAB_MODCONFIGDATA = {}
--Stat Settings
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Health"] = GetModConfigData("Health")
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Hunger"] = GetModConfigData("Hunger")
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Sanity"] = GetModConfigData("Sanity")
--Burrowing Settings
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Drain_Move"] = GetModConfigData("Burrow_Drain_Move")
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Drain_Still"] = GetModConfigData("Burrow_Drain_Still")
--Treasure Settings
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Burrow_Treasure"] = GetModConfigData("Burrow_Treasure")
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Treasure_Frequency"] = GetModConfigData("Treasure_Frequency")
TUNING.CHARACTER_PREFAB_MODCONFIGDATA["Treasure_Amount"] = GetModConfigData("Treasure_Amount")

STRINGS.CHARACTER_TITLES.wurrow = "The Cavernous"
STRINGS.CHARACTER_NAMES.wurrow = "Wurrow"
STRINGS.CHARACTER_DESCRIPTIONS.wurrow = "*Loves the caves, hates the surface\n*Insatiable appetite for anything\n*No stranger to getting dirty\n*Blinded by bright things"
STRINGS.CHARACTER_QUOTES.wurrow = "\"Have you seen my lure?\""
STRINGS.CHARACTER_SURVIVABILITY.wurrow = "Grim"

STRINGS.CHARACTERS.WURROW = require "speech_wurrow"

STRINGS.NAMES.WURROW = "Wurrow"
STRINGS.SKIN_NAMES.wurrow_none = "Wurrow"

local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = { 0, -25 }
    },
}
------------------------------------------------------------------------------------------------------------

--- Courtesy of zhuyifei1999, ClumsyPenny & Lukaട ↓
AddAction("BURROW", "Burrow", function(act)
    if act.doer ~= nil and act.doer:HasTag("wurrow")
        and not act.doer:HasTag("burrowed") and inst.components.hunger:GetPercent() >= 0.2 then
        return true
    end
end)

AddAction("RESURFACE", "Resurface", function(act)
    if act.doer ~= nil and act.doer:HasTag("wurrow") and act.doer:HasTag("burrowed") then
        return true
    end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURROW, function(inst, action)
    return action.invobject == nil and inst:HasTag("wurrow") and "burrow"
end))

AddStategraphActionHandler("wurrow", GLOBAL.ActionHandler(GLOBAL.ACTIONS.RESURFACE, function(inst, action)
    return action.invobject == nil and inst:HasTag("wurrow") and "resurface"
end))

AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURROW, "burrow"))

AddComponentAction("BURROW_RCLICK", "Burrow", function(doer, actions, _right)
    if doer.prefab == "wurrow" then
        table.insert(actions, GLOBAL.ACTIONS.BURROW)
    end
end)

AddComponentAction("RESURFACE_RCLICK", "Resurface", function(doer, actions, _right)
    if doer.prefab == "wurrow" then
        table.insert(actions. GLOBAL.ACTIONS.RESURFACE)
    end
end)

AddStategraphState ("wilson", GLOBAL.State{
    name = "burrow",
    tags = { "doing", "busy" },

    onenter = function(inst)
        if inst:HasTag("scarytoprey") then
            inst:RemoveTag("scarytoprey")
        end
        inst.components.locomotor:Stop()
        inst.DynamicShadow:Enable(false)
        inst.AnimState:PlayAnimation("jump", false)
        local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end
    end,

    timeline = {
        GLOBAL.TimeEvent(15 * GLOBAL.FRAMES, function(inst)
				inst.Physics:Stop()
            end),
        GLOBAL.FrameEvent(15, function(inst)
            GLOBAL.SpawnAt("mole_move_fx", inst)
        end),
        GLOBAL.FrameEvent(17, function(inst)
            GLOBAL.SpawnAt("dirt_puff", inst)
        end),
        -- GLOBAL.TimeEvent(18 * GLOBAL.FRAMES, function(inst)
        --     inst.Light:Enable(false)
        -- end),
    },

    events = {
        GLOBAL.EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
				inst.components.health:SetInvincible(true)
                inst.components.moisture.inherentWaterproofness = 1000

                if not inst:HasTag("burrowed") then
                    inst:AddTag("burrowed")
                end

                inst.AnimState:PlayAnimation("despawn")
				inst.AnimState:SetBank("mole")
				inst.AnimState:SetBuild("mole_build")
				inst:SetStateGraph("SGwurrow")
                inst.sg:GoToState("idle")

                inst.components.hunger.burnratemodifiers:SetModifier(inst, 4, "burrowingpenalty")
                inst.components.temperature.mintemp = 6
                inst.components.temperature.maxtemp = 63
            end
        end)
    },
})

AddStategraphState("wilson_client", GLOBAL.State{
    name = "burrow",
    tags = { "doing", "busy" },
    server_states = { "burrow", "resurface" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("jump")

        inst:PerformPreviewBufferedAction()
        inst.sg:SetTimeout(2)
    end,

    onupdate = function(inst)
        if inst.sg:ServerStateMatches() then
            if inst.entity:FlattenMovementPrediction() then
                inst.sg:GoToState("idle", "noanim")
            end
        elseif inst.bufferedaction == nil then
            inst.sg:GoToState("idle")
        end
    end,

    ontimeout = function(inst)
        inst:ClearBufferedAction()
        inst.sg:GoToState("idle")
    end
})

------------------------------------------------------------------------------------------------------------

-- AddAction("CUSTOMDIG", "Dig", function(act)
-- 	local val = GLOBAL.ACTIONS.DIG.fn(act)
-- 	if val then
-- 		return true
-- 	end
-- end)

-- AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.CUSTOMDIG, function(inst)
-- 	inst.AnimState:ClearOverrideSymbol("swap_object")
-- 	inst.AnimState:Hide("swap_object")
-- 	inst:DoTaskInTime(50 * GLOBAL.FRAMES, function()
-- 		local handitem = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
-- 		if handitem then
-- 			handitem.components.equippable.onequipfn(handitem, inst)
-- 		end
-- 	end)
-- 	return "dig_start"
-- end))

AddComponentPostInit("playeractionpicker", function(self)
	if self.inst.prefab == "wurrow" then --and GLOBAL.inst:HasTag("burrowed") then
		local old = self.GetRightClickActions
		self.GetRightClickActions = function(self, position, target)
			local bodyitem = self.inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
				if target and target:HasTag(GLOBAL.ACTIONS.DIG.id.."_workable") then
					return self:SortActionList({ GLOBAL.ACTIONS.DIG }, target)
				end
			return old(self, position, target)
		end
	end
end)

------------------------------------------------------------------------------------------------------------

local function OnEntityDeath(inst, data)
    inst.Light:Enable(false)
end

--- Courtesy of Ilaskus
AddPrefabPostInit("worm", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    if inst.components.combat then
        inst.components.combat:AddNoAggroTag("wurrow")
    end
end)

AddPrefabPostInit("worm_boss", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    if inst.components.combat then
        inst.components.combat:AddNoAggroTag("wurrow")
    end
end)

AddModCharacter("wurrow", "MALE", skin_modes)