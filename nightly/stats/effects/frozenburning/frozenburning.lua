function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  animator.setParticleEmitterOffsetRegion("frozenfiretrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("frozenfiretrail", true)
  effect.setParentDirectives("fade=AC00BF=0.25")
  
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
  
  mcontroller.controlModifiers({
      groundMovementModifier = -0.7,
      runModifier = -0.25,
      jumpModifier = -0.25
    })

  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = 3,
        damageSourceKind = "frozenburning",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()
  
end