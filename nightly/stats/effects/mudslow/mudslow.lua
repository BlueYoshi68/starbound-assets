function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  effect.setParentDirectives("fade=505000=0.6")

  local slows = status.statusProperty("slows", {})
  slows["mudslow"] = 0.8
  status.setStatusProperty("slows", slows)
end

function update(dt)
  mcontroller.controlModifiers({
      runModifier = -0.2,
      jumpModifier = -0.4
    })
end

function uninit()
  local slows = status.statusProperty("slows", {})
  slows["mudslow"] = nil
  status.setStatusProperty("slows", slows)
end