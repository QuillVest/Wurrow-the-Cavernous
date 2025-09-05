local require = GLOBAL.require

AddClassPostConstruct( "widgets/controls", function(self, inst)
	local ownr = self.owner
	if ownr == nil then return end
	
	if self.owner:HasTag("wurrow") then
		local Wurrow_Sonar = require "widgets/wurrow_sonar"
		self.wurrow_sonar = self:AddChild( Wurrow_Sonar(self.owner) )
		self.wurrow_sonar:MoveToBack()
	end
end)