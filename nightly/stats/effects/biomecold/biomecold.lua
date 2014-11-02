function init()
  animator.setParticleEmitterOffsetRegion("snow", mcontroller.boundBox())
  animator.setParticleEmitterActive("snow", true)
  
  script.setUpdateDelta(5)

  self.tickTimer = 1
  self.degen = 0.005

  self.pulseTimer = 0
  self.halfPi = math.pi / 2
end

function update(dt)
  mcontroller.controlModifiers({
      groundMovementModifier = -0.9,
      runModifier = -0.5,
      jumpModifier = -0.3
    })

  mcontroller.controlParameters({
      normalGroundFriction = 0.9
    })

  status.modifyResourcePercentage("energy", -self.degen * dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = 1
    self.degen = self.degen + 0.005
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.degen * status.resourceMax("health"),
        sourceEntityId = entity.id()
      })
  end

  self.pulseTimer = self.pulseTimer + dt * 2
  if self.pulseTimer >= math.pi then
    self.pulseTimer = self.pulseTimer - math.pi
  end
  effect.setParentDirectives("fade=AAAAFF="..math.cos(self.pulseTimer - self.halfPi) * 0.2 + 0.2)
end

function uninit()

end