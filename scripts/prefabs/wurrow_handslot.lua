local function makefn(slot)
    local function fn()
	    local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddNetwork()
		
        MakeInventoryPhysics(inst)
	
	    inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end
	
	    inst:AddComponent("inventoryitem")
		inst:AddComponent("equippable")

        inst.components.equippable:SetPreventUnequipping(true)
    
        return inst
	end
	return fn
end

local function makedirt(name, slot)
	if slot ~= nil then
    	return Prefab("common/inventory/"..name, makefn(slot))
    end
end

return makedirt("wurrow_handslot", EQUIPSLOTS.HANDS)
