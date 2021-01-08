local Uppdrag = { }
local AceAddon = { }
LibStub = { }

function Uppdrag:NewModule(moduleName)
  if (not self.modules) then
    self.modules = { }
  end
  if (self.modules[moduleName]) then
    error(moduleName, 2)
  end
  self.modules[moduleName] = { }
  return self.modules[moduleName]
end

function Uppdrag:GetModule(moduleName)
  return self.modules[moduleName]
end

function AceAddon:NewAddon(addonName)
  if (addonName == "Uppdrag") then
    return Uppdrag
  end
  error(addonName)
end

function AceAddon:GetAddon(addonName)
  if (addonName == "Uppdrag") then
    return Uppdrag
  end
  error(addonName)
end

function LibStub:GetLibrary(major)
  if (major == "AceAddon-3.0") then
    return AceAddon
  end
  error(major)
end

setmetatable(LibStub, { __call = LibStub.GetLibrary })

function dump(...)
  local serializer = LibStub("AceAddon-3.0"):GetAddon("Uppdrag"):GetModule("Serializer")
  local text = serializer:Serialize(...)
  print(text)
end