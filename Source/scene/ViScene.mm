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
#import "ViCamera.h"
#import "ViSceneNode.h"
#import "ViRenderer.h"

namespace vi
{
    namespace scene
    {
        scene::scene(vi::scene::camera *camera, float minX, float minY, float maxX, float maxY, uint32_t subdivisions)
        {
            assert(maxX > minX);
            assert(maxY > minY);
            
            vi::common::rect rect = vi::common::rect(minX, minY, maxX-minX, maxY-minY);
            quadtree = new vi::common::quadtree(rect, subdivisions);
            cameras  = new std::vector<vi::scene::camera *>();
            
            addCamera(camera);
            
#ifdef ViPhysicsChipmunk
            totalPhysicsTime = 0.0;
            
            space = cpSpaceNew();
            setGravity(vi::common::vector2(0.0, 100.0));
#endif
        }
        
        scene::~scene()
        {
#ifdef ViPhysicsChipmunk
            cpSpaceFree(space);
#endif
            
            delete cameras;
            delete quadtree;
        }
        
        void scene::draw(vi::graphic::renderer *renderer, double timestep)
        {
#ifdef ViPhysicsChipmunk
            static double physicsstep = 1.0 / 60.0;
            
            totalPhysicsTime += timestep;
            while(totalPhysicsTime >= physicsstep)
            {
                totalPhysicsTime -= physicsstep;
                cpSpaceStep(space, physicsstep);
            }
#endif
            
            std::vector<vi::scene::camera *>::iterator iterator;
            for(iterator=cameras->begin(); iterator!=cameras->end(); iterator++)
            {
                vi::scene::camera *camera = *iterator;
                renderer->renderSceneWithCamera(this, camera, timestep);
            }
        }
        
        
#ifdef ViPhysicsChipmunk
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
        
        
        
        void scene::addNode(vi::scene::sceneNode *node)
        {
            quadtree->insertObject(node);
            node->scene = this;
            
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
                    node->makeStaticObject(node->staticEnd);
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
    }
}

