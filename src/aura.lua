local Aura = LibStub("AceAddon-3.0"):GetAddon("Uppdrag"):NewModule("Aura")

function Aura:New(event, duration, callback)
  return {
    event = event,
    duration = duration,
    callback = callback
  }
end

function Aura:GetDuration() return self.duration end
function Aura:GetCallback() return self.callback end

function Aura:DoRound()
  self.duration = self.duration - 1
end


