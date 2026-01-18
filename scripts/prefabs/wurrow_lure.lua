local function WurrowLure(name, anim, light)
	local assets = {
		Asset("ANIM", "anim/wurrow_lure.zip"),
	}

	local function fn()
		local inst = CreateEntity()

        inst.persists = false

        inst:AddTag("FX")

        inst.entity:AddTransform()
        inst.entity:AddFollower()
        inst.entity:AddNetwork()
        inst.entity:AddLight()
        inst.entity:AddAnimState()

        inst.AnimState:SetBank("wurrow_lure")
        inst.AnimState:SetBuild("wurrow_lure")
        inst.AnimState:PlayAnimation("idle_flowering", true)

        inst.Light:Enable(light)
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

	return Prefab(name, fn, assets)
end

return WurrowLure("wurrowlure_budding", "idle_budding", false),
	   WurrowLure("wurrowlure_flowering", "idle_flowering", true),
	   WurrowLure("wurrowlure_wilting", "idle_wilting", false)