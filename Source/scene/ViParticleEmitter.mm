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
            
            mesh = new vi::common::meshRGBA(0, 0);
            
            particleMesh = new vi::common::meshRGBA(4, 6);
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
                
                vi::common::vertexRGBA *vertices = particleMesh->getVertices();                
                
                if(orderFrontToBack)
                {
                    std::vector<vi::scene::particle *>::iterator iterator;
                    for(iterator=particles.begin(); iterator!=particles.end(); iterator++)
                    {
                        vi::scene::particle *particle = *iterator;
                        
                        vertices[0].r = particle->color.r;
                        vertices[0].g = particle->color.g;
                        vertices[0].b = particle->color.b;
                        vertices[0].a = particle->color.a;
                        
                        vertices[1].r = particle->color.r;
                        vertices[1].g = particle->color.g;
                        vertices[1].b = particle->color.b;
                        vertices[1].a = particle->color.a;
                        
                        vertices[2].r = particle->color.r;
                        vertices[2].g = particle->color.g;
                        vertices[2].b = particle->color.b;
                        vertices[2].a = particle->color.a;
                        
                        vertices[3].r = particle->color.r;
                        vertices[3].g = particle->color.g;
                        vertices[3].b = particle->color.b;
                        vertices[3].a = particle->color.a;
                        
                        mesh->addMesh(particleMesh, particle->position, particleSize * particle->scale);
                    }
                }
                else
                {
                    std::vector<vi::scene::particle *>::reverse_iterator iterator;
                    for(iterator=particles.rbegin(); iterator!=particles.rend(); iterator++)
                    {
                        vi::scene::particle *particle = *iterator;
                        
                        vertices[0].r = particle->color.r;
                        vertices[0].g = particle->color.g;
                        vertices[0].b = particle->color.b;
                        vertices[0].a = particle->color.a;
                        
                        vertices[1].r = particle->color.r;
                        vertices[1].g = particle->color.g;
                        vertices[1].b = particle->color.b;
                        vertices[1].a = particle->color.a;
                        
                        vertices[2].r = particle->color.r;
                        vertices[2].g = particle->color.g;
                        vertices[2].b = particle->color.b;
                        vertices[2].a = particle->color.a;
                        
                        vertices[3].r = particle->color.r;
                        vertices[3].g = particle->color.g;
                        vertices[3].b = particle->color.b;
                        vertices[3].a = particle->color.a;
                        
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
