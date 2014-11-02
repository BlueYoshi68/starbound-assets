function init()
  self.immunityEffects = effect.configParameter("immunityEffects") or {}
  self.clearEffects = effect.configParameter("clearEffects") or {}

  for _,clearEffect in ipairs(self.clearEffects) do
    status.removeEphemeralEffect(clearEffect)
  end
end

function update(dt)
  for _,immunityEffects in ipairs(self.immunityEffects) do
    status.removeEphemeralEffect(immunityEffects)
  end
end

function uninit()
end
