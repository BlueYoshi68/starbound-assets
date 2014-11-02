-- Swoop from the current position towards the target, then retreat back towards
-- the starting position

flyingSwoopBounceAttack = {
  stateCooldown = 1.0
}

function flyingSwoopBounceAttack.enter()
  return { swoopBounceTimer = 0.0 }
end

function flyingSwoopBounceAttack.update(dt, stateData)
  mcontroller.controlFace(self.toTarget[1])

  if self.toTarget[2] > 0 then
    return true
  elseif self.sensors.upSensors.collision.any(true) then
    return true
  elseif self.sensors.downSensors.collision.any(true) then
    return true
  elseif not entity.entityInSight(self.target) then
    return true
  else
    entity.setAggressive(true)
    if stateData.swoopBounceTimer > 0.0 then
      local bounceAngle = entity.configParameter("swoopBounceAngle") * math.pi / 180
      local vector = { math.cos(bounceAngle), math.sin(bounceAngle) }

      if self.toTarget[1] > 0 then
        vector[1] = -vector[1]
      end

      mcontroller.controlFly(vec2.mul(vector, mcontroller.baseParameters().flySpeed), true)
      stateData.swoopBounceTimer = stateData.swoopBounceTimer - dt
      if stateData.swoopBounceTimer < 0.0 then
        return true
      end
    else
      mcontroller.controlFly(vec2.mul({ self.toTarget[1], self.toTarget[2] }, mcontroller.baseParameters().flySpeed), true)

      if world.magnitude(self.toTarget) < entity.configParameter("swoopBounceLimit") then
        stateData.swoopBounceTimer = entity.configParameter("swoopBounceTime")
      end
    end

    return false
  end
end
