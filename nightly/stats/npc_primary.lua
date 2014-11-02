function applyDamageRequest(damageRequest)
  local damage = 0
  if damageRequest.damageType == "Damage" or damageRequest.damageType == "Knockback" then
    damage = damage + root.evalFunction2("protection", damageRequest.damage, status.stat("protection"))
  elseif damageRequest.damageType == "IgnoresDef" then
    damage = damage + damageRequest.damage
  end

  if damage > 0 and damageRequest.damageType ~= "Knockback" then
    status.modifyResource("health", -damage)
  end

  status.addEphemeralEffects(damageRequest.statusEffects)

  local knockbackFactor = (1 - status.stat("grit")) * (damage / status.resourceMax("health"))

  local knockbackMomentum = damageRequest.knockbackMomentum
  knockbackMomentum[1] = knockbackMomentum[1] * knockbackFactor
  knockbackMomentum[2] = knockbackMomentum[2] * knockbackFactor
  mcontroller.addMomentum(knockbackMomentum)

  return {{
    sourceEntityId = damageRequest.sourceEntityId,
    targetEntityId = entity.id(),
    position = mcontroller.position(),
    damage = damage,
    kind = "Normal",
    damageSourceKind = damageRequest.damageSourceKind,
    targetMaterialKind = status.statusProperty("targetMaterialKind"),
    killed = not status.resourcePositive("health")
  }}
end

function update(dt)
  local liquidStatusEffects = root.liquidStatusEffects(mcontroller.inLiquidId())
  if liquidStatusEffects then
    status.addEphemeralEffects(liquidStatusEffects)
  end

  local spatialStatusEffects = status.scanSpatialEffects(mcontroller.collisionBody())
  if spatialStatusEffects then
    status.addEphemeralEffects(spatialStatusEffects)
  end
end