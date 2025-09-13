local ENV = env
GLOBAL.setfenv(1, GLOBAL)

ENV.AddPrefabPostInit("slurtleslime", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("furgel")
end)