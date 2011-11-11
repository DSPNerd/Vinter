//
//  ViParticleEmitter.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <tr1/functional>
#include <algorithm>

#import "ViContext.h"
#import "ViParticleEmitter.h"

namespace vi
{
    namespace scene
    {   
        particleEmitter::particleEmitter(vi::graphic::texture *texture)
        {
            vi::common::context *context = vi::common::context::getActiveContext();
            assert(context);
            
            material = new vi::graphic::material(texture, context->getShader(vi::graphic::defaultShaderParticle));
            material->blending = true;
            material->blendSource = GL_ONE;
            material->blendDestination = GL_ONE_MINUS_SRC_ALPHA;
            
            mesh = new vi::common::meshRGBA(0, 0);
            
            templateParticle = NULL;
            time = 0.0;
            
            orderFrontToBack    = true;
            autocreateParticle  = false;
            particleSize = vi::common::vector2(texture->getWidth(), texture->getHeight());
        }
        
        particleEmitter::~particleEmitter()
        {
            delete material;
            delete mesh;
            
            std::vector<vi::scene::particle *>::iterator iterator;
            for(iterator=particles.begin(); iterator!=particles.end(); iterator++)
            {
                vi::scene::particle *particle = *iterator;
                delete particle;
            }
            
            if(templateParticle)
                delete templateParticle;
        }
        
        
        
        void particleEmitter::visit(double timestep)
        {
            time += timestep;
            sceneNode::visit(timestep);
            
            std::vector<vi::scene::particle *> livingParticles;
            std::vector<vi::scene::particle *>::iterator iterator;
            for(iterator=particles.begin(); iterator!=particles.end(); iterator++)
            {
                vi::scene::particle *particle = *iterator;
                particle->visit(timestep);
                
                if(particle->lifespan <= 0.0)
                {
                    delete particle;
                    continue;
                }
                
                livingParticles.push_back(particle);
            }
            
            
            particles = livingParticles;
            
            if(autocreateParticle && particles.size() < maxParticles)
            {
                uint32_t spawnParticles = MIN(maxParticles - (uint32_t)particles.size(), particlesPerFrame);
                for(uint32_t i=0; i<spawnParticles; i++)
                {
                    vi::scene::particle *particle = templateParticle->recreate();
                    particle->time = time;
                    particle->visit(0.0);
                    
                    particles.push_back(particle);
                }
            }
            
            if(particles.size() > 0)
            {
                std::sort(particles.begin(), particles.end(), std::tr1::bind(&particleEmitter::particlePredicate, this, std::tr1::placeholders::_1, std::tr1::placeholders::_2));
                
                mesh->vertexCount = 0;
                mesh->indexCount = 0;
                
                std::vector<vi::scene::particle *>::iterator iterator;
                for(iterator=particles.begin(); iterator!=particles.end(); iterator++)
                {
                    vi::scene::particle *particle = *iterator;
                    mesh->addMesh(particle->mesh, particle->position, particleSize * particle->scale);
                }
            }
        }
        
        void particleEmitter::emitParticle(vi::scene::particle *particle)
        {
            particle->time = time;
            particles.push_back(particle);
        }
        
        void particleEmitter::autoEmitParticle(vi::scene::particle *particle, uint32_t tparticlesPerFrame, uint32_t tmaxParticles)
        {
            if(templateParticle)
                delete templateParticle;
            
            autocreateParticle = (particle != NULL);
            templateParticle = particle;
            
            particlesPerFrame = tparticlesPerFrame;
            maxParticles = tmaxParticles;
        }
        
        
        bool particleEmitter::particlePredicate(particle *particleA, particle *particleB)
        {
            return (orderFrontToBack) ? particleA->time < particleB->time : particleA->time > particleB->time;
        }
    }
}
