//
//  ViParticle.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViBase.h"
#import "ViColor.h"
#import "ViVector2.h"
#import "ViMesh.h"

namespace vi
{
    namespace scene
    {
        class particle
        {
        public:
            particle();
            virtual ~particle();
            
            virtual particle *recreate();
            virtual void visit(double timestep);
            
            
            GLfloat lifespan;
            GLfloat scale;
            
            vi::common::vector2 position;
            vi::graphic::color  color;
        };
        
        
        
        
        class baseParticleEffect
        {
        public:
            baseParticleEffect();
            
            GLfloat lifespan;
            GLfloat randomLifespan;
            
            GLfloat scale;
            GLfloat randomScale;
            
            GLfloat targetScale;
            GLfloat randomTargetScale;
            
            vi::common::vector2 randomPosition;
            
            vi::common::vector2 speed;
            vi::common::vector2 randomSpeed;
            
            vi::common::vector2 targetSpeed;
            vi::common::vector2 randomTargetSpeed;
            
            vi::graphic::color color;
            vi::graphic::color randomColor;
            
            vi::graphic::color targetColor;
            vi::graphic::color randomTargetColor;
        };
        
        class baseParticle : public particle
        {
        public:
            baseParticle(baseParticleEffect *effect);
            
            virtual particle *recreate();
            virtual void visit(double timestep);
            
        private:
            GLfloat scaleChange;
            vi::graphic::color colorChange;
            
            vi::common::vector2 speed;
            vi::common::vector2 speedChange;
            
            baseParticleEffect *effect;
        };
    }
}
