function init()
  animator.setParticleEmitterOffsetRegion("sparkles", mcontroller.boundBox())
  animator.setParticleEmitterActive("sparkles", true)
  effect.setParentDirectives("fade=FFFFCC;0.03?border=2;FFFFCC20;00000000")
end

function update(dt)
  
end

function uninit()
  
end