function init()
  self.multiJumps = 0
  self.lastJump = false
end

function input(args)
  if args.moves["jump"] and not mcontroller.jumping() and not mcontroller.canJump() and not self.lastJump then
    self.lastJump = true
    return "multiJump"
  else
    self.lastJump = args.moves["jump"]
    return nil
  end
end

function update(args)
  local multiJumpCount = tech.parameter("multiJumpCount")
  local energyUsage = tech.parameter("energyUsage")

  if args.actions["multiJump"] and self.multiJumps < multiJumpCount and args.availableEnergy > energyUsage then
    mcontroller.controlJump(true)
    self.multiJumps = self.multiJumps + 1
    tech.burstParticleEmitter("multiJumpParticles")
    tech.playImmediateSound(tech.parameter("sound"))
    return energyUsage
  else
    if mcontroller.onGround() or mcontroller.inLiquid() then
      self.multiJumps = 0
    end

    return 0.0
  end
end
