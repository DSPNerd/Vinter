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
            mesh = new vi::common::meshRGBA(4, 6);
            mesh->addVertex(0.0, 1.0, 0.0, 0.0);
            mesh->addVertex(1.0, 1.0, 1.0, 0.0);
            mesh->addVertex(1.0, 0.0, 1.0, 1.0);
            mesh->addVertex(0.0, 0.0, 0.0, 1.0);
            
            mesh->addIndex(0);
            mesh->addIndex(3);
            mesh->addIndex(1);
            mesh->addIndex(2);
            mesh->addIndex(1);
            mesh->addIndex(3);
            
            lifespan = 1.0;
            scale = 1.0;
        }
        
        particle::~particle()
        {
            delete mesh;
        }
        
        
        particle *particle::recreate()
        {
            return new particle();
        }
        
        void particle::visit(double timestep)
        {
            lifespan -= timestep;
            
            vi::common::vertexRGBA *vertices = mesh->getVertices();
            vertices[0].r = color.r;
            vertices[0].g = color.g;
            vertices[0].b = color.b;
            vertices[0].a = color.a;
            
            vertices[1].r = color.r;
            vertices[1].g = color.g;
            vertices[1].b = color.b;
            vertices[1].a = color.a;
            
            vertices[2].r = color.r;
            vertices[2].g = color.g;
            vertices[2].b = color.b;
            vertices[2].a = color.a;
            
            vertices[3].r = color.r;
            vertices[3].g = color.g;
            vertices[3].b = color.b;
            vertices[3].a = color.a;
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
