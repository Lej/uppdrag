local Debug = true

local Uppdrag = LibStub("AceAddon-3.0"):NewAddon("Uppdrag", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0")
local AceGui = LibStub("AceGUI-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

function Uppdrag:OnInitialize()
  self:Debug("OnInitialize")

  self:RegisterEvent("ADDON_LOADED")
end

function Uppdrag:ADDON_LOADED(eventName, addonName)
  self:Debug("ADDON_LOADED", eventName, addonName)

  if addonName == "Blizzard_GarrisonUI" then
    self:CreateGui()
  end
end

function Uppdrag:CreateGui()
  self:Debug("CreateGui")

  local frame = AceGui:Create("Frame")
  --frame:Hide()
  frame:SetTitle("Uppdrag")
  frame:SetPoint("TOPRIGHT", _G.CovenantMissionFrame, "TOPLEFT", -7, 7)
  frame:SetWidth(400)
  frame:SetHeight(676)
  --frame:SetLayout("Fill")
  frame:SetLayout("List")
  frame.statustext:Hide()
  frame.statustext:GetParent():Hide()

  -- Hide close button
  local children = { frame.frame:GetChildren() }
  children[1]:Hide()

  local editbox = AceGui:Create("MultiLineEditBox")
  editbox.editBox:SetMaxBytes(0)
  editbox:SetMaxLetters(0)
  editbox:SetLabel("")
  editbox:SetWidth(370)
  editbox:SetNumLines(40)
  editbox:DisableButton(true)

  frame:AddChild(editbox)
  frame.editbox = editbox

  local button = AceGui:Create("Button")
  button:SetText("Refresh")
  button:SetWidth(100)
  button:SetCallback("OnClick", function(widget) self:UpdateCombatLog() end)
  frame:AddChild(button)



  --button.frame:SetParent(_G.CombatLog.CombatLogMessageFrame)

  --dump(_G.CombatLog.CombatLogMessageFrame)

  --_G.CombatLog:AddChild(button)

  --self:SecureHook("CovenantMissionFrame_OpenFrame", function()
  --  self:Debug("EJSuggestFrame_OpenFrame")
  --  self:UpdateVisibility()
  --end)

  --hooksecurefunc(_G["CovenantMissionFrame"], "ShowMission", KayrCovenantMissions.CMFrame_ShowMission_Hook)

  --[[
  dump("flork--------------------------------")
  dump(_G["CovenantMissionFrame"].MissionComplete.RewardsScreen == nil)
  dump("brosk--------------------------------")
  dump(_G["CovenantMissionFrame"].MissionComplete == nil)
  ]]--

  --self:SecureHook(_G["CovenantMissionFrame"].MissionComplete.RewardsScreen, "PopulateFollowerInfo", function(...)
  --self:SecureHook(_G.CovenantMissionFrame.MissionComplete.RewardsScreen, "PopulateFollowerInfo", function(...)
  self:SecureHook(_G.CovenantMissionFrame.MissionComplete.RewardsScreen, "PopulateFollowerInfo", function(_, followerInfo, missionInfo, winner)

    dump(followerInfo)

    self.gui.editbox:SetText("")

    local sorted = {}

    for guid, info in pairs(followerInfo) do

      sorted[info.boardIndex + 1] = info -- boardIndex zero based


      --dump(guid)
      --dump(info)
      --self:Debug(guid, info)
    end

    for i, info in ipairs(sorted) do
      --dump(info)
      self:AddLine(info.boardIndex)
      self:AddLine(info.name)
      self:AddLine(info.level)
      self:AddLine(info.health)
      self:AddLine("")
    end

    --self.result = sorted

    --self:Debug("PopulateFollowerInfo")
    --self:Debug("followerInfo", followerInfo)
    --self:Debug("missionInfo", missionInfo)
    --self:Debug("winner", winner)
  end)

  self:SecureHook(_G.CombatLog.CombatLogMessageFrame, "AddMessage", function(_, logEntry)
    --self:Debug("AddMessage")
    self:AddLine(logEntry)
  end)

  self:SecureHook(_G.CombatLog, "AddVictoryState", function(_, winState)
    --self:Debug("AddMessage")
    --self:AddLine("")

    local sorted = {}

    local board = _G.CovenantMissionFrame.MissionComplete.Board

    for followerFrame in board:EnumerateFollowers() do
      sorted[followerFrame.info.boardIndex + 1] = followerFrame
    end

    for i, followerFrame in ipairs(sorted) do
      local puck = board:GetFrameByBoardIndex(followerFrame.info.boardIndex)
      local health = puck:GetHealth()
      self:AddLine("")
      self:AddLine(followerFrame.info.boardIndex)
      self:AddLine(followerFrame.info.name)
      self:AddLine(followerFrame.info.level)
      self:AddLine(health)
    end


--[[
    for i, info in ipairs(self.result) do
      --dump(info)
      self:AddLine(info.boardIndex)
      self:AddLine(info.name)
      self:AddLine(info.level)
      self:AddLine(info.health)
      self:AddLine("")
    end]]--
  end)



  self:RegisterEvent("ADVENTURE_MAP_OPEN")
  self:RegisterEvent("ADVENTURE_MAP_CLOSE")
  self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")

  self.gui = frame

end

function Uppdrag:AddLine(text)
  --self:Debug("AddLine")
  self.gui.editbox:SetText(self.gui.editbox:GetText() .. text .. "\n")
end

function Uppdrag:UpdateCombatLog()
  self:Debug("UpdateCombatLog")
  local text = ""
  for i = 1, _G.CombatLog.CombatLogMessageFrame:GetNumMessages() do
    local line = _G.CombatLog.CombatLogMessageFrame:GetMessageInfo(i)
    text = text .. line .. "\n"
  end
  self.gui.editbox:SetText(text)
end

function Uppdrag:ADVENTURE_MAP_OPEN()
  self:Debug("ADVENTURE_MAP_OPEN")
  self.gui:Show()
end

function Uppdrag:ADVENTURE_MAP_CLOSE()
  self:Debug("ADVENTURE_MAP_CLOSE")
  self.gui:Hide()
end

function Uppdrag:GARRISON_MISSION_COMPLETE_RESPONSE(...)
  self:Debug("GARRISON_MISSION_COMPLETE_RESPONSE")

  --self.gui.editbox:SetText("")



  --local text = AceSerializer:Serialize(...)
  --self.gui.editbox:SetText(text)
  --dump(...)

  --local missionPage = _G["CovenantMissionFrame"]:GetMissionPage()
  --local missionPage = _G.CovenantMissionFrame:GetMissionPage()
  --for followerFrame in missionPage.Board:EnumerateFollowers() do
    --dump("----------------------")
    --dump(followerFrame.RewardsFollower)
    --local guid = followerFrame:GetFollowerGUID()
    --local info = guid and C_Garrison.GetFollowerInfo(guid)
    --self:Debug(guid, info)
    --local followerInfo = C_Garrison.GetFollowerInfo(followerID);

    --dump(followerFrame)
      --if followerFrame:GetFollowerGUID() then
        --  numFollowers = numFollowers + 1
      --end
  --end
end

--[[
function KayrCovenantMissions:GetNumMissionPlayerUnitsTotal()
  local numFollowers = 0
  local missionPage = _G["CovenantMissionFrame"]:GetMissionPage()
  for followerFrame in missionPage.Board:EnumerateFollowers() do
      if followerFrame:GetFollowerGUID() then
          numFollowers = numFollowers + 1
      end
  end
  return numFollowers
end
]]--

function Uppdrag:Debug(...)
  if (Debug) then
    self:Print(...)
  end
end