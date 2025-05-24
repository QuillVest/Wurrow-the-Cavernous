local ENV = env
GLOBAL.setfenv(1, GLOBAL)

local CarefulWalker = require("components/carefulwalker")

local _ToggleCareful = CarefulWalker.ToggleCareful
function CarefulWalker:ToggleCareful(...)
    if self.inst:HasTag("burrowed") then 
        return false
    end        
    return _ToggleCareful(self, ...)
end