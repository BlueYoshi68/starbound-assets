function init()
  self.active = false
  self.fireTimer = 0
  tech.setVisible(false)
  tech.rotateGroup("guns", 0, true)
end

function uninit()
  if self.active then
    local mechTransformPositionChange = tech.parameter("mechTransformPositionChange")
    mcontroller.translate({-mechTransformPositionChange[1], -mechTransformPositionChange[2]})
    tech.setParentOffset({0, 0})
    self.active = false
    tech.setVisible(false)
    tech.setParentState()
    tech.setToolUsageSuppressed(false)
  end
end

function input(args)
  if args.moves["special"] == 1 then
    if self.active then
      return "mechDeactivate"
    else
      return "mechActivate"
    end
  elseif args.moves["primaryFire"] then
    return "mechFire"
  end

  return nil
end

function update(args)
  local energyCostPerSecond = tech.parameter("energyCostPerSecond")
  local mechCustomMovementParameters = tech.parameter("mechCustomMovementParameters")
  local mechTransformPositionChange = tech.parameter("mechTransformPositionChange")
  local parentOffset = tech.parameter("parentOffset")
  local mechCollisionTest = tech.parameter("mechCollisionTest")
  local mechAimLimit = tech.parameter("mechAimLimit") * math.pi / 180
  local mechFrontRotationPoint = tech.parameter("mechFrontRotationPoint")
  local mechFrontFirePosition = tech.parameter("mechFrontFirePosition")
  local mechBackRotationPoint = tech.parameter("mechBackRotationPoint")
  local mechBackFirePosition = tech.parameter("mechBackFirePosition")
  local mechFireCycle = tech.parameter("mechFireCycle")
  local mechProjectile = tech.parameter("mechProjectile")
  local mechProjectileConfig = tech.parameter("mechProjectileConfig")

  if not self.active and args.actions["mechActivate"] then
    mechCollisionTest[1] = mechCollisionTest[1] + mcontroller.position()[1]
    mechCollisionTest[2] = mechCollisionTest[2] + mcontroller.position()[2]
    mechCollisionTest[3] = mechCollisionTest[3] + mcontroller.position()[1]
    mechCollisionTest[4] = mechCollisionTest[4] + mcontroller.position()[2]
    if not world.rectCollision(mechCollisionTest) then
      tech.burstParticleEmitter("mechActivateParticles")
      mcontroller.translate(mechTransformPositionChange)
      tech.setVisible(true)
      tech.setParentState("sit")
      tech.setToolUsageSuppressed(true)
      self.active = true
    else
      -- Make some kind of error noise
    end
  elseif self.active and (args.actions["mechDeactivate"] or energyCostPerSecond * args.dt > args.availableEnergy) then
    tech.burstParticleEmitter("mechDeactivateParticles")
    mcontroller.translate({-mechTransformPositionChange[1], -mechTransformPositionChange[2]})
    tech.setVisible(false)
    tech.setParentState()
    tech.setToolUsageSuppressed(false)
    tech.setParentOffset({0, 0})
    self.active = false
  end

  if self.active then
    local diff = world.distance(args.aimPosition, mcontroller.position())
    local aimAngle = math.atan2(diff[2], diff[1])
    local flip = aimAngle > math.pi / 2 or aimAngle < -math.pi / 2

    mcontroller.controlParameters(mechCustomMovementParameters)
    if flip then
      tech.setFlipped(true)
      local nudge = tech.appliedOffset()
      tech.setParentOffset({-parentOffset[1] - nudge[1], parentOffset[2] + nudge[2]})
      mcontroller.controlFace(-1)

      if aimAngle > 0 then
        aimAngle = math.max(aimAngle, math.pi - mechAimLimit)
      else
        aimAngle = math.min(aimAngle, -math.pi + mechAimLimit)
      end

      tech.rotateGroup("guns", math.pi - aimAngle)
    else
      tech.setFlipped(false)
      local nudge = tech.appliedOffset()
      tech.setParentOffset({parentOffset[1] + nudge[1], parentOffset[2] + nudge[2]})
      mcontroller.controlFace(1)

      if aimAngle > 0 then
        aimAngle = math.min(aimAngle, mechAimLimit)
      else
        aimAngle = math.max(aimAngle, -mechAimLimit)
      end

      tech.rotateGroup("guns", aimAngle)
    end

    if not mcontroller.onGround() then
      if mcontroller.velocity()[2] > 0 then
        tech.setAnimationState("movement", "jump")
      else
        tech.setAnimationState("movement", "fall")
      end
    elseif mcontroller.walking() or mcontroller.running() then
      if flip and mcontroller.movingDirection() == 1 or not flip and mcontroller.movingDirection() == -1 then
        tech.setAnimationState("movement", "backWalk")
      else
        tech.setAnimationState("movement", "walk")
      end
    else
      tech.setAnimationState("movement", "idle")
    end

    if args.actions["mechFire"] then
      if self.fireTimer <= 0 then
        world.spawnProjectile(mechProjectile, vec2.add(mcontroller.position(), tech.anchorPoint("frontGunFirePoint")), entity.id(), {math.cos(aimAngle), math.sin(aimAngle)}, false, mechProjectileConfig)
        self.fireTimer = self.fireTimer + mechFireCycle
        tech.setAnimationState("frontFiring", "fire")
      else
        local oldFireTimer = self.fireTimer
        self.fireTimer = self.fireTimer - args.dt
        if oldFireTimer > mechFireCycle / 2 and self.fireTimer <= mechFireCycle / 2 then
          world.spawnProjectile(mechProjectile, vec2.add(mcontroller.position(), tech.anchorPoint("backGunFirePoint")), entity.id(), {math.cos(aimAngle), math.sin(aimAngle)}, false, mechProjectileConfig)
          tech.setAnimationState("backFiring", "fire")
        end
      end
    end

    return energyCostPerSecond * args.dt
  end

  return 0
end
