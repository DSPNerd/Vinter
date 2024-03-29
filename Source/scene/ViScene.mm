//
//  ViScene.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViScene.h"
#import "ViQuadtree.h"
#import "ViRect.h"
#import "ViLine.h"
#import "ViCamera.h"
#import "ViSceneNode.h"
#import "ViRenderer.h"
#import "ViEvent.h"
#import "ViKernel.h"

namespace vi
{
    namespace scene
    {
#ifdef ViPhysicsChipmunk
        int collisionBeginCallback(cpArbiter *arb, cpSpace *space, void *data);
        int collisionPreSolveCallback(cpArbiter *arb, cpSpace *space, void *data);
        void collisionPostSolveCallback(cpArbiter *arb, cpSpace *space, void *data);
        void collisionSeparateCallback(cpArbiter *arb, cpSpace *space, void *data);
        
        
        int collisionBeginCallback(cpArbiter *arb, cpSpace *space, void *data)
        {
            vi::event::physicEvent event = vi::event::physicEvent(vi::event::physicEventTypeCollisionBegan, (vi::scene::scene *)data, arb);
            event.raise();
            
            return event.returnValue;
        }
        
        int collisionPreSolveCallback(cpArbiter *arb, cpSpace *space, void *data)
        {
            vi::event::physicEvent event = vi::event::physicEvent(vi::event::physicEventTypeCollisionWillSolve, (vi::scene::scene *)data, arb);
            event.raise();
            
            return event.returnValue;
        }
        
        void collisionPostSolveCallback(cpArbiter *arb, cpSpace *space, void *data)
        {
            vi::event::physicEvent event = vi::event::physicEvent(vi::event::physicEventTypeCollisionDidSolve, (vi::scene::scene *)data, arb);
            event.raise();
        }
        
        void collisionSeparateCallback(cpArbiter *arb, cpSpace *space, void *data)
        {
            vi::event::physicEvent event = vi::event::physicEvent(vi::event::physicEventTypeCollisionSeperate, (vi::scene::scene *)data, arb);
            event.raise();
        }
#endif
        
        
        
        scene::scene(vi::scene::camera *camera, float minX, float minY, float maxX, float maxY, uint32_t subdivisions)
        {
            assert(maxX > minX);
            assert(maxY > minY);
            
            vi::common::rect rect = vi::common::rect(minX, minY, maxX-minX, maxY-minY);
            quadtree = new vi::common::quadtree(rect, subdivisions);
            cameras  = new std::vector<vi::scene::camera *>();
            animationServer = new vi::animation::animationServer();
            
            context = NULL;
            addCamera(camera);
            
#ifdef ViPhysicsChipmunk
            totalPhysicsTime = 0.0;
            physicsPaused = false;
            
            space = cpSpaceNew();
            setGravity(vi::common::vector2(0.0, 100.0));
            cpSpaceSetDefaultCollisionHandler(space, collisionBeginCallback, collisionPreSolveCallback, collisionPostSolveCallback, collisionSeparateCallback, this);
#endif
        }
        
        scene::~scene()
        {
#ifdef ViPhysicsChipmunk
            cpSpaceFree(space);
#endif
            
            if(context)
                alcDestroyContext(context);
            
            delete animationServer;
            delete cameras;
            delete quadtree;
        }
        
        
        vi::animation::animationServer *scene::getAnimationServer()
        {
            return animationServer;
        }
        
        void scene::draw(vi::graphic::renderer *renderer, double timestep)
        {
            vi::event::renderEvent event = vi::event::renderEvent(vi::event::renderEventTypeWillDrawScene, this);
            event.timestep = timestep;
            event.raise();
            
            animationServer->run(timestep);
            
#ifdef ViPhysicsChipmunk
            if(!physicsPaused)
            {
                static double physicsstep = 1.0 / 60.0;
                
                totalPhysicsTime += timestep;
                while(totalPhysicsTime >= physicsstep)
                {
                    totalPhysicsTime -= physicsstep;
                    cpSpaceStep(space, physicsstep);
                }
            }
#endif
            
            std::vector<vi::scene::camera *>::iterator iterator;
            for(iterator=cameras->begin(); iterator!=cameras->end(); iterator++)
            {
                vi::scene::camera *camera = *iterator;
                renderer->renderSceneWithCamera(this, camera, timestep);
            }
            
            event = vi::event::renderEvent(vi::event::renderEventTypeDidDrawScene, this);
            event.timestep = timestep;
            event.raise();
        }
        
        
#ifdef ViPhysicsChipmunk
        void scene::pausePhysics()
        {
            physicsPaused = true;
        }
        
