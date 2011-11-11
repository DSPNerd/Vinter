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
        /**
         * @brief Implementation of a particle without logic
         *
         * A particle is a object that contains state informations about one particle, which is used by an particleEmitter to draw the particle on the screen.
         * Usually you use, or create your own, subclass of this class which implements some custom logic for the particle.
         **/
        class particle
        {
        public:
            particle();
            virtual ~particle();
            
            /**
             * Must be overwritten by subclasses and return a new instance of the particle.
             * Used by the emitter class to automatically spawn particles.
             **/
            virtual particle *recreate();
            /**
             * Drains the lifespan of the particle
             **/
            virtual void visit(double timestep);
            
            /**
             * The lifespan of the particle in seconds
             * @default 1.0
             **/
            GLfloat lifespan;
            /**
             * The scale of the particle.
             * @default 1.0
             **/
            GLfloat scale;
            
            /**
             * The position of the particle, relative to its emitter
             **/
            vi::common::vector2 position;
            /**
             * The color of the particle.
             **/
            vi::graphic::color  color;
        };
        
        
        
        /**
         * @brief Capsulates boundary informations for a baseParticle
         *
         * A baseParticleEffect contains information used by baseParticles to initialize themself.
         **/
        class baseParticleEffect
        {
        public:
            baseParticleEffect();
            
            /**
             * The default lifespan
             **/
            GLfloat lifespan;
            GLfloat randomLifespan;
            
            /**
             * The start scale
             **/
            GLfloat scale;
            GLfloat randomScale;
            
            /**
             * The target scale. Particles will interpolate between the start and target scale during their lifetime
             **/
            GLfloat targetScale;
            GLfloat randomTargetScale;
            
            vi::common::vector2 randomPosition;
            
            /**
             * The start speed
             **/
            vi::common::vector2 speed;
            vi::common::vector2 randomSpeed;
            
            /**
             * The target speed.
             **/
            vi::common::vector2 targetSpeed;
            vi::common::vector2 randomTargetSpeed;
            
            /**
             * The start color
             **/
            vi::graphic::color color;
            vi::graphic::color randomColor;
            
            /**
             * The target color
             **/
            vi::graphic::color targetColor;
            vi::graphic::color randomTargetColor;
        };
        
        /**
         * @brief Particle with some basic logic
         *
         * A base particle uses a baseParticleEffect instance to initialize itself. Unlike a normal particle, a baseParticle has the ability to change itself
         * over its lifetime.
         **/
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
