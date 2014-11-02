-- Factory that creates a flying ranged attack state for a specific skill
function createRangedAttack(skillName)
  local rangedAttack = {}

  function rangedAttack.enter()
    if entity.entityInSight(self.target) then
      local params = entity.configParameter(skillName)

      rangedAttack.pType = type(params.projectile) == "table" and entity.staticRandomizeParameter(skillName..".projectile") or params.projectile
      rangedAttack.pPower = root.evalFunction("monsterLevelPowerMultiplier", entity.level()) * params.power
      rangedAttack.pSpeed = params.speed or 20.0
      rangedAttack.pGrav = root.projectileGravityMultiplier(rangedAttack.pType) or 1.0
      rangedAttack.pArc = params.arc
      rangedAttack.shots = params.shots or 1
      rangedAttack.fireInterval = params.fireInterval or 0.5

      rangedAttack.attackTime = rangedAttack.shots * rangedAttack.fireInterval
      rangedAttack.cooldownTime = 1.0

      return {
        basePosition = mcontroller.position(),
        timer = rangedAttack.attackTime,
        fireCooldown = 0,
        shotsRemaining = rangedAttack.shots
      }
    end

    return nil
  end

  function rangedAttack.update(dt, stateData)
    if not entity.entityInSight(self.target) then return true end
    if stateData.timer <= 0 then return true end
    if stateData.shotsRemaining <= 0 then return true end

    entity.setDamageOnTouch(false)
    entity.setAggressive(true)

    entity.setAnimationState("movement", "flyingAttack")

    local toTarget = world.distance(world.entityPosition(self.target), mcontroller.position())
    mcontroller.controlFace(toTarget[1])

    if stateData.fireCooldown <= 0 then
      rangedAttack.fire(toTarget)

      stateData.shotsRemaining = stateData.shotsRemaining - 1
      stateData.fireCooldown = rangedAttack.fireInterval
    end
    stateData.fireCooldown = stateData.fireCooldown - dt

    --don't fall!
    entity.flyTo(stateData.basePosition, true)

    stateData.timer = stateData.timer - dt
    return false
  end

  function rangedAttack.fire(direction)
    local pConfig = {
      power = rangedAttack.pPower,
      speed = rangedAttack.pSpeed
    }
    world.spawnProjectile(rangedAttack.pType, mcontroller.position(), entity.id(), direction, false, pConfig)
  end

  function rangedAttack.leavingState(stateData)
    entity.setAnimationState("movement", "flying")
  end

  return rangedAttack
end
