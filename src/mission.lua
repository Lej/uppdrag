local Mission = LibStub("AceAddon-3.0"):GetAddon("Uppdrag"):NewModule("Mission")

function Mission:New(units)

  local followers = []
  local enemies = []
  for i, unit in ipairs(units) do
    local boardIndex = unit:GetBoardIndex()
    if (0 <= boardIndex and boardIndex <= 4) then
      table.insert(followers, unit)
    elseif (5 <= boardIndex and boardIndex <= 12) then
      table.insert(enemies, unit)
    end
  end

  return {
    round = 1,
    units = units,
    followers = followers,
    enemies = enemies
  }
end

function Mission:GetRound() return self.round end
function Mission:GetUnits() return self.units end
function Mission:GetFollowers() return self.followers end
function Mission:GetEnemies() return self.enemies end

function Mission:DoRound()
  local units = self:GetUnits()
  for i, unit in ipairs(units) do
    unit:DoRound(mission)
  end
end