local function WurrowLureFx()
	local inst = CreateEntity()

	inst.persists = false

    inst:AddTag("FX")

	inst.entity:AddTransform()
	inst.entity:AddFollower()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    inst.Light:Enable(true)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(128/255, 255/255, 255/255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		return inst
	end

	return inst
end

return Prefab("wurrow_lure_fx", WurrowLureFx)