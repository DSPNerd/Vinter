//
//  ViParticle.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViParticle.h"

namespace vi
{
    namespace scene
    {
        particle::particle()
        {
            lifespan = 1.0;
            scale = 1.0;
        }
        
        particle::~particle()
        {
        }

        particle *particle::recreate()
        {
            return new particle();
        }
        
        void particle::visit(double timestep)
        {
            lifespan -= timestep;
        }
        
        
        
        
        baseParticleEffect::baseParticleEffect()
        {
            color = vi::graphic::color(1.0, 1.0, 1.0, 1.0);
            targetColor = vi::graphic::color(1.0, 1.0, 1.0, 1.0);
            
            lifespan = 1.0;
            randomLifespan = 0.0;
            
            scale = 1.0;
            randomScale = 0.0;
            
            targetScale = 1.0;
            randomTargetScale = 0.0;
        }
        
     
        
        
        baseParticle::baseParticle(baseParticleEffect *teffect)
        {
            effect = teffect;
            lifespan = effect->lifespan + ViRandom(effect->randomLifespan);
            
            scale       = effect->scale + ViRandom(effect->randomScale);
            scaleChange = ((effect->targetScale + ViRandom(effect->randomTargetScale)) - scale) / lifespan;
            
            color       = effect->color + vi::graphic::color(ViRandom(effect->randomColor.r), ViRandom(effect->randomColor.g), ViRandom(effect->randomColor.b), ViRandom(effect->randomColor.a));
            colorChange = ((effect->targetColor + vi::graphic::color(ViRandom(effect->randomTargetColor.r), ViRandom(effect->randomTargetColor.g), ViRandom(effect->randomTargetColor.b), ViRandom(effect->randomTargetColor.a))) - color) / lifespan;
            
            speed       = effect->speed + vi::common::vector2(ViRandom(effect->randomSpeed.x), ViRandom(effect->randomSpeed.y));
            speedChange = ((effect->targetSpeed + vi::common::vector2(ViRandom(effect->randomTargetSpeed.x), ViRandom(effect->randomTargetSpeed.y))) - speed) / lifespan;
            
            position = vi::common::vector2(ViRandom(effect->randomPosition.x), ViRandom(effect->randomPosition.y));
        }
        
        particle *baseParticle::recreate()
        {
            return new baseParticle(effect);
        }
        
        void baseParticle::visit(double timestep)
        {
            speed       += speedChange * timestep;
            position    += speed * timestep;
            scale       += scaleChange * timestep;
            color       += colorChange * vi::graphic::color(timestep, timestep, timestep, timestep);
            
            particle::visit(timestep);
        }
    }
}
