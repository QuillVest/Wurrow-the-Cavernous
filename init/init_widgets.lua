AddComponentPostInit("playervision", function(self)
	local BAT_COLOURCUBE = GLOBAL.resolvefilepath "images/colour_cubes/bat_vision_on_cc.tex"
	local BAT_COLOURCUBES = {
		day = BAT_COLOURCUBE,
		dusk = BAT_COLOURCUBE,
		night = BAT_COLOURCUBE,
		full_moon = BAT_COLOURCUBE,
	}

-- local function BurrowingVision(inst)
-- 	if inst.components:HasTag("burrowed")
-- 		self.batview:StartSonar()
-- 	else not inst.components:HasTag("burrowed")
-- 		self.batview:StopSonar()
-- 	end
-- end

	local function OnEquipChanged(inst)
		local self = inst.components.playervision
		if self.batvision == not inst.replica.inventory:EquipHasTag("batvision") then
			self.batvision = not self.batvision
			self:UpdateCCTable()
		end
	end
	
	local function OnInit(inst, self)
		inst:ListenForEvent("equip", OnEquipChanged)
		inst:ListenForEvent("unequip", OnEquipChanged)
		if not GLOBAL.TheWorld.ismastersim then
			inst:ListenForEvent("inventoryclosed", OnEquipChanged)
			if inst.replica.inventory == nil then return end
		end
		OnEquipChanged(inst)
	end

	self.batvision = false
	self.inst:DoTaskInTime(0, OnInit, self)

	local old_UpdateCCTable = self.UpdateCCTable
	function self:UpdateCCTable()
		old_UpdateCCTable(self)
		local cctable = self.batvision and BAT_COLOURCUBES or nil
		if cctable ~= self.currentcctable and cctable ~= nil then
			self.currentcctable = cctable
			self.inst:PushEvent("ccoverrides", cctable)
		end
	end
end)

AddClassPostConstruct("screens/playerhud", function(self)
	local BatSonar = require "widgets/batsonar"
	local old_CreateOverlays = self.CreateOverlays
	function self:CreateOverlays(owner)
		old_CreateOverlays(self, owner)
		self.batview = self.overlayroot:AddChild(BatSonar(owner))
	end

	local old_OnUpdate = self.OnUpdate
	function self:OnUpdate(dt)
		old_OnUpdate(self, dt)
		if self.owner then
			if self.batview then
				if not self.batview.shown and self.owner.replica.inventory:EquipHasTag("batvision") then
					self.batview:StartSonar()
				elseif self.batview.shown and not self.owner.replica.inventory:EquipHasTag("batvision") then
					self.batview:StopSonar()
				end
			end

			--[[ hide goggle texture
			if self.gogglesover then
				if self.owner.replica.inventory:EquipHasTag("batvision") then
					self.gogglesover.bg:SetTint(1, 1, 1, 0)
				else
					self.gogglesover.bg:SetTint(1, 1, 1, 1)
				end
			end
			]]
		end
	end
end)