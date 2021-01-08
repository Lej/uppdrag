Test = { }

function Test:ReadCombatLog()
  local info = debug.getinfo(2)
  local path = info.source:gsub("^@", ""):gsub(".lua$", ".log")
  dump(path)
  local file = io.open(path, "rb")
  local combatLog = file:read("*all"):gsub("\r\n", "\n")
  file:close()
  return combatLog
end