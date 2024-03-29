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
#import "ViAnimationServer.h"

namespace vi
{
    namespace scene
    {
        sceneNode::sceneNode(vi::common::vector2 const& pos, vi::common::vector2 const& tsize, uint32_t tlayer)
        {
            position    = temporaryPosition = pos;
            size        = temporarySize = tsize;
            scale       = temporaryScale = vi::common::vector2(1.0, 1.0);
            layer       = tlayer;
            rotation    = temporaryRotation = 0.0;
            
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
                
                position = vi::common::vector2(roundf(pPos.x), roundf(pPos.y)) - size * 0.5;
                rotation = pRot;
                
                temporaryPosition = position;
                temporaryRotation = rotation;

                update();
            }
#endif
            
            matrix.makeIdentity();
            matrix.translate(vi::common::vector3(position.x, - position.y - size.y, 0.0));
            
            if(rotation > kViEpsilonFloat || rotation < -kViEpsilonFloat)
            {
                float halfWidth  = size.x * 0.5f;
                float halfHeight = size.y * 0.5f;
                
                vi::common::matrix4x4 rotationMatrix;
                rotationMatrix.makeTranslate(vi::common::vector3(halfWidth, halfHeight, 0.0f));
                rotationMatrix.rotate(rotation, vi::common::vector3(0.0f, 0.0f, 1.0f));
                rotationMatrix.translate(vi::common::vector3(-halfWidth, -halfHeight, 0.0f));
                
                matrix *= rotationMatrix;
            }
            
            matrix.scale(vi::common::vector3(scale.x, scale.y, 1.0));
        }
        
        
        
        vi::common::vector2 sceneNode::getPosition()
        {
            return position;
        }
        
        void sceneNode::setPosition(vi::common::vector2 const& point)
        {
            if(temporaryPosition != point)
            {
                if(scene)
                {
                    vi::animation::animationStack *stack = scene->getAnimationServer()->topStack();
                    if(stack)
                    {
                        vi::animation::basicAnimation<vi::common::vector2> *animation = new vi::animation::basicAnimation<vi::common::vector2>();
                        animation->setValues(temporaryPosition, point);
                        animation->setApplyCallback(std::tr1::bind(&vi::scene::sceneNode::forceSetPosition, this, std::tr1::placeholders::_1));
                        animation->setApplyProperty(&temporaryPosition);
                        
                        stack->addAnimation(animation);
                        temporaryPosition = point;
                        return;
                    }
                }
                
                position = point;
                temporaryPosition = point;
                update();
                
#ifdef ViPhysicsChipmunk
                if(body)
                    cpBodySetPos(body, cpv(position.x + (size.x * 0.5), position.y + (size.y * 0.5)));
#endif
            }
        }
        
        vi::common::vector2 sceneNode::getSize()
        {
            return size;
        }
        
        void sceneNode::setSize(vi::common::vector2 const& tsize)
        {
            if(temporarySize != tsize)
            {
                if(scene)
                {
                    vi::animation::animationStack *stack = scene->getAnimationServer()->topStack();
                    if(stack)
                    {
                        vi::animation::basicAnimation<vi::common::vector2> *animation = new vi::animation::basicAnimation<vi::common::vector2>();
                        animation->setValues(temporarySize, tsize);
                        animation->setApplyCallback(std::tr1::bind(&vi::scene::sceneNode::forceSetSize, this, std::tr1::placeholders::_1));
                        animation->setApplyProperty(&temporarySize);
                        
                        stack->addAnimation(animation);
                        temporarySize = tsize;
                        return;
                    }
                }
                
                size = tsize;
                temporarySize = tsize;
                
                update();
                
#ifdef ViPhysicsChipmunk
                reenablePhysics();
#endif
            }
        }
        
        void sceneNode::setScale(vi::common::vector2 const& tscale)
        {
            if(temporaryScale != tscale)
            {
                if(scene)
                {
                    vi::animation::animationStack *stack = scene->getAnimationServer()->topStack();
                    if(stack)
                    {
                        vi::animation::basicAnimation<vi::common::vector2> *animation = new vi::animation::basicAnimation<vi::common::vector2>();
                        animation->setValues(temporaryScale, tscale);
                        animation->setApplyProperty(&scale);
                        
                        stack->addAnimation(animation);
                        temporaryScale = tscale;
                        return;
                    }
                }
                
                scale = tscale;
                temporaryScale = tscale;
            }
        }
        
