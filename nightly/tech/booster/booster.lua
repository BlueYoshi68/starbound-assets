function init()
  self.lastJump = false
  self.lastBoost = nil
  self.ranOut = false
end

function input(args)
  local currentJump = args.moves["jump"]
  local currentBoost = nil

  if not mcontroller.onGround() then
    if not mcontroller.canJump() and currentJump and not self.lastJump then
      if args.moves["right"] and args.moves["up"] then
        currentBoost = "boostRightUp"
      elseif args.moves["right"] and args.moves["down"] then
        currentBoost = "boostRightDown"
      elseif args.moves["left"] and args.moves["up"] then
        currentBoost = "boostLeftUp"
      elseif args.moves["left"] and args.moves["down"] then
        currentBoost = "boostLeftDown"
      elseif args.moves["right"] then
        currentBoost = "boostRight"
      elseif args.moves["down"] then
        currentBoost = "boostDown"
      elseif args.moves["left"] then
        currentBoost = "boostLeft"
      elseif args.moves["up"] then
        currentBoost = "boostUp"
      end
    elseif currentJump and self.lastBoost then
      currentBoost = self.lastBoost
    end
  end

  self.lastJump = currentJump
  self.lastBoost = currentBoost

  return currentBoost
end

function update(args)
  local boostControlForce = tech.parameter("boostControlForce")
  local boostSpeed = tech.parameter("boostSpeed")
  local energyUsagePerSecond = tech.parameter("energyUsagePerSecond")
  local energyUsage = energyUsagePerSecond * args.dt

  if args.availableEnergy < energyUsage then
    self.ranOut = true
  elseif mcontroller.onGround() or mcontroller.inLiquid() then
    self.ranOut = false
  end

  local boosting = false
  local diag = 1 / math.sqrt(2)

  if not self.ranOut then
    boosting = true
    if args.actions["boostRightUp"] then
      mcontroller.controlApproachVelocity({boostSpeed * diag, boostSpeed * diag}, boostControlForce, true, true)
    elseif args.actions["boostRightDown"] then
      mcontroller.controlApproachVelocity({boostSpeed * diag, -boostSpeed * diag}, boostControlForce, true, true)
    elseif args.actions["boostLeftUp"] then
      mcontroller.controlApproachVelocity({-boostSpeed * diag, boostSpeed * diag}, boostControlForce, true, true)
    elseif args.actions["boostLeftDown"] then
      mcontroller.controlApproachVelocity({-boostSpeed * diag, -boostSpeed * diag}, boostControlForce, true, true)
    elseif args.actions["boostRight"] then
      mcontroller.controlApproachVelocity({boostSpeed, 0}, boostControlForce, true, true)
    elseif args.actions["boostDown"] then
      mcontroller.controlApproachVelocity({0, -boostSpeed}, boostControlForce, true, true)
    elseif args.actions["boostLeft"] then
      mcontroller.controlApproachVelocity({-boostSpeed, 0}, boostControlForce, true, true)
    elseif args.actions["boostUp"] then
      mcontroller.controlApproachVelocity({0, boostSpeed}, boostControlForce, true, true)
    else
      boosting = false
    end
  end

  if boosting then
    tech.setAnimationState("boosting", "on")
    tech.setParticleEmitterActive("boostParticles", true)
    return energyUsage
  else
    tech.setAnimationState("boosting", "off")
    tech.setParticleEmitterActive("boostParticles", false)
    return 0
  end
end
