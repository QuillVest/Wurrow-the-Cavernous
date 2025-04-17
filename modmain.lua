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

-- local function SpawnMoveFx(inst)
--     SpawnPrefab("mole_move_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
-- end

--- Courtesy of zhuyifei1999, ClumsyPenny & Lukaട ↓
AddAction("BURROW", "Burrow", function(act)
    if act.doer ~= nil and act.doer:HasTag("wurrow") then
        return true
    end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURROW, function(inst, action)
    return action.invobject == nil and inst:HasTag("wurrow") and "burrow"
end))

AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURROW, "burrow"))

AddComponentAction("BURROW_RCLICK", "Burrow", function(doer, actions, _right)
    if doer.prefab == "wurrow" then
        table.insert(actions, GLOBAL.ACTIONS.BURROW)
    end
end)

AddStategraphState ("wilson", GLOBAL.State{
    name = "burrow",
    tags = {},

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.DynamicShadow:Enable(false)
        inst.AnimState:PlayAnimation("jump", false)
        local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end
    end,

    timeline = {
        GLOBAL.FrameEvent(15, function(inst)
            GLOBAL.SpawnAt("mole_move_fx", inst)
        end),
        GLOBAL.FrameEvent(17, function(inst)
            GLOBAL.SpawnAt("dirt_puff", inst)
        end),
    },

    events = {
        GLOBAL.EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
<<<<<<< HEAD
				inst.components.health:SetInvincible(true)
                inst.AnimState:PlayAnimation("despawn")
				inst.AnimState:SetBank("mole")
				inst.AnimState:SetBuild("mole_build")
				inst:SetStateGraph("SGwurrow")
                inst.sg:GoToState("idle")
=======
                inst.sg:GoToState("tunneling")
>>>>>>> 4eef73e5695bf143338712a2ea5fabbe5a15b4e6
            end
        end)
    },
})

AddStategraphState ("wilson", GLOBAL.State{
<<<<<<< HEAD
=======
    name = "tunneling",
    tags = {},
    
    onenter = function(inst)
        local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end
    end,
    
    timeline = {
    },

    events = {
        GLOBAL.EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("resurface")
            end
        end),
    },
})

AddStategraphState ("wilson", GLOBAL.State{
>>>>>>> 4eef73e5695bf143338712a2ea5fabbe5a15b4e6
    name = "resurface",
    tags = {},

    onenter = function(inst)
        inst.components.health:SetInvincible(true)
		inst.components.locomotor:StopMoving()
        inst.AnimState:SetBank("wilson")
		inst.AnimState:SetBuild("wurrow")
        inst.AnimState:PlayAnimation("jumpout")
        local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end
    end,

    timeline = {
    },

    events = {
<<<<<<< HEAD
    GLOBAL.EventHandler("animqueueover", function(inst)
        if inst.AnimState:AnimDone() then
            inst.components.health:SetInvincible(false)
            inst:SetStateGraph("SGwilson")
            inst.sg:GoToState("idle")
        end
    end),
=======
    GLOBAL.EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
>>>>>>> 4eef73e5695bf143338712a2ea5fabbe5a15b4e6
    },
})

AddStategraphState("wilson_client", GLOBAL.State{
    name = "burrow",
    tags = { "doing", "busy" },
    server_states = { "burrow", "tunneling" },

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

--- Courtesy of Ilaskus
AddPrefabPostInit("worm", function(inst)
    
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    if inst.components.combat then
        inst.components.combat:AddNoAggroTag("wurrow")
    end

end)

AddModCharacter("wurrow", "MALE", skin_modes)