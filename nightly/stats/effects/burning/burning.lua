function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=BF3300=0.25")
  
  script.setUpdateDelta(5)

  self.tickTime = 1.0
  self.tickTimer = self.tickTime
end

function update(dt)
  if effect.duration()
    and ((world.visibleLiquidAt and world.visibleLiquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}))
    or (world.liquidAt and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}))) then
      effect.expire()
  end

  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = 3,
        damageSourceKind = "burning",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()
  
end