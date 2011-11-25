//
//  ViParticleEmitter.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

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
            
            mesh = new vi::common::mesh(0, 0);
            
            particleMesh = new vi::common::mesh(4, 6);
            particleMesh->addVertex(0.0, 1.0, 0.0, 0.0);
            particleMesh->addVertex(1.0, 1.0, 1.0, 0.0);
            particleMesh->addVertex(1.0, 0.0, 1.0, 1.0);
            particleMesh->addVertex(0.0, 0.0, 0.0, 1.0);
            
            particleMesh->addIndex(0);
            particleMesh->addIndex(3);
            particleMesh->addIndex(1);
            particleMesh->addIndex(2);
            particleMesh->addIndex(1);
            particleMesh->addIndex(3);
            
            
            templateParticle = NULL;
            
            orderFrontToBack    = true;
            autocreateParticle  = false;
            particleSize = vi::common::vector2(texture->getWidth(), texture->getHeight());
        }
        
        particleEmitter::~particleEmitter()
        {
            delete material;
            delete mesh;
            delete particleMesh;
            
            if(templateParticle)
                delete templateParticle;
            
            
            
            std::vector<vi::scene::particle *>::iterator iterator;
            for(iterator=particles.begin(); iterator!=particles.end(); iterator++)
            {
                vi::scene::particle *particle = *iterator;
                delete particle;
            }
        }
        
        
        void particleEmitter::setTexture(vi::graphic::texture *texture)
        {
            material->textures[0] = texture;
        }
        
        
        void particleEmitter::visit(double timestep)
        {
            sceneNode::visit(timestep);
            
            for(int32_t i=(int32_t)particles.size()-1; i>=0; i--)
            {
                vi::scene::particle *particle = particles[i];
                particle->visit(timestep);
                
                if(particle->lifespan <= 0.0)
                {
                    delete particle;
                    particles.erase(particles.begin() + i);
                }
            }
            
            if(autocreateParticle && particles.size() < maxParticles)
            {
                uint32_t spawnParticles = MIN(maxParticles - (uint32_t)particles.size(), particlesPerFrame);
                for(uint32_t i=0; i<spawnParticles; i++)
                {
                    vi::scene::particle *particle = templateParticle->recreate();
                    particle->visit(0.0);
                    
                    particles.push_back(particle);
                }
            }
            
            
            // Generate the mesh...
            if(particles.size() > 0)
            {
                mesh->vertexCount = 0;
                mesh->indexCount = 0;
                
                if(orderFrontToBack)
                {
                    std::vector<vi::scene::particle *>::iterator iterator;
                    for(iterator=particles.begin(); iterator!=particles.end(); iterator++)
                    {
                        vi::scene::particle *particle = *iterator;
                        
                        particleMesh->updateColor(0, particle->color);
                        particleMesh->updateColor(1, particle->color);
                        particleMesh->updateColor(2, particle->color);
                        particleMesh->updateColor(3, particle->color);
                        
                        mesh->addMesh(particleMesh, particle->position, particleSize * particle->scale);
                    }
                }
                else
                {
                    std::vector<vi::scene::particle *>::reverse_iterator iterator;
                    for(iterator=particles.rbegin(); iterator!=particles.rend(); iterator++)
                    {
                        vi::scene::particle *particle = *iterator;
                        
                        particleMesh->updateColor(0, particle->color);
                        particleMesh->updateColor(1, particle->color);
                        particleMesh->updateColor(2, particle->color);
                        particleMesh->updateColor(3, particle->color);
                        
                        mesh->addMesh(particleMesh, particle->position, particleSize * particle->scale);
                    }
                }
            }
        }
        
        void particleEmitter::emitParticle(vi::scene::particle *particle)
        {
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
        
        void particleEmitter::updateAutoEmitting(uint32_t tparticlesPerFrame, uint32_t tmaxParticles)
        {
            particlesPerFrame = tparticlesPerFrame;
            maxParticles = tmaxParticles;
        }
    }
}
