local addonName, vars = ...
local Ld, La = {}, {}
local locale = GAME_LOCALE or GetLocale()

vars.L = setmetatable({},{
    __index = function(t, s) return La[s] or Ld[s] or rawget(t,s) or s end
})

-- Ld["All Stats"] = "All Stats"


if locale == "ruRU" then do end
La["History"] = "История"

end
