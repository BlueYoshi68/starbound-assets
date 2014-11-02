--------------------------------------------------------------------------------
function init()
  self.sensors = sensors.create()

  capturepod.onInit()

  self.state = stateMachine.create({
    "attackState",
    "moveState",
    "captiveState"
  })
  self.state.leavingState = function(stateName)
    entity.setAnimationState("movement", "idle")
  end


  entity.setAggressive(true)
  entity.setDamageOnTouch(true)
  entity.setDeathParticleBurst("deathPoof")
  entity.setAnimationState("movement", "idle")
end

--------------------------------------------------------------------------------
function update(dt)
  util.trackTarget(entity.configParameter("noticeDistance"))
  if self.targetId ~= nil and not attacking() then
    self.state.pickState(self.targetId)
  end

  self.state.update(dt)
  self.sensors.clear()

  -- Update animation
  if mcontroller.onGround() then
    entity.setAnimationState("movement", "idle")
  else
    local velocity = mcontroller.velocity()

    if velocity[2] < 0 then
      entity.setAnimationState("movement", "fall")
    else
      entity.setAnimationState("movement", "jump")
    end
  end
end

--------------------------------------------------------------------------------
function damage(args)
  capturepod.onDamage(args)
end

--------------------------------------------------------------------------------
function shouldDie()
  return self.dead or entity.health() <= 0
end

--------------------------------------------------------------------------------
function setSpawnDirection(direction)
  local spawnVelocity = entity.configParameter("spawnVelocity")
  mcontroller.setVelocity({ spawnVelocity[1] * direction, spawnVelocity[2] })
end

--------------------------------------------------------------------------------
function poSize()
  return entity.configParameter("poSize")
end

--------------------------------------------------------------------------------
function attacking()
  return self.state.stateDesc() == "attackState"
end

--------------------------------------------------------------------------------
function move(delta, run)
  if not mcontroller.onGround() and self.jumpHoldTime > 0 then
    mcontroller.controlHoldJump()
    self.jumpHoldTime = math.max(0, self.jumpHoldTime - dt)
  end

  if mcontroller.onGround() then
    entity.idle()

    if delta[2] > entity.configParameter("largeJumpYThreshold") then
      self.jumpHoldTime = entity.configParameter("largeHumpHoldTime")
    else
      self.jumpHoldTime = 0
    end
  end

  mcontroller.controlMove(delta[1], true)
end

--------------------------------------------------------------------------------
moveState = {}

function moveState.enter()
  if capturepod.isCaptive() then return nil end

  return {
    timer = entity.randomizeParameterRange("moveTimeRange"),
    direction = util.toDirection(math.random(100) - 50)
  }
end

function moveState.update(dt, stateData)
  if self.sensors.blockedSensors.collision.any(true) then
    stateData.direction = -stateData.direction
  end

  move({ stateData.direction, 0 }, false)

  stateData.timer = stateData.timer - dt
  if stateData.timer <= 0 then
    return true, entity.randomizeParameterRange("moveCooldownTimeRange")
  end

  return false
end

--------------------------------------------------------------------------------
attackState = {}

function attackState.enterWith(targetId)
  return { timer = 0 }
end

function attackState.update(dt, stateData)
  if self.targetPosition == nil then return true end

  if self.targetId == nil then
    stateData.timer = stateData.timer + dt
    if stateData.timer > entity.configParameter("attackSearchTime") then
      return true
    end
  end

  local toTarget = world.distance(self.targetPosition, mcontroller.position())
  move(toTarget, true)

  return false
end

--------------------------------------------------------------------------------
captiveState = {
  closeDistance = 4,
  runDistance = 12,
}

function captiveState.enter()
  if not capturepod.isCaptive() or self.targetId ~= nil then return nil end

  return { running = false }
end

function captiveState.update(dt, stateData)
  -- Translate owner uuid to entity id
  if self.ownerEntityId ~= nil then
    if not world.entityExists(self.ownerEntityId) then
      self.ownerEntityId = nil
    end
  end

  if self.ownerEntityId == nil then
    local playerIds = world.entityQuery(mcontroller.position(), 50, {includedTypes = {"player"}})
    for _, playerId in pairs(playerIds) do
      if world.entityUuid(playerId) == storage.ownerUuid then
        self.ownerEntityId = playerId
        break
      end
    end
  end

  -- Owner is nowhere around
  if self.ownerEntityId == nil then
    return false
  end

  local ownerPosition = world.entityPosition(self.ownerEntityId)
  local toOwner = world.distance(ownerPosition, mcontroller.position())
  local distance = math.abs(toOwner[1])

  local movement
  if distance < captiveState.closeDistance then
    stateData.running = false
    movement = 0
  elseif toOwner[1] < 0 then
    movement = -1
  elseif toOwner[1] > 0 then
    movement = 1
  end

  if distance > captiveState.runDistance then
    stateData.running = true
  end

  move({ movement, toOwner[2] }, stateData.running)

  return false
end
