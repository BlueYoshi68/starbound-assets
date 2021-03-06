wanderSkipState = {}

function wanderSkipState.enterWith(params)
  if not params.wander then return nil end
  
  return wanderSkipState.enter()
end

function wanderSkipState.enter()
  if hasTarget() or isCaptive() then return nil end

  return {
    wanderTimer = entity.randomizeParameterRange("wanderTime"),
    wanderMovementTimer = entity.randomizeParameterRange("wanderMovementTime"),
    wanderFlipTimer = 0,
    movement = util.randomDirection()
  }
end

function wanderSkipState.update(dt, stateData)
  if hasTarget() then return true end

  if self.jumpTimer > 0 and not mcontroller.onGround() then
    mcontroller.controlHoldJump()
  elseif self.territory ~= 0 then
    if isBlocked() or willFall() then
      storage.basePosition = self.position
    else
      stateData.movement = self.territory
      stateData.wanderTimer = entity.randomizeParameterRange("wanderTime")
      stateData.wanderMovementTimer = entity.randomizeParameterRange("wanderMovementTime")
    end
  elseif stateData.movement ~= 0 and (willFall() or isBlocked()) then
    if math.random() < entity.configParameter("wanderJumpProbability") then
      self.jumpTimer = entity.randomizeParameterRange("jumpTime")
      jump()
    elseif stateData.wanderFlipTimer <= 0 then
      stateData.movement = -stateData.movement
      stateData.wanderTimer = entity.randomizeParameterRange("wanderTime")
      stateData.wanderFlipTimer = entity.configParameter("wanderFlipTimer") or 0.5
    end
  else
    if stateData.wanderTimer <= 0 then
      return true
    end
  end

  moveX(stateData.movement, false)

  entity.setAnimationState("attack", "idle")
  if not mcontroller.onGround() then
    entity.setAnimationState("movement", "jump")
    entity.setParticleEmitterActive("skipnotes", false)
  elseif stateData.movement ~= 0 then
    entity.setAnimationState("movement", "skip")
    entity.setParticleEmitterActive("skipnotes", true)
  else
    entity.setAnimationState("movement", "idle")
    entity.setParticleEmitterActive("skipnotes", false)
  end

  if stateData.wanderMovementTimer <= 0 then
    stateData.movement = 0
  end

  if self.idleSoundTimer <= 0 then
    entity.playSound(entity.randomizeParameter("idleNoise"))
    self.idleSoundTimer = entity.randomizeParameterRange("idleSoundTime")
  end

  stateData.wanderTimer = stateData.wanderTimer - dt
  stateData.wanderMovementTimer = stateData.wanderMovementTimer - dt
  stateData.wanderFlipTimer = stateData.wanderFlipTimer - dt

  return false
end
