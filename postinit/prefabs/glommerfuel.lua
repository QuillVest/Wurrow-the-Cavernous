local ENV = env
GLOBAL.setfenv(1, GLOBAL)

ENV.AddPrefabPostInit("glommerfuel", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("furgel")
end)