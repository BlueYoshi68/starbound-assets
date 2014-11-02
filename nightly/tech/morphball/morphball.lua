function init()
  self.specialLast = false
  self.primaryFireLast = false
  self.angularVelocity = 0
  self.angle = 0
  self.active = false
  tech.setVisible(false)
end

function uninit()
  if self.active then
    tech.setVisible(false)
    mcontroller.translate({0, -tech.parameter("ballTransformHeightChange")})
    tech.setParentDirectives()
    tech.setToolUsageSuppressed(false)
    self.active = false
  end
end

function input(args)
  local move = nil
  if args.moves["special"] == 1 and not self.specialLast then
    if self.active then
      return "morphballDeactivate"
    else
      return "morphballActivate"
    end
  end

  self.specialLast = args.moves["special"] == 1
  self.primaryFireLast = args.moves["primaryFire"]

  return move
end

function update(args)
  local energyCostPerSecond = tech.parameter("energyCostPerSecond")
  local ballCustomMovementParameters = tech.parameter("ballCustomMovementParameters")
  local ballTransformHeightChange = tech.parameter("ballTransformHeightChange")
  local ballDeactivateCollisionTest = tech.parameter("ballDeactivateCollisionTest")
  local ballRadius = tech.parameter("ballRadius")
  local ballFrames = tech.parameter("ballFrames")

  if not self.active and args.actions["morphballActivate"] then
    tech.setVisible(true)
    tech.burstParticleEmitter("morphballActivateParticles")
    mcontroller.translate({0, ballTransformHeightChange})
    tech.setParentDirectives("?multiply=00000000")
    tech.setToolUsageSuppressed(true)
    self.active = true
  elseif self.active and (args.actions["morphballDeactivate"] or energyCostPerSecond * args.dt > args.availableEnergy) then
    ballDeactivateCollisionTest[1] = ballDeactivateCollisionTest[1] + mcontroller.position()[1]
    ballDeactivateCollisionTest[2] = ballDeactivateCollisionTest[2] + mcontroller.position()[2]
    ballDeactivateCollisionTest[3] = ballDeactivateCollisionTest[3] + mcontroller.position()[1]
    ballDeactivateCollisionTest[4] = ballDeactivateCollisionTest[4] + mcontroller.position()[2]
    if not world.rectCollision(ballDeactivateCollisionTest) then
      tech.setVisible(false)
      tech.burstParticleEmitter("morphballDeactivateParticles")
      mcontroller.translate({0, -ballTransformHeightChange})
      tech.setParentDirectives()
      tech.setToolUsageSuppressed(false)
      self.angle = 0
      self.active = false
    else
      -- Make some kind of error noise if not auto-deactivating
    end
  end

  if self.active then
    mcontroller.controlParameters(ballCustomMovementParameters)

    if mcontroller.onGround() then
      -- If we are on the ground, assume we are rolling without slipping to
      -- determine the angular velocity
      self.angularVelocity = -mcontroller.measuredVelocity()[1] / ballRadius
    end

    self.angle = math.fmod(math.pi * 2 + self.angle + self.angularVelocity * args.dt, math.pi * 2)

    -- Rotation frames for the ball are given as one *half* rotation so two
    -- full cycles of each of the ball frames completes a total rotation.
    local rotationFrame = math.floor(self.angle / math.pi * ballFrames) % ballFrames
    tech.setGlobalTag("rotationFrame", rotationFrame)

    return energyCostPerSecond * args.dt
  end

  return 0
end
