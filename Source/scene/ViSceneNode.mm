//
//  ViSceneNode.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViSceneNode.h"
#import "ViQuadtree.h"
#import "ViScene.h"
#import "ViRenderer.h"
#import "ViVector3.h"

namespace vi
{
    namespace scene
    {
        sceneNode::sceneNode(vi::common::vector2 const& pos, vi::common::vector2 const& tsize, uint32_t tlayer)
        {
            position    = pos;
            size        = tsize;
            layer       = tlayer;
            rotation    = 0.0;
            
            flags = 0;

            material    = NULL;
            mesh        = NULL;
            noPass      = NULL;
            
            scene   = NULL;
            tree    = NULL;
            parent  = NULL;
            
            debugName = NULL;
            
#ifdef ViPhysicsChipmunk
            waitingForActivation = false;
            initializedInertia = false;
            bodyIsSleeping = false;
            
            body  = NULL;
            shape = NULL;
            
            friction = 0.0;
            elasticity = 0.0;
            surfaceVelocity = cpvzero;
            group = CP_NO_GROUP;
            
            angVelLimit = (cpFloat)INFINITY;
            velLimit = (cpFloat)INFINITY;
            
            mass = 1.0;
#endif
        }
        
        sceneNode::~sceneNode()
        {            
#ifdef ViPhysicsChipmunk
            disablePhysics();
#endif
            
            if(tree)
                tree->removeObject(this);
            
            if(debugName && deleteDebugName)
                delete debugName;
        }
        
        void sceneNode::visit(double timestep)
        {
#ifdef ViPhysicsChipmunk
            if(body)
            {
                cpVect pPos = body->p;
                cpFloat pRot = body->a;
                
                position = vi::common::vector2(pPos.x, pPos.y) - (size * 0.5);
                rotation = pRot;

                update();
            }
#endif
            
            matrix.makeIdentity();
            matrix.translate(vi::common::vector3(position.x, - position.y - size.y, 0.0));
            
            if(rotation > kViEpsilonFloat)
            {
                float halfWidth  = size.x * 0.5f;
                float halfHeight = size.y * 0.5f;
                
                vi::common::matrix4x4 rotationMatrix;
                rotationMatrix.makeTranslate(vi::common::vector3(halfWidth, halfHeight, 0.0f));
                rotationMatrix.rotate(rotation, vi::common::vector3(0.0f, 0.0f, 1.0f));
                rotationMatrix.translate(vi::common::vector3(-halfWidth, -halfHeight, 0.0f));
                
                matrix *= rotationMatrix;
            }
        }
        
        
        
        vi::common::vector2 sceneNode::getPosition()
        {
            return position;
        }
        
        void sceneNode::setPosition(vi::common::vector2 const& point)
        {
            if(position != point)
            {
                position = point;
                update();
                
#ifdef ViPhysicsChipmunk
                if(body)
                    cpBodySetPos(body, cpv(position.x, position.y));
#endif
            }
        }
        
        
        vi::common::vector2 sceneNode::getSize()
        {
            return size;
        }
        
        void sceneNode::setSize(vi::common::vector2 const& tsize)
        {
            if(size != tsize)
            {
                size = tsize;
                update();
                
#ifdef ViPhysicsChipmunk
                if(body)
                    enablePhysics(physicType); // Re-enable physics to update the size changes
#endif
            }
        }
        

        uint32_t sceneNode::getFlags()
        {
            return flags;
        }
        
        void sceneNode::setFlags(uint32_t tflags)
        {
            if(flags != tflags)
            {
                flags = tflags;                
                update();
            }
            
        }
        
        
        void sceneNode::update()
        {
            if((flags & sceneNodeFlagDynamic) && knownDynamic)
                return;
                
            if(tree)
            {
                knownDynamic = (flags & sceneNodeFlagDynamic);
                tree->updateObject(this);
            }
            else
                knownDynamic = false;
        }
        
        
        bool sceneNode::hasChilds()
        {
            return (childs.size() > 0);
        }
        
        std::vector<vi::scene::sceneNode *> *sceneNode::getChilds()
        {
            return &childs;
        }
        
        void sceneNode::addChild(vi::scene::sceneNode *child)
        {
            if(child->parent)
                child->parent->removeChild(child);
            
            childs.push_back(child);
            child->parent = this;
        }
        
