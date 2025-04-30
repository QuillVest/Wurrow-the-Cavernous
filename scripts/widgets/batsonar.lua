local Widget = require "widgets/widget"

local BatSonar = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "BatSonar")
    self:SetClickable(false)

    self.bg2 = self:AddChild(Image("images/fx_batsonar.xml", "fog_over.tex"))
    self.bg2:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg2:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg2:SetVAnchor(ANCHOR_MIDDLE)
    self.bg2:SetHAnchor(ANCHOR_MIDDLE)
    self.bg2:SetScaleMode(SCALEMODE_FILLSCREEN)

    self.alpha = 0
    self.alphagoal = 0
    self.transitiontime = 2.0
    self.transitiontimeIN = 0.2
    self.transitiontimeOUT = 5
    self.transitiontimeREST = 1    
    self.time = self.transitiontimeIN
    self.currentstate = "out"
    self:Hide()
end)

function BatSonar:StartSonar()
    self.time = self.transitiontimeIN
    self.alphagoal = 1
    self:StartUpdating()
    self:Show()
end

function BatSonar:StopSonar()
    self.time = self.transitiontime
    self.alphagoal = 0
    self:StopUpdating()
    self:Hide()
end

function BatSonar:UpdateAlpha(dt)

    if self.time > 0 then
        self.time = math.max(0, self.time - dt)
    else
        if self.currentstate == "out" then
            ThePlayer.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/batmask/sonar")

            local ring = SpawnPrefab("groundpoundring_fx")
            ring.Transform:SetScale(2,2,2)
            ring.Transform:SetPosition(ThePlayer.Transform:GetWorldPosition())    
            
            ThePlayer:DoTaskInTime(0.1, function()
                if self.shown then
                    local ring2 = SpawnPrefab("groundpoundring_fx")
                    ring2.Transform:SetScale(2,2,2)
                    ring2.Transform:SetPosition(ThePlayer.Transform:GetWorldPosition())
                end
            end)

            self.currentstate = "in"
            self.alphagoal = 0
            self.time = self.transitiontimeIN
        elseif self.currentstate == "in" then
            self.currentstate = "out"
            self.alphagoal = 1
            self.time = self.transitiontimeOUT
        end                
    end

    local mapping = 0
    if self.currentstate == "out" then
        mapping = Remap(self.time, self.transitiontimeOUT, 0, 0, 1)
    else
        mapping = Remap(self.time, self.transitiontimeIN, 0, 1, 0)
    end
    self.alpha = mapping
end

function BatSonar:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end
    self:UpdateAlpha(dt)
    self.bg2:SetTint(0, 0, 0, self.alpha)
end

return BatSonar
