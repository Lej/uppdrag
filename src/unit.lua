local Unit = LibStub("AceAddon-3.0"):GetAddon("Uppdrag"):NewModule("Unit")

function Unit:New(boardIndex, name, level, maxHealth, health)
  local maxHealth = maxHealth or health,
  local info = self:GetUnitInfo(name, level)
  return {
    boardIndex = boardIndex,
    name = name,
    level = level,
    health = health,
    maxHealth = maxHealth
    info = info
  }
end

function Unit:GetBoardIndex() return self.boardIndex end
function Unit:GetLevel() return self.level end
function Unit:GetHealth() return self.health end

function Unit:DoRound(mission)

end

function Unit:GetUnitInfo(name)
  return UnitInfo[name]
end

local UnitInfo = {
  ["Ardenweald Trapper"] = {
    Attack = {
      Type = "Melee",
      Damage = function(unit) return 3 * unit:GetLevel() + 30 end
    }
    Abilities = {
      [1] = function(mission, unit)
        local round = mission:GetRound()
        local enemies = mission:GetEnemies()
        -- TODO Fortsätter auran efter att denna unit dör?
        -- TODO Hur stackar auran?
        if (round % 7 == 1) then

        elseif (round % )

      end
    }
  }
}