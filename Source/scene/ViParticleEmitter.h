//
//  ViParticleEmitter.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <vector>
#import "ViBase.h"
#import "ViSceneNode.h"
#import "ViMaterial.h"
#import "ViParticle.h"

namespace vi
{
    namespace scene
    {
        /**
         * @brief Node for displaying particles
         *
         * While a particle only contains state informations about the particle and can't be added to the scene, a particle emitter controls and displays multiple particles.
         **/
        class particleEmitter : public sceneNode
        {
        public:
            /**
             * Constructor for a particle emitter
             * @param texture The texture that should be used for every particle.
             **/
            particleEmitter(vi::graphic::texture *texture);
            /**
             * Destructor
             **/
            virtual ~particleEmitter();
            
            /**
             * Sets a new texture
             * @remark The texture is applied the next frame for all particles, even particles emitted before the texture was changed.
             **/
            void setTexture(vi::graphic::texture *texture);
            
            /**
             * Adds the given particle to the emitter.
             **/
            virtual void emitParticle(vi::scene::particle *particle);
            
            /**
             * Tells the emitter to automatically emit copies of the given particle over and over again.
             * @param particle A template particle or NULL to disable auto emitting
             * @param particlesPerFrame The number of particles that should be emitted per frame
             * @param maxParticles The maximum number of particles the emitter should control at a single point in time.
             **/
            void autoEmitParticle(vi::scene::particle *particle, uint32_t particlesPerFrame, uint32_t maxParticles);
            /**
             * Updates the auto emitting informations
             **/
            void updateAutoEmitting(uint32_t particlesPerFrame, uint32_t maxParticles);
            
            /**
             * Prepares the particle emitter for drawing.
             **/
            virtual void visit(double timestep);
            
            /**
             * If true (default) newer particles are drawn over older particles, otherwise false.
             **/
            bool orderFrontToBack;
            
        private:
            vi::common::vector2 particleSize;
            vi::common::meshRGBA *particleMesh;
            
            std::vector<vi::scene::particle *> particles;
            
            bool autocreateParticle;
            
            vi::scene::particle *templateParticle;
            uint32_t particlesPerFrame;
            uint32_t maxParticles;
        };
    }
}
