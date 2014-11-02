function init()
  self.superJumpTimer = 0
end

function input(args)
  if args.moves["jump"] and args.moves["up"] and mcontroller.onGround() then
    return "superjump"
  else
    return nil
  end
end

function update(args)
  local energyUsage = tech.parameter("energyUsage")
  local superJumpSpeed = tech.parameter("superjumpSpeed")
  local superJumpControlForce = tech.parameter("superjumpControlForce")
  local superJumpTime = tech.parameter("superjumpTime")
  local superjumpSound = tech.parameter("superjumpSound")

  local usedEnergy = 0

  if args.actions["superjump"] and mcontroller.onGround() and self.superJumpTimer <= 0 and args.availableEnergy > energyUsage then
    tech.playImmediateSound(superjumpSound)
    self.superJumpTimer = superJumpTime
    usedEnergy = energyUsage
  end

  tech.setFlipped(mcontroller.facingDirection() < 0)

  if self.superJumpTimer > 0 then
    mcontroller.controlApproachYVelocity(superJumpSpeed, superJumpControlForce)
    tech.setParticleEmitterActive("jumpParticles", true)
    self.superJumpTimer = self.superJumpTimer - args.dt
  else
    tech.setParticleEmitterActive("jumpParticles", false)
  end

  return usedEnergy
end
