function init()
  script.setUpdateDelta(5)

  self.tickTimer = 1
  self.degen = 0.005

  self.pulseTimer = 0
  self.halfPi = math.pi / 2
end

function update(dt)
  mcontroller.controlModifiers({
      runModifier = -0.4,
      jumpModifier = -0.4
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

  local pulseMagnitude = math.cos(self.pulseTimer - self.halfPi)
  local dString = string.format("fade=AAFF88=%.3f?border=2;AAFF88%2x;00000000", (pulseMagnitude * 0.3 + 0.1), math.floor(pulseMagnitude * 70) + 10)
  world.logInfo(dString)
  effect.setParentDirectives(dString)
end

function uninit()

end