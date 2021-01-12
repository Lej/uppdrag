local Debug = true

local AceGui = LibStub("AceGUI-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

local Uppdrag = LibStub("AceAddon-3.0"):GetAddon("Uppdrag")
local Serializer = Uppdrag:GetModule("Serializer")
local Util = Uppdrag:GetModule("Util")

function Uppdrag:OnInitialize()
  self:Debug("OnInitialize")

  self:RegisterEvent("ADDON_LOADED")
end

function Uppdrag:ShowGui()
  self:Debug("ShowGui")

  -- Current Mission
  local function DrawGroupCurrentMission(container)

    local editBox = AceGui:Create("MultiLineEditBox")
    editBox.editBox:SetMaxBytes(0)
    editBox:SetMaxLetters(0)
    editBox:SetLabel("")
    editBox:SetWidth(370)
    editBox:SetNumLines(38)
    editBox:DisableButton(true)
    editBox:SetText(self:GetCurrentMission())

    container:AddChild(editBox)

    self.currentMissionEditBox = editBox
  end

  -- Combat Log
  local function DrawGroupCombatLog(container)

    local editBox = AceGui:Create("MultiLineEditBox")
    editBox.editBox:SetMaxBytes(0)
    editBox:SetMaxLetters(0)
    editBox:SetLabel("")
    editBox:SetWidth(370)
    editBox:SetNumLines(38)
    editBox:DisableButton(true)
    editBox:SetText(self:GetCombatLog())

    container:AddChild(editBox)

    self.combatLogEditBox = editBox
  end

  -- Tabs
  local tabs = {
    [1] = {
      name = "Current Mission",
      draw = DrawGroupCurrentMission
    },
    [2] = {
      name = "Combat Log",
      draw = DrawGroupCombatLog
    }
  }

  local tabNameToDraw = {}
  local tabKeys = {}
  for i, tab in ipairs(tabs) do
    tabKeys[i] = {
      value = tab.name,--:gsub("%s+", ""),
      text = tab.name,
    }
    tabNameToDraw[tab.name] = tab.draw
  end

  local function SelectTab(container, event, tabName)
    self:Debug("SelectTab", tabName)
    container:ReleaseChildren()
    tabNameToDraw[tabName](container)
  end

  local tabGroup = AceGui:Create("TabGroup")
  tabGroup:SetLayout("Flow")
  tabGroup:SetTabs(tabKeys)
  tabGroup:SetCallback("OnGroupSelected", SelectTab)
  tabGroup:SelectTab(tabKeys[1].value)

  local frame = AceGui:Create("Frame")
  --frame:Hide()
  frame:SetTitle("Uppdrag")
  frame:SetCallback("OnClose", function(widget) AceGui:Release(widget) end)
  frame:SetPoint("TOPRIGHT", _G.CovenantMissionFrame, "TOPLEFT", -7, 7)
  frame:SetWidth(400)
  frame:SetHeight(676)
  frame:SetLayout("Fill")
  -- Hide bottom status
  frame.statustext:Hide()
  frame.statustext:GetParent():Hide()
  -- Hide close button
  local children = { frame.frame:GetChildren() }
  children[1]:Hide()

  frame:AddChild(tabGroup)

  self.gui = frame

end

function Uppdrag:FollowerFrameToString(board, followerFrame)
  local puck = board:GetFrameByBoardIndex(followerFrame.boardIndex)
  local health = puck:GetHealth()
  return "## " .. followerFrame.boardIndex .. "\n"
    .. "### boardIndex: " .. followerFrame.boardIndex .. "\n"
    .. "### name: " .. followerFrame.info.name .. "\n"
    .. "### level: " .. followerFrame.info.level .. "\n"
    .. "### health: " .. health .. "\n"
    .. "### maxHealth: " .. followerFrame.info.autoCombatantStats.maxHealth
end

function Uppdrag:EnemyFrameToString(enemyFrame)
  return "## " .. enemyFrame.boardIndex .. "\n"
    .. "### boardIndex: " .. enemyFrame.boardIndex .. "\n"
    .. "### name: " .. enemyFrame.name .. "\n"
    .. "### health: " .. enemyFrame.HealthBar.health
end

function Uppdrag:UnitsToString(board, variableName)

  local text = variableName .. "\n"

  local followerFrames = self:GetSortedFollowerFrames(board)
  for i, followerFrame in ipairs(followerFrames) do
    text = text .. self:FollowerFrameToString(board, followerFrame) .. "\n"
  end

  local enemyFrames = self:GetSortedEnemyFrames(board)
  for i, enemyFrame in ipairs(enemyFrames) do
    text = text .. self:EnemyFrameToString(enemyFrame) .. "\n"
  end

  return Util:Trim(text)
end

function Uppdrag:Hook()

  -- Catch unit status at start of completed mission
  self:SecureHook(_G.CovenantMissionFrame.MissionComplete.RewardsScreen, "PopulateFollowerInfo", function(_, followerInfo, missionInfo, winner)

    --self:Inspect(_G.CovenantMissionFrame.MissionComplete.currentMission)
    self:ClearCombatLog()

    local mission = _G.CovenantMissionFrame.MissionComplete.currentMission
    self:AddCombatLogLine("# mission")
    self:AddCombatLogLine("## name: " .. mission.name)
    self:AddCombatLogLine("## level: " .. mission.missionScalar)

    local board = _G.CovenantMissionFrame.MissionComplete.Board
    local text = self:UnitsToString(board, "# unitsPre")
    self:AddCombatLogLine(text)

    self:AddCombatLogLine("# combatLog")
  end)

  -- Catch mission combat log messages
  self:SecureHook(_G.CombatLog.CombatLogMessageFrame, "AddMessage", function(_, logEntry)
    self:AddCombatLogLine("+ " .. logEntry)
  end)

  -- Catch unit status at end of completed mission
  self:SecureHook(_G.CombatLog, "AddVictoryState", function(_, winState)

    local board = _G.CovenantMissionFrame.MissionComplete.Board
    local text = self:UnitsToString(board, "# unitsPost")
    self:AddCombatLogLine(text)
  end)

  -- Catch unit status when follower added to mission
  self:SecureHook(_G.CovenantMissionFrame, "AssignFollowerToMission", function(frame, info)

    local board = _G.CovenantMissionFrame.MissionTab.MissionPage.Board
    local text = self:UnitsToString(board, "# unitsPre")
    self:SetCurrentMission(text)
  end)
end

function Uppdrag:HideGui()
  self:Debug("HideGui")
  self.gui:Hide()
end

function Uppdrag:ClearCombatLog(text)
  self:SetCombatLog("")
end

function Uppdrag:AddCombatLogLine(text)
  self:SetCombatLog((self.combatLog or "") .. text .. "\n")
end

function Uppdrag:SetCombatLog(text)
  self.combatLog = text or ""
  if (self.combatLogEditBox) then
    self.combatLogEditBox:SetText(self.combatLog)
  end
end

function Uppdrag:GetCombatLog()
  return self.combatLog or ""
end

function Uppdrag:ADDON_LOADED(eventName, addonName)
  self:Debug("ADDON_LOADED", addonName)

  if addonName == "Blizzard_GarrisonUI" then
    self:RegisterEvent("ADVENTURE_MAP_OPEN")
    self:RegisterEvent("ADVENTURE_MAP_CLOSE")
    self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
    self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
    self:Hook()
    self:ShowGui()
  end
end

function Uppdrag:ADVENTURE_MAP_OPEN()
  self:Debug("ADVENTURE_MAP_OPEN")
  self:ShowGui()
end

function Uppdrag:ADVENTURE_MAP_CLOSE()
  self:Debug("ADVENTURE_MAP_CLOSE")
  self:HideGui()
end

function Uppdrag:GARRISON_MISSION_COMPLETE_RESPONSE(...)
  self:Debug("GARRISON_MISSION_COMPLETE_RESPONSE")
end

function Uppdrag:SetCurrentMission(text)
  self.currentMission = text or ""
  if (self.currentMissionEditBox) then
    self.currentMissionEditBox:SetText(self.currentMission)
  end
end

function Uppdrag:GetCurrentMission()
  return self.currentMission or ""
end

function Uppdrag:GARRISON_FOLLOWER_LIST_UPDATE(...)
  self:Debug("GARRISON_FOLLOWER_LIST_UPDATE")
end

function Uppdrag:GetSortedEnemyFrames(board)
  local enemyFrames = { }
  for enemyFrame in board:EnumerateEnemies() do
    if (enemyFrame:IsShown()) then
      table.insert(enemyFrames, enemyFrame)
    end
  end

  return self:SortBy(enemyFrames, function(x) return x.boardIndex end)
end

function Uppdrag:GetSortedFollowerFrames(board)
  local followerFrames = { }
  for followerFrame in board:EnumerateFollowers() do
    if (followerFrame.info) then
      table.insert(followerFrames, followerFrame)
    end
  end

  return self:SortBy(followerFrames, function(x) return x.boardIndex end)
end

function Uppdrag:SortBy(items, keySelector)
  local keys = { }
  local keyToItem = { }
  for _, item in pairs(items) do
     local key = keySelector(item)
     table.insert(keys, key)
     keyToItem[key] = item
  end
  table.sort(keys)

  local sorted = { }
  for i, key in ipairs(keys) do
     local item = keyToItem[key]
     table.insert(sorted, item)
  end
  return sorted
end

function Uppdrag:Debug(...)
  if (Debug) then
    self:Print(...)
  end
end

function Uppdrag:Inspect(...)

  local frame = AceGui:Create("Frame")
  --frame:Hide()
  frame:SetTitle("Inspect")
  frame:SetCallback("OnClose", function(widget) AceGui:Release(widget) end)
  --frame:SetPoint("TOPRIGHT", _G.CovenantMissionFrame, "TOPLEFT", -7, 7)
  frame:SetWidth(600)
  frame:SetHeight(800)
  frame:SetLayout("Fill")
  -- Hide bottom status
  frame.statustext:Hide()
  frame.statustext:GetParent():Hide()
  -- Hide close button
  --local children = { frame.frame:GetChildren() }
  --children[1]:Hide()

  local editBox = AceGui:Create("MultiLineEditBox")
  editBox.editBox:SetMaxBytes(0)
  editBox:SetMaxLetters(0)
  editBox:SetLabel("")
  --editBox:SetNumLines(38)
  editBox:DisableButton(true)

  frame:AddChild(editBox)

  local serialized = Serializer:Serialize(...)
  editBox:SetText(serialized)

end