        void scene::unpausePhysics()
        {
            physicsPaused = false;
        }
        
        
        void scene::setGravity(vi::common::vector2 const& gravity)
        {
            cpSpaceSetGravity(space, cpv(gravity.x, gravity.y));
        }
        
        void scene::setDamping(GLfloat damping)
        {
            cpSpaceSetDamping(space, damping);
        }
        
        void scene::setCollisionSlop(GLfloat slop)
        {
            cpSpaceSetCollisionSlop(space, slop);
        }
        
        void scene::enableSpatialHash(GLfloat dimension, uint32_t count)
        {
            cpSpaceUseSpatialHash(space, dimension, count);
        }
        
        
        vi::common::vector2 scene::getGravity()
        {
            cpVect gravitiy = cpSpaceGetGravity(space);
            return vi::common::vector2(gravitiy.x, gravitiy.y);
        }
        
        GLfloat scene::getDamping()
        {
            return cpSpaceGetDamping(space);
        }
        
        GLfloat scene::getCollisionSlop()
        {
            return cpSpaceGetCollisionSlop(space);
        }
#endif
        
        
        void scene::addCamera(vi::scene::camera *camera)
        {
            if(!camera)
                return;
            
            cameras->push_back(camera);
        }
        
        void scene::removeCamera(vi::scene::camera *camera)
        {
            std::vector<vi::scene::camera *>::iterator iterator;
            for(iterator=cameras->begin(); iterator!=cameras->end(); iterator++)
            {
                vi::scene::camera *cam = *iterator;
                if(cam == camera)
                {
                    cameras->erase(iterator);
                    break;
                }
            }
        }
        
        std::vector<vi::scene::camera *> scene::getCameras()
        {
            std::vector<vi::scene::camera *> camerasCopy = std::vector<vi::scene::camera *>(*cameras);
            return camerasCopy;
        }
        
        
        void scene::addUINode(vi::scene::sceneNode *node)
        {
            uiNodes.push_back(node);
            node->setScene(this);
        }
        
        void scene::removeUINode(vi::scene::sceneNode *node)
        {
            node->scene = NULL;
            
            std::vector<vi::scene::sceneNode *>::iterator iterator;
            for(iterator=uiNodes.begin(); iterator!=uiNodes.end(); iterator++)
            {
                vi::scene::sceneNode *tnode = *iterator; 
                if(node == tnode)
                {
                    uiNodes.erase(iterator);
                    break;
                }
            }
        }     
        
        void scene::deleteAllUINodes()
        {
            std::vector<vi::scene::sceneNode *>::iterator iterator;
            for(iterator=uiNodes.begin(); iterator!=uiNodes.end(); iterator++)
            {
                vi::scene::sceneNode *node = *iterator; 
                delete node;
            }
            
            uiNodes.clear();
        }
        
        
        
        void scene::addNode(vi::scene::sceneNode *node)
        {
            quadtree->insertObject(node);
            node->setScene(this);
            
#ifdef ViPhysicsChipmunk
            if(node->waitingForActivation)
            {
                if(!node->isStatic)
                {
                    cpSpaceAddShape(space, node->shape);
                    cpSpaceAddBody(space, node->body);
                    
                    if(node->isSleeping())
                        cpBodySleep(node->body);
                }
                else
                {
                    node->makeStaticObject(node->staticStart, node->staticEnd, node->staticRadius);
                }
                
                node->waitingForActivation = false;
            }
#endif
        }
        
        void scene::removeNode(vi::scene::sceneNode *node)
        {
#ifdef ViPhysicsChipmunk
            if(node->body)
                cpSpaceRemoveBody(space, node->body);
            
            if(node->shape)
                cpSpaceRemoveShape(space, node->shape);
#endif
            
            node->scene = NULL;
            quadtree->removeObject(node);
        }
        
