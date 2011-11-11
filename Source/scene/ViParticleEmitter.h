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
        class particleEmitter : public sceneNode
        {
        public:
            particleEmitter(vi::graphic::texture *texture);
            ~particleEmitter();
            
            
            void emitParticle(vi::scene::particle *particle);
            void autoEmitParticle(vi::scene::particle *particle, uint32_t particlesPerFrame, uint32_t maxParticles);
            
            virtual void visit(double timestep);
            
            bool orderFrontToBack;
            
        private:
            bool particlePredicate(vi::scene::particle *particleA, vi::scene::particle *particleB);
            
            vi::common::vector2 particleSize;
            
            std::vector<vi::scene::particle *> particles;
            
            double time;
            bool autocreateParticle;
            vi::scene::particle *templateParticle;
            uint32_t particlesPerFrame;
            uint32_t maxParticles;
        };
    }
}