        void sceneNode::removeChild(vi::scene::sceneNode *child)
        {
            if(child->parent != this)
                return;
            
            std::vector<vi::scene::sceneNode *>::iterator iterator;
            for(iterator=childs.begin(); iterator!=childs.end(); iterator++)
            {
                if(*iterator == child)
                {
                    child->parent = NULL;
                    childs.erase(iterator);
                    break;
                }
            }
        }
        
        
        void sceneNode::setDebugName(std::string *name, bool deleteAutomatically)
        {
            if(debugName && deleteDebugName)
                delete debugName;
            
            debugName = name;
            deleteDebugName = deleteAutomatically;
        }
        
        
#ifdef ViPhysicsChipmunk
        GLfloat sceneNode::suggestedInertia()
        {
            cpFloat sInertia = 0.0f;
            switch(physicType)
            {
                case sceneNodePhysicTypeBox:
                    sInertia = cpMomentForBox(mass, size.x, size.y);
                    break;
                    
                case sceneNodePhysicTypeCircle:
                {
                    cpFloat radius = MAX(size.x, size.y) * 0.5f;
                    sInertia = cpMomentForCircle(mass, radius, 0.0f, cpvzero);
                    break;
                }
            }
            
            return sInertia;
        }
        
        
        void sceneNode::enablePhysics(sceneNodePhysicType type)
        {
            if(shape)
                disablePhysics();
            
            isStatic = false;
            physicType = type;
            body = cpBodyNew(mass, initializedInertia ? inertia : suggestedInertia());
            
            switch(physicType)
            {
                case sceneNodePhysicTypeBox:
                    shape = cpBoxShapeNew(body, size.x, size.y);
                    break;
                    
                case sceneNodePhysicTypeCircle:
                {
                    cpFloat radius = MAX(size.x, size.y) * 0.5f;
                    shape = cpCircleShapeNew(body, radius, cpvzero);
                    break;
                }
            }
            
            
            cpBodySetPos(body, cpv(position.x + (size.x * 0.5), position.y + (size.y * 0.5)));
            cpBodySetAngle(body, rotation);
            cpBodySetAngVelLimit(body, angVelLimit);
            cpBodySetVelLimit(body, velLimit);
            
            cpShapeSetFriction(shape, friction);
            cpShapeSetElasticity(shape, elasticity);
            cpShapeSetSurfaceVelocity(shape, surfaceVelocity);
            cpShapeSetGroup(shape, group);
            
            
            setFlags(flags | vi::scene::sceneNodeFlagDynamic);
            
            if(scene)
            {
                cpSpaceAddBody(scene->space, body);
                cpSpaceAddShape(scene->space, shape);
                waitingForActivation = false;
                
                if(bodyIsSleeping)
                    cpBodySleep(body);
            }
            else
                waitingForActivation = true;
        }
        
        void sceneNode::makeStaticObject(vi::common::vector2 const& end)
        {
            if(shape)
                disablePhysics();
            
            isStatic = true;
            staticEnd = end;
            
            if(scene)
            {
                shape = cpSegmentShapeNew(scene->space->staticBody, cpv(position.x, position.y), cpv(end.x, end.y), 0);
                waitingForActivation = false;
                
                cpShapeSetFriction(shape, friction);
                cpShapeSetElasticity(shape, elasticity);
                cpShapeSetSurfaceVelocity(shape, surfaceVelocity);
                cpShapeSetGroup(shape, group);
                
                cpSpaceAddShape(scene->space, shape);
            }
            else
                waitingForActivation = true;
        }
        
        void sceneNode::disablePhysics()
        {
            if(!shape)
                return;
            
            waitingForActivation = false;
            
            if(body)
            {
                if(scene)
                    cpSpaceRemoveBody(scene->space, body);
                
                cpBodyFree(body);
                body = NULL;
            }
            
            if(shape)
            {
                if(scene)
                    cpSpaceRemoveShape(scene->space, shape);
                
                cpShapeFree(shape);
                shape = NULL;
            }
        }
        
        
        void sceneNode::resetForce()
        {
            if(body)
                cpBodyResetForces(body);
        }
        
        void sceneNode::applyForce(vi::common::vector2 const& force, vi::common::vector2 const& offset)
        {
            if(body)
                cpBodyApplyForce(body, cpv(force.x, force.y), cpv(offset.x, offset.y));
            
            bodyIsSleeping = false;
        }
        
        void sceneNode::applyImpulse(vi::common::vector2 const& impulse, vi::common::vector2 const& offset)
        {
            if(body)
                cpBodyApplyImpulse(body, cpv(impulse.x, impulse.y), cpv(offset.x, offset.y));
            
            bodyIsSleeping = false;
        }
        
        
        void sceneNode::restrictAngularVelocity(GLfloat aVel)
        {
            if(body)
                cpBodySetAngVelLimit(body, aVel);
            
            angVelLimit = aVel;
        }
        
        void sceneNode::restrictVelocity(GLfloat velocity)
        {
            if(body)
                cpBodySetVelLimit(body, velocity);
            
            velLimit = velocity;
        }
        
        
        void sceneNode::sleep()
        {
            if(body && scene)
                cpBodySleep(body);
            
            bodyIsSleeping = true;
        }
        
        void sceneNode::activate()
        {
            if(body && scene)
                cpBodyActivate(body);
            
            bodyIsSleeping = false;
        }
        
        bool sceneNode::isSleeping()
        {
            return bodyIsSleeping;
        }
        
        
        void sceneNode::setMass(GLfloat tmass)
        {
            mass = tmass;
            
            if(body)
                cpBodySetMass(body, mass);
        }
        
        void sceneNode::setInertia(GLfloat tinertia)
        {
            inertia = tinertia;
            initializedInertia = true;
            
            if(body)
                cpBodySetMoment(body, inertia);
        }
        
        void sceneNode::setElasticity(GLfloat telasticity)
        {
            elasticity = telasticity;
            
            if(shape)
                cpShapeSetElasticity(shape, elasticity);
        }
        
        void sceneNode::setFriction(GLfloat tfriction)
        {
            friction = tfriction;
            
            if(shape)
                cpShapeSetFriction(shape, friction);
        }
        
        void sceneNode::setSurfaceVelocity(vi::common::vector2 const& tvelocity)
        {
            surfaceVelocity = cpv(tvelocity.x, tvelocity.y);
            
            if(shape)
                cpShapeSetSurfaceVelocity(shape, surfaceVelocity);
        }
        
        void sceneNode::setGroup(uint32_t tgroup)
        {
            group = tgroup;
            
            if(shape)
                cpShapeSetGroup(shape, (cpGroup)group);
        }
        
        void sceneNode::setRotation(GLfloat trotation)
        {
            rotation = trotation;
            
            if(body)
                cpBodySetAngle(body, rotation);
        }
#endif
    }
}
