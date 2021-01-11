local Util = LibStub("AceAddon-3.0"):GetAddon("Uppdrag"):NewModule("Util")

function Util:Trim(text)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end