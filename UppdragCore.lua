local Debug = true

local Uppdrag = LibStub("AceAddon-3.0"):NewAddon("Uppdrag", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0")
local AceGui = LibStub("AceGUI-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

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

function Uppdrag:Hook()

  -- Catch follower status at start of completed mission
  self:SecureHook(_G.CovenantMissionFrame.MissionComplete.RewardsScreen, "PopulateFollowerInfo", function(_, followerInfo, missionInfo, winner)

    self:ClearCombatLog()

    for guid, info in pairs(followerInfo) do
      info.guid = guid
    end

    local sorted = self:SortBy(followerInfo, function(x) return x.boardIndex end)

    for i, info in ipairs(sorted) do
      self:AddCombatLogLine("index: " .. info.boardIndex)
      self:AddCombatLogLine("guid: " .. info.guid)
      self:AddCombatLogLine("name: " .. info.name)
      self:AddCombatLogLine("level: " .. info.level)
      self:AddCombatLogLine("health: " .. info.health)
      self:AddCombatLogLine("")
    end

  end)

  -- Catch mission combat log messages
  self:SecureHook(_G.CombatLog.CombatLogMessageFrame, "AddMessage", function(_, logEntry)
    self:AddCombatLogLine(logEntry)
  end)

  -- Catch follower status at end of completed mission
  self:SecureHook(_G.CombatLog, "AddVictoryState", function(_, winState)

    local board = _G.CovenantMissionFrame.MissionComplete.Board
    local followerFrames = self:GetSortedFollowerFrames(board, function(x) return x.info.boardIndex end)

    for i, followerFrame in ipairs(followerFrames) do
      local puck = board:GetFrameByBoardIndex(followerFrame.info.boardIndex)
      local health = puck:GetHealth()
      self:AddCombatLogLine("")
      self:AddCombatLogLine("index: " .. followerFrame.info.boardIndex)
      self:AddCombatLogLine("guid: " .. followerFrame.followerGUID)
      self:AddCombatLogLine("name: " .. followerFrame.info.name)
      self:AddCombatLogLine("health: " .. health)
    end

  end)

  -- Catch followers added to missions
  self:SecureHook(_G.CovenantMissionFrame, "AssignFollowerToMission", function(frame, info)
    local missionPage = _G.CovenantMissionFrame:GetMissionPage()
    local followerFrames = self:GetSortedFollowerFrames(missionPage.Board, function(x) return x.boardIndex end)

    local text = ""
    for i, followerFrame in ipairs(followerFrames) do
      if (followerFrame.info) then
        text = text .. "index: " .. followerFrame.boardIndex .. "\n"
          .. "guid: " .. followerFrame.followerGUID .. "\n"
          .. "name: " .. followerFrame.name .. "\n"
          .. "level: " .. followerFrame.info.level .. "\n"
          .. "health: " .. followerFrame.info.autoCombatantStats.currentHealth .. "\n"
          .. "\n"
      end
    end

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

function Uppdrag:GetSortedFollowerFrames(board, boardIndexSelector)
  local followerFrames = { }
  for followerFrame in board:EnumerateFollowers() do
      table.insert(followerFrames, followerFrame)
  end

  return self:SortBy(followerFrames, boardIndexSelector)
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
     print(i)
     local item = keyToItem[key]
     print(item)
     table.insert(sorted, item)
  end
  return sorted
end

function Uppdrag:Debug(...)
  if (Debug) then
    self:Print(...)
  end
end