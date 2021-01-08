luaunit = require("./tests/libs/luaunit")
require("./tests/libs/wow")
require("./tests/libs/utils")
require("./src/serializer")
require("./src/parser")

function test()

  local combatLog = Test:ReadCombatLog()
  local Parser = LibStub("AceAddon-3.0"):GetAddon("Uppdrag"):GetModule("Parser")
  local root = Parser:Parse(combatLog)
  dump(root)



  luaunit.assertEquals({1, 2, 3}, {1, 2, 3})
end

os.exit(luaunit.LuaUnit.run())