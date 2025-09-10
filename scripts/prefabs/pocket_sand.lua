-- local function GelBlobBottle_OnEquip(inst, owner)
-- 	owner.AnimState:OverrideSymbol("swap_object", "swap_gelblobbottle", "swap_bottle")
-- 	owner.AnimState:Show("ARM_carry")
-- 	owner.AnimState:Hide("ARM_normal")
-- end

-- local function GelBlobBottle_OnUnequip(inst, owner)
-- 	owner.AnimState:Hide("ARM_carry")
-- 	owner.AnimState:Show("ARM_normal")
-- end

-- local function GelBlobBottle_OnHit(inst, attacker, target)
-- 	local x, y, z = inst.Transform:GetWorldPosition()
-- 	if not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) and not TheWorld.Map:GetPlatformAtPoint(x,z) then
-- 		SpawnPrefab("splash_green_small").Transform:SetPosition(x,y,z)
-- 		inst.components.inventoryitem.canbepickedup = false

-- 		inst.AnimState:PlayAnimation("bob_gelblob")
-- 		inst:ListenForEvent("animover", inst.Remove)
-- 	else
-- 		SpawnPrefab("messagebottle_break_fx").Transform:SetPosition(x, y, z)
-- 		inst:Remove()
-- 		local blob = SpawnPrefab("gelblob_small_fx")
-- 		blob.Transform:SetPosition(x, 0, z)
-- 		blob:SetLifespan(TUNING.TOTAL_DAY_TIME)
-- 		blob:ReleaseFromBottle()
-- 	end
-- end

-- local function GelBlobBottle_OnThrown(inst)
-- 	inst:AddTag("NOCLICK")
-- 	inst.persists = false

-- 	inst.AnimState:PlayAnimation("spin_gelblob_loop", true)

-- 	inst.Physics:SetMass(1)
-- 	inst.Physics:SetFriction(0)
-- 	inst.Physics:SetDamping(0)
-- 	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
-- 	inst.Physics:SetCollisionMask(
-- 		COLLISION.WORLD,
-- 		COLLISION.OBSTACLES,
-- 		COLLISION.ITEMS
-- 	)
-- 	inst.Physics:SetCapsule(.2, .2)
-- end

-- local function GelBlobBottle_OnStartFloating(inst)
-- 	inst.AnimState:PlayAnimation("idle_gelblob_water")
-- end

-- local function GelBlobBottle_OnStopFloating(inst)
-- 	inst.AnimState:PlayAnimation("idle_gelblob")
-- end

-- local function gelblobbottlefn()
-- 	local inst = CreateEntity()

--     inst.entity:AddTransform()
--     inst.entity:AddAnimState()
--     inst.entity:AddNetwork()

--     inst.AnimState:SetBank("bottle")
--     inst.AnimState:SetBuild("bottle")
-- 	inst.AnimState:PlayAnimation("idle_gelblob")

-- 	--waterproofer (from waterproofer component) added to pristine state for optimization
-- 	inst:AddTag("waterproofer")

-- 	--projectile (from complexprojectile component) added to pristine state for optimization
-- 	inst:AddTag("projectile")
-- 	inst:AddTag("complexprojectile")

-- 	MakeInventoryPhysics(inst)
-- 	MakeInventoryFloatable(inst, "small", 0.05, 1)

--     inst.entity:SetPristine()

--     if not TheWorld.ismastersim then
--         return inst
-- 	end

--     inst:AddComponent("inspectable")
-- 	inst:AddComponent("inventoryitem")

--     inst:AddComponent("stackable")
-- 	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

-- 	inst:AddComponent("waterproofer")
-- 	inst.components.waterproofer:SetEffectiveness(0)

-- 	inst:AddComponent("equippable")
-- 	inst.components.equippable:SetOnEquip(GelBlobBottle_OnEquip)
-- 	inst.components.equippable:SetOnUnequip(GelBlobBottle_OnUnequip)
-- 	inst.components.equippable.equipstack = true

-- 	inst:AddComponent("complexprojectile")
-- 	inst.components.complexprojectile:SetHorizontalSpeed(15)
-- 	inst.components.complexprojectile:SetGravity(-35)
-- 	inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
-- 	inst.components.complexprojectile:SetOnLaunch(GelBlobBottle_OnThrown)
-- 	inst.components.complexprojectile:SetOnHit(GelBlobBottle_OnHit)

--     inst:ListenForEvent("floater_startfloating", GelBlobBottle_OnStartFloating)
--     inst:ListenForEvent("floater_stopfloating",  GelBlobBottle_OnStopFloating )

-- 	return inst
-- end

-- return
-- 	Prefab("gelblob_bottle", gelblobbottlefn, assets_gelblob, prefabs_gelblob)