        vi::common::vector2 sceneNode::getScale()
        {
            return scale;
        }
        
        
        void sceneNode::setRotation(GLfloat trotation)
        {
            if(scene)
            {
                vi::animation::animationStack *stack = scene->getAnimationServer()->topStack();
                if(stack)
                {
                    vi::animation::basicAnimation<GLfloat> *animation = new vi::animation::basicAnimation<GLfloat>();
                    animation->setValues(temporaryRotation, trotation);
                    animation->setApplyCallback(std::tr1::bind(&vi::scene::sceneNode::forceSetRotation, this, std::tr1::placeholders::_1));
                    animation->setApplyProperty(&temporaryRotation);
                    
                    stack->addAnimation(animation);
                    temporaryRotation = trotation;
                    return;
                }
            }
            
            
            rotation = trotation;
            temporaryRotation = trotation;
            
#ifdef ViPhysicsChipmunk
            if(body)
                cpBodySetAngle(body, rotation);
#endif
        }
        
        void sceneNode::setVelocity(vi::common::vector2 const& velocity)
        {
            if(body)
                cpBodySetVel(body, cpv(velocity.x, velocity.y));
        }
        
        void sceneNode::setAngularVelocity(GLfloat avelocity)
        {
            if(body)
                cpBodySetAngVel(body, avelocity);
        }
        
        
        
        void sceneNode::forceSetPosition(vi::common::vector2 const& point)
        {
            position = point;
            update();
            
#ifdef ViPhysicsChipmunk
            if(body)
                cpBodySetPos(body, cpv(position.x + (size.x * 0.5), position.y + (size.y * 0.5)));
#endif
        }
        
        void sceneNode::forceSetSize(vi::common::vector2 const& tsize)
        {
            size = tsize;
            update();
            
#ifdef ViPhysicsChipmunk
            reenablePhysics();
#endif
        }
        
        void sceneNode::forceSetRotation(GLfloat trotation)
        {
            rotation = trotation;
            
#ifdef ViPhysicsChipmunk
            if(body)
                cpBodySetAngle(body, rotation);
#endif
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
        
        
        void sceneNode::setScene(vi::scene::scene *tscene)
        {
            scene = tscene;
            std::vector<vi::scene::sceneNode *>::iterator iterator;
            
            for(iterator=childs.begin(); iterator!=childs.end(); iterator++)
            {
                vi::scene::sceneNode *child = *iterator;
                child->setScene(scene);
            }
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
            child->setScene(scene);
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
        
        
        void sceneNode::reenablePhysics()
        {
            if(body)
            {
                // Velocity and angular velocity aren't stored, so we have to manually save them and reapply them when the new physic body is ready!
                vi::common::vector2 velocity = getVelocity();
                GLfloat angVelocity = getAngularVelocity();
                
                enablePhysics(physicType);
                
                setVelocity(velocity);
                setAngularVelocity(angVelocity);
            }
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
            
            cpBodySetUserData(body, this);
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
        
        void sceneNode::makeStaticObject(vi::common::vector2 const& start, vi::common::vector2 const& end, GLfloat height)
        {
            if(shape)
                disablePhysics();
            
            isStatic = true;
            
            staticEnd = end;
            staticStart = start;
            staticRadius = height;
            
            if(scene)
            {
                shape = cpSegmentShapeNew(scene->space->staticBody, cpv(start.x, start.y), cpv(end.x, end.y), height);
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
        
        
        bool sceneNode::isPhysicalBody()
        {
            return (shape != NULL);
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
        
        
        GLfloat sceneNode::getMass()
        {
            return mass;
        }
        
        GLfloat sceneNode::getInertia()
        {
            if(initializedInertia)
                return inertia;
            
            return suggestedInertia();
        }
        
        GLfloat sceneNode::getElasticity()
        {
            return elasticity;
        }
        
        GLfloat sceneNode::getFriction()
        {
            return friction;
        }
        
        vi::common::vector2 sceneNode::getSurfaceVelocitiy()
        {
            return  vi::common::vector2(surfaceVelocity.x, surfaceVelocity.y);
        }
        
        uint32_t sceneNode::getGroup()
        {
            return group;
        }
        
        
        GLfloat sceneNode::getAngularVelocityLimit()
        {
            return angVelLimit;
        }
        
        GLfloat sceneNode::getVelocityLimit()
        {
            return velLimit;
        }
        
        GLfloat sceneNode::getAngularVelocity()
        {
            return body ? cpBodyGetAngVel(body) : 0.0;
        }
        
        vi::common::vector2 sceneNode::getVelocity()
        {
            if(!body)
                return vi::common::vector2();
            
            cpVect velocity = cpBodyGetVel(body);
            return vi::common::vector2(velocity.x, velocity.y);
        }
        
        
        cpBody *sceneNode::getCPBody()
        {
            return body;
        }
        
        cpShape *sceneNode::getCPShape()
        {
            return shape;
        }
#endif
    }
}
