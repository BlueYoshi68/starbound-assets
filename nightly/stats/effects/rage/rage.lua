function init()
  --Slow
  self.runModifier = effect.configParameter("runModifier") or -0.35
  self.jumpModifier = effect.configParameter("jumpModifier") or -0.35
  self.groundMovementModifier = effect.configParameter("groundMovementModifier") or -0.5

  local slows = status.statusProperty("slows", {})
  slows["rageslow"] = 1 + self.runModifier
  status.setStatusProperty("slows", slows)

  --Power
  self.powerModifier = effect.configParameter("powerModifier") or 0.5
  effect.addStatModifierGroup({{stat = "powerMultiplier", basePercentage = self.powerModifier}})

  animator.setParticleEmitterOffsetRegion("embers", mcontroller.boundBox())
  animator.setParticleEmitterActive("embers", true)

  local statusTextRegion = { 0, 1, 0, 1 }
  animator.setParticleEmitterOffsetRegion("statustext", statusTextRegion)
  animator.burstParticleEmitter("statustext")
end


function update(dt)
  mcontroller.controlModifiers({
    groundMovementModifier = self.groundMovementModifier,
    runModifier = self.runModifier,
    jumpModifier = self.jumpModifier
  })

end

function uninit()

end
