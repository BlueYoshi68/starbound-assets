function init()
  self.holdingJump = false
  self.ranOut = false
end

function input(args)
  if args.moves["jump"] and mcontroller.jumping() then
    self.holdingJump = true
  elseif not args.moves["jump"] then
    self.holdingJump = false
  end

  if args.moves["jump"] and not mcontroller.canJump() and not self.holdingJump then
    return "jetpack"
  else
    return nil
  end
end

function update(args)
  local jetpackSpeed = tech.parameter("jetpackSpeed")
  local jetpackControlForce = tech.parameter("jetpackControlForce")
  local energyUsagePerSecond = tech.parameter("energyUsagePerSecond")
  local energyUsage = energyUsagePerSecond * args.dt

  if args.availableEnergy < energyUsage then
    self.ranOut = true
  elseif mcontroller.onGround() or mcontroller.inLiquid() then
    self.ranOut = false
  end

  if args.actions["jetpack"] and not self.ranOut then
    tech.setAnimationState("jetpack", "on")
    mcontroller.controlApproachYVelocity(jetpackSpeed, jetpackControlForce, true)
    return energyUsage
  else
    tech.setAnimationState("jetpack", "off")
    return 0
  end

  return usedEnergy
end
