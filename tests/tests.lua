luaunit = require("./tests/libs/luaunit")
require("./tests/libs/wow")
require("./tests/libs/utils")
require("./src/serializer")
require("./src/parser")

function test()

  local Parser = LibStub("AceAddon-3.0"):GetAddon("Uppdrag"):GetModule("Parser")

  local logPaths = GetCombatLogPaths()
  for i, logPath in ipairs(logPaths) do
    print(logPath)
    local combatLogText = ReadCombatLog(logPath)
    local combatLog = Parser:Parse(combatLogText)
    dump(combatLog)
  end


  --[[
  local combatLog = Test:ReadCombatLog()
  local Parser = LibStub("AceAddon-3.0"):GetAddon("Uppdrag"):GetModule("Parser")
  local root = Parser:Parse(combatLog)
  dump(root)



  luaunit.assertEquals({1, 2, 3}, {1, 2, 3})
  ]]
end

function GetCombatLogPaths()
  local info = debug.getinfo(2)
  local logDir = info.source:gsub("^@", ""):gsub([[\[^\]*.lua$]], [[\logs]])
  local cmd = [[dir "]] .. logDir .. [[" /b /a-d]]
  local logPaths = {}
  for logFile in io.popen(cmd):lines() do
    local logPath = logDir .. [[\]] .. logFile
    table.insert(logPaths, logPath)
  end
  return logPaths
end

function ReadCombatLog(path)
  local file = io.open(path, "rb")
  local combatLog = file:read("*all"):gsub("\r\n", "\n")
  file:close()
  return combatLog
end

os.exit(luaunit.LuaUnit.run())