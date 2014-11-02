function init()
  self.range = effect.configParameter("range") or 3
  self.minRange = effect.configParameter("minRange") or 0.5

  self.projectileCount = effect.configParameter("projectileCount") or 20
  self.projectileType = effect.configParameter("projectileType") or "armorthorns"
  self.projectileSpeed = effect.configParameter("projectileSpeed") or 20
  self.damageMultiplier = effect.configParameter("damageMultiplier") or 0.01

  self.cooldown = effect.configParameter("cooldown") or 5
  self.thornsDuration = effect.configParameter("thornsDuration") or 0.2

  self.projectileTimeToLive = self.range / self.projectileSpeed

  resetThorns()
  self.cooldownTimer = 0
end

function resetThorns()
  self.cooldownTimer = self.cooldown
  self.triggerThorns = false
  self.thornsTimer = 0
  self.spawnedThorns = 0
  self.thornDamage = 0

  effect.setParentDirectives("")
end

function update(dt)
  if self.cooldownTimer > 0 then
    self.cooldownTimer = self.cooldownTimer - dt
  end

  if self.triggerThorns then
    self.thornsTimer = self.thornsTimer - dt

    local fadeOpacity = ((self.projectileCount - self.spawnedThorns) / self.projectileCount) * 0.8
    effect.setParentDirectives("fade=993300="..fadeOpacity)

    if self.thornsTimer <= 0 then
      local thornInterval = self.thornsDuration / self.projectileCount

      --It's possible we need to spawn several thorns because they need to spawn very fast
      local thornCount = math.floor((thornInterval - self.thornsTimer) / thornInterval)
      thornCount = math.min(thornCount, self.projectileCount - self.spawnedThorns)

      spawnThorns(self.thornDamage, thornCount)

      self.thornsTimer = self.thornsTimer + thornCount * thornInterval

      if self.spawnedThorns >= self.projectileCount then resetThorns() end
    end
  end
end

function spawnThorns(needleDamage, count)
  if count == nil then count = 1 end
  local pi = 3.14

  for x = 1, count do
    local randAngle = math.random() * 2 * pi --Random radian
    local needleVector = {math.cos(randAngle), math.sin(randAngle)}

    local position = mcontroller.position()
    local perimeterPosition = {
      position[1] + needleVector[1] * self.minRange,
      position[2] + needleVector[2] * self.minRange
    }
    local needleConfig = {
      power = needleDamage, 
      timeToLive = self.projectileTimeToLive,
      speed = self.projectileSpeed,
      physics = "default"
    }

    world.spawnProjectile(self.projectileType, perimeterPosition, entity.id(), needleVector, true, needleConfig)

    self.spawnedThorns = self.spawnedThorns + 1
  end
end

function triggerThorns(damage)
  self.triggerThorns = true
  self.thornDamage = damage
  self.thornsTimer = 0
end

function selfDamage(notification)
  if self.cooldownTimer <= 0 and notification.sourceEntityId ~= notification.targetEntityId then
    triggerThorns(notification.damage * self.damageMultiplier)
    self.cooldownTimer = self.cooldown
  end
end
