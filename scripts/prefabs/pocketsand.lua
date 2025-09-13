local assets = {
    Asset("ANIM", "anim/bottle.zip"),
	Asset("ANIM", "anim/swap_bottle.zip"),
	Asset("ANIM", "anim/swap_gelblobbottle.zip"),
	Asset("ATLAS", "images/inventoryimages/pocketsand.xml"),
    Asset("IMAGE", "images/inventoryimages/pocketsand.tex"),
}

local prefabs = {
    "miasma_cloud",
}

local function JarOfDirt_OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_gelblobbottle", "swap_bottle")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function JarOfDirt_OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function JarOfDirt_OnHit(inst, attacker, target)
	local x, y, z = inst.Transform:GetWorldPosition()
	if not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) and not TheWorld.Map:GetPlatformAtPoint(x,z) then
		SpawnPrefab("splash_green_small").Transform:SetPosition(x,y,z)
		inst.components.inventoryitem.canbepickedup = false

		inst.AnimState:PlayAnimation("bob_gelblob")
		inst:ListenForEvent("animover", inst.Remove)
	else
		SpawnPrefab("messagebottle_break_fx").Transform:SetPosition(x, y, z)
		inst:Remove()
		local dirt = SpawnPrefab("miasma_cloud")
		dirt.Transform:SetPosition(x, 0, z)
		-- dirt:SetLifespan(TUNING.TOTAL_DAY_TIME)
		-- dirt:ReleaseFromBottle()
	end
end

local function JarOfDirt_OnThrown(inst)
	inst:AddTag("NOCLICK")
	inst.persists = false

	inst.AnimState:PlayAnimation("spin_gelblob_loop", true)

	inst.Physics:SetMass(1)
	inst.Physics:SetFriction(0)
	inst.Physics:SetDamping(0)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:SetCollisionMask(
		COLLISION.WORLD,
		COLLISION.OBSTACLES,
		COLLISION.ITEMS
	)
	inst.Physics:SetCapsule(.2, .2)
end

local function JarOfDirt_OnStartFloating(inst)
	inst.AnimState:PlayAnimation("idle_gelblob_water")
end

local function JarOfDirt_OnStopFloating(inst)
	inst.AnimState:PlayAnimation("idle_gelblob")
end

local function pocketsandfn(inst)
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bottle")
    inst.AnimState:SetBuild("bottle")
	inst.AnimState:PlayAnimation("idle_gelblob")

	inst:AddTag("waterproofer")

	inst:AddTag("projectile")
	inst:AddTag("complexprojectile")

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "small", 0.05, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
	end

    inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "pocketsand"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/pocketsand.xml"

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0)

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(JarOfDirt_OnEquip)
	inst.components.equippable:SetOnUnequip(JarOfDirt_OnUnequip)
	inst.components.equippable.equipstack = true

	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetHorizontalSpeed(15)
	inst.components.complexprojectile:SetGravity(-35)
	inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
	inst.components.complexprojectile:SetOnLaunch(JarOfDirt_OnThrown)
	inst.components.complexprojectile:SetOnHit(JarOfDirt_OnHit)

    inst:ListenForEvent("floater_startfloating", JarOfDirt_OnStartFloating)
    inst:ListenForEvent("floater_stopfloating",  JarOfDirt_OnStopFloating )

	return inst
end

return Prefab("pocketsand", pocketsandfn, assets, prefabs)