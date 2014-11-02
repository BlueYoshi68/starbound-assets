function init()
  self.airDashing = false
  self.dashTimer = 0
  self.dashDirection = 0
  self.dashLastInput = 0
  self.dashTapLast = 0
  self.dashTapTimer = 0
end

function input(args)
  if self.dashTimer > 0 then
    return nil
  end

  local maximumDoubleTapTime = tech.parameter("maximumDoubleTapTime")

  if self.dashTapTimer > 0 then
    self.dashTapTimer = self.dashTapTimer - args.dt
  end

  if args.moves["right"] then
    if self.dashLastInput ~= 1 then
      if self.dashTapLast == 1 and self.dashTapTimer > 0 then
        self.dashTapLast = 0
        self.dashTapTimer = 0
        return "dashRight"
      else
        self.dashTapLast = 1
        self.dashTapTimer = maximumDoubleTapTime
      end
    end
    self.dashLastInput = 1
  elseif args.moves["left"] then
    if self.dashLastInput ~= -1 then
      if self.dashTapLast == -1 and self.dashTapTimer > 0 then
        self.dashTapLast = 0
        self.dashTapTimer = 0
        return "dashLeft"
      else
        self.dashTapLast = -1
        self.dashTapTimer = maximumDoubleTapTime
      end
    end
    self.dashLastInput = -1
  else
    self.dashLastInput = 0
  end

  return nil
end

function update(args)
  local dashControlForce = tech.parameter("dashControlForce")
  local dashSpeed = tech.parameter("dashSpeed")
  local dashDuration = tech.parameter("dashDuration")
  local energyUsage = tech.parameter("energyUsage")

  local usedEnergy = 0
  if args.actions["dashRight"] and self.dashTimer <= 0 and args.availableEnergy > energyUsage then
    self.dashTimer = dashDuration
    self.dashDirection = 1
    usedEnergy = energyUsage
    self.airDashing = not mcontroller.onGround()
  elseif args.actions["dashLeft"] and self.dashTimer <= 0 and args.availableEnergy > energyUsage then
    self.dashTimer = dashDuration
    self.dashDirection = -1
    usedEnergy = energyUsage
    self.airDashing = not mcontroller.onGround()
  end

  if self.dashTimer > 0 then
    mcontroller.controlApproachXVelocity(dashSpeed * self.dashDirection, dashControlForce, true)

    if self.airDashing then
      mcontroller.controlParameters({gravityEnabled = false})
      mcontroller.controlApproachYVelocity(0, dashControlForce, true)
    end

    if self.dashDirection == -1 then
      mcontroller.controlFace(-1)
      tech.setFlipped(true)
    else
      mcontroller.controlFace(1)
      tech.setFlipped(false)
    end
    tech.setAnimationState("dashing", "on")
    tech.setParticleEmitterActive("dashParticles", true)
    self.dashTimer = self.dashTimer - args.dt
  else
    tech.setAnimationState("dashing", "off")
    tech.setParticleEmitterActive("dashParticles", false)
  end

  return usedEnergy
end
