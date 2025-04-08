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

--- Courtesy of zhuyifei1999, ClumsyPenny & Luкaട ↓
AddAction("BURROW", "Burrow", function(act)
    if act.doer ~= nil and act.doer:HasTag("wurrow") then
        return true
    end
end)

AddStategraphActionHandler {
    GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURROW,
        function(inst, action)
            return action.invobject == nil and inst:HasTag("wurrow") and "burrow_enter"
        end),
    GLOBAL.ActionHandler(GLOBAL.ACTIONS.TUNNEL,
        function(inst, action)
            return action.invobject == nil and inst:HasTag("wurrow") and "burrowing"
        end),
}

AddComponentAction("BURROW_RCLICK", "Burrow", function(doer, actions, _right)
    if doer.prefab == "wurrow" then
        table.insert(actions, GLOBAL.ACTIONS.BURROW)
    end
end)

AddStategraphState ("wilson", GLOBAL.State{
    State{
        name = "burrow_pre",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jumpin")
            inst.AnimState:PlayAnimation("despawn")
            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end
        end,

        timeline = {
            GLOBAL.FrameEvent(10, function(inst)
                SpawnAt("shovel_dirt", inst)
            end),
            GLOBAL.FrameEvent(30, function(inst)
                SpawnAt("shovel_dirt", inst)
            end),
            GLOBAL.FrameEvent(40, function(inst)
                inst.sg:RemoveStateTag("busy")
            end)
        },

        events = {
            GLOBAL.EventHandler("animover", 
                function(inst)
                    if inst.AnimState:AnimDone() and not inst:PerformBufferedAction() then
                        inst.sg:GoToState("burrowing")
                    end
                end)
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("busy") then
                inst.SoundEmitter:KillSound("rumble_lp")
            end
        end,
    },
})

AddStategraphState ("wilson", GLOBAL.State{
    State{
        name = "burrowing",
        tags = { "moving", "canrotate", "dirt", "invisible" },
    
        onenter = function(inst)
            inst.components.health:SetInvincible(true)
            inst.DynamicShadow:Enable(false)
            inst.components.locomotor.walkspeed = 4
            inst.components.locomotor:SetSlowMultiplier( 1 )
            inst.components.locomotor:SetTriggersCreep(false)
            inst.components.locomotor.pathcaps = { ignorecreep = true, ignorebridges = true, }
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop")
            if not inst.SoundEmitter:PlayingSound("walkloop") then
                inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/move", "walkloop")
            end
         end,
    
        timeline = {
            GLOBAL.TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/dirt") end),
            GLOBAL.TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/dirt") end),
            GLOBAL.TimeEvent(20 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/dirt") end),
         },

        events = {
            GLOBAL.EventHandler("animover", function(inst)
                inst.sg.statemem.walking = true
                inst.sg:GoToState("walk")
            end),
        },
    
        onexit = function(inst)
            if not inst.sg.statemem.walking then
                inst.SoundEmitter:KillSound("walkloop")
            end
        end,
    },
})

AddStategraphState ("wilson", GLOBAL.State{
    State{
        name = "burrow_out",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jumpout")
            local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil and buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
        end,
        
        onexit = function(inst)
        end,

        events =
        {
            GLOBAL.EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and not inst:PerformBufferedAction() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
})

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURROW, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURROW, "dolongaction"))

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