        void scene::deleteAllNodes()
        {
            quadtree->deleteAllObjects();
        }
        
        
        
        std::vector<vi::scene::sceneNode *> *scene::nodesInRect(vi::common::rect const& rect)
        {
            nodes = std::vector<vi::scene::sceneNode *>();
            
            quadtree->objectsInRect(rect, &nodes);            
            return &nodes;
        }
        
        std::vector<vi::scene::sceneNode *> *scene::UINodes()
        {
            return &uiNodes;
        }
        
        
        void scene::activate(ALCdevice *device)
        {
            if(context)
            {
                ALCdevice *contextDevice = alcGetContextsDevice(context);
                if(contextDevice != device)
                {
                    alcDestroyContext(context);
                    context = NULL;
                }
            }
            
            if(!context)
                context = alcCreateContext(device, NULL);
            
            alcMakeContextCurrent(context);
        }
        
        void scene::deactivate()
        {
            ALCcontext *current = alcGetCurrentContext();
            if(current == context)
            {
                alcMakeContextCurrent(NULL);
            }
        }
        
        
        vi::scene::sceneNode *scene::trace(vi::common::vector2 const& from, vi::common::vector2 const& to, uint32_t layer, hitInfo *info)
        {
            GLfloat x1 = MIN(from.x, to.x) - 1.0f;
            GLfloat y1 = MIN(from.y, to.y) - 1.0f;
            GLfloat x2 = MAX(from.x, to.x) + 1.0f;
            GLfloat y2 = MAX(from.y, to.y) + 1.0f;
            
            vi::common::rect rect = vi::common::rect(x1, y1, x2 - x1, y2 - y1);
            vi::common::line line = vi::common::line(from, to);
            
            std::vector<vi::scene::sceneNode *> objects;
            std::vector<vi::scene::sceneNode *>::iterator iterator;
            
            vi::common::vector2 hitVec, hitVec2;
            vi::scene::sceneNode *hitNode = NULL;
            GLfloat hitDistance;
            
            quadtree->objectsInRect(rect, &objects);
            for(iterator=objects.begin(); iterator!=objects.end(); iterator++)
            {
                vi::scene::sceneNode *node = *iterator;
                if(layer == 0 || node->layer == layer)
                {
                    bool intersects = line.intersects(vi::common::rect(node->position, node->size), &hitVec2);
                    if(intersects)
                    {
                        if(hitNode)
                        {
                            if(hitVec2.dist(from) < hitDistance)
                            {
                                hitNode = node;
                                hitVec = hitVec2;
                                hitDistance = hitVec.dist(from);
                            }
                        }
                        else
                        {
                            hitNode = node;
                            hitVec = hitVec2;
                            hitDistance = hitVec.dist(from);
                        }
                    }
                }
            }
            
            
            if(info)
            {
                info->node = hitNode;
                info->position = hitVec;
                info->distance = hitDistance;
            }
            
            return hitNode;
        }
        
        vi::scene::sceneNode *scene::trace(vi::common::rect const& rect, uint32_t layer, hitInfo *info)
        {
            std::vector<vi::scene::sceneNode *> objects;
            std::vector<vi::scene::sceneNode *>::iterator iterator;
            
            vi::scene::sceneNode *hitNode = NULL;
            vi::common::vector2 hitVec;
            GLfloat hitDistance = 0.0;
            
            quadtree->objectsInRect(rect, &objects);
            for(iterator=objects.begin(); iterator!=objects.end(); iterator++)
            {
                vi::scene::sceneNode *node = *iterator;
                if(layer == 0 || node->layer == layer)
                {
                    bool intersects = vi::common::rect(node->position, node->size).intersectsRect(rect);
                    
                    if(intersects)
                    {
                        if(hitNode)
                        {
                            if(node->position.dist(rect.origin) < hitDistance)
                            {
                                hitNode = node;
                                hitVec = node->position;
                                hitDistance = node->position.dist(rect.origin);
                            }
                        }
                        else
                        {
                            hitNode = node;
                            hitVec = node->position;
                            hitDistance = node->position.dist(rect.origin);
                        }
                    }
                }
            }
            
            
            if(info)
            {
                info->node = hitNode;
                info->position = hitVec;
                info->distance = hitDistance;
            }
            
            return hitNode;
        }
    }
}

