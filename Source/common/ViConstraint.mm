//
//  ViConstraint.mm
//  Physics
//
//  Created by Sidney Just on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViConstraint.h"

#ifdef ViPhysicsChipmunk

namespace vi
{
    namespace common
    {
        constraint::constraint()
        {
            breakable = false;
        }
        
        constraint::~constraint()
        {
            cpConstraintFree(cconstraint);
        }
        
        
        
        vi::scene::sceneNode *constraint::getNodeA()
        {
            cpBody *body = cpConstraintGetA(cconstraint);
            return (vi::scene::sceneNode *)cpBodyGetUserData(body);
        }
        
        vi::scene::sceneNode *constraint::getNodeB()
        {
            cpBody *body = cpConstraintGetB(cconstraint);
            return (vi::scene::sceneNode *)cpBodyGetUserData(body);
        }
        
        
        void constraint::setMaxForce(GLfloat maxForce)
        {
            cpConstraintSetMaxForce(cconstraint, maxForce);
        }
        
        void constraint::setErrorBias(GLfloat bias)
        {
            cpConstraintSetErrorBias(cconstraint, bias);
        }
        
        
        GLfloat constraint::getMaxForce()
        {
            return cpConstraintGetMaxForce(cconstraint);
        }
        
        GLfloat constraint::getErrorBias()
        {
            return cpConstraintGetMaxBias(cconstraint);
        }
        
        GLfloat constraint::getImpulse()
        {
            return cpConstraintGetImpulse(cconstraint);
        }
        
        
#pragma mark -
#pragma mark Pin Joint
        pinJoint::pinJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& anchor1, vi::common::vector2 const& anchor2)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpPinJointNew(bodyA, bodyB, cpv(anchor1.x, anchor1.y), cpv(anchor2.x, anchor2.y));
        }
        
        
        void pinJoint::setAnchor1(vi::common::vector2 const& anchor1)
        {
            cpPinJointSetAnchr1(cconstraint, cpv(anchor1.x, anchor1.y));
        }
        
        void pinJoint::setAnchor2(vi::common::vector2 const& anchor2)
        {
            cpPinJointSetAnchr2(cconstraint, cpv(anchor2.x, anchor2.y));
        }
        
        void pinJoint::setDistance(GLfloat distance)
        {
            cpPinJointSetDist(cconstraint, distance);
        }
        
        
        
        vi::common::vector2 pinJoint::getAnchor1()
        {
            cpVect vector = cpPinJointGetAnchr1(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        vi::common::vector2 pinJoint::getAnchor2()
        {
            cpVect vector = cpPinJointGetAnchr2(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        GLfloat pinJoint::getDistance()
        {
            return cpPinJointGetDist(cconstraint);
        }
        
        
#pragma mark -
#pragma mark Slide Joint
        slideJoint::slideJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& anchor1, vi::common::vector2 const& anchor2, GLfloat min, GLfloat max)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpSlideJointNew(bodyA, bodyB, cpv(anchor1.x, anchor1.y), cpv(anchor2.x, anchor2.y), min, max);
        }
        
        
        void slideJoint::setAnchor1(vi::common::vector2 const& anchor1)
        {
            cpSlideJointSetAnchr1(cconstraint, cpv(anchor1.x, anchor1.y));
        }
        
        void slideJoint::setAnchor2(vi::common::vector2 const& anchor2)
        {
            cpSlideJointSetAnchr2(cconstraint, cpv(anchor2.x, anchor2.y));
        }
        
        void slideJoint::setMin(GLfloat min)
        {
            cpSlideJointSetMin(cconstraint, min);
        }
        
        void slideJoint::setMax(GLfloat max)
        {
            cpSlideJointSetMax(cconstraint, max);
        }
        
        
        vi::common::vector2 slideJoint::getAnchor1()
        {
            cpVect vector = cpSlideJointGetAnchr1(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        vi::common::vector2 slideJoint::getAnchor2()
        {
            cpVect vector = cpSlideJointGetAnchr2(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        GLfloat slideJoint::getMin()
        {
            return cpSlideJointGetMin(cconstraint);
        }
        
        GLfloat slideJoint::getMax()
        {
            return cpSlideJointGetMax(cconstraint);
        }
        
        
#pragma mark -
#pragma mark Pivot Joint
        pivotJoint::pivotJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& anchor1, vi::common::vector2 const& anchor2)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpPivotJointNew2(bodyA, bodyB, cpv(anchor1.x, anchor1.y), cpv(anchor2.x, anchor2.y));
        }
        
        pivotJoint::pivotJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& pivot)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpPivotJointNew(bodyA, bodyB, cpv(pivot.x, pivot.y));
        }
        
        
        void pivotJoint::setAnchor1(vi::common::vector2 const& anchor1)
        {
            cpPivotJointSetAnchr1(cconstraint, cpv(anchor1.x, anchor1.y));
        }
        
        void pivotJoint::setAnchor2(vi::common::vector2 const& anchor2)
        {
            cpPivotJointSetAnchr2(cconstraint, cpv(anchor2.x, anchor2.y));
        }
        
        
        vi::common::vector2 pivotJoint::getAnchor1()
        {
            cpVect vector = cpPivotJointGetAnchr1(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        vi::common::vector2 pivotJoint::getAnchor2()
        {
            cpVect vector = cpPivotJointGetAnchr2(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        
#pragma mark -
#pragma mark Groove Joint
        grooveJoint::grooveJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& grooveA, vi::common::vector2 const& grooveB, vi::common::vector2 const& anchor2)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpGrooveJointNew(bodyA, bodyB, cpv(grooveA.x, grooveA.y), cpv(grooveB.x, grooveB.y), cpv(anchor2.x, anchor2.y));
        }
        
        void grooveJoint::setGrooveA(vi::common::vector2 const& grooveA)
        {
            cpGrooveJointSetGrooveA(cconstraint, cpv(grooveA.x, grooveA.y));
        }
        
        void grooveJoint::setGrooveB(vi::common::vector2 const& grooveB)
        {
            cpGrooveJointSetGrooveB(cconstraint, cpv(grooveB.x, grooveB.y));
        }
        
        void grooveJoint::setAnchor2(vi::common::vector2 const& anchor2)
        {
            cpGrooveJointSetAnchr2(cconstraint, cpv(anchor2.x, anchor2.y));
        }
        
        
        vi::common::vector2 grooveJoint::getGrooveA()
        {
            cpVect vector = cpGrooveJointGetGrooveA(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        vi::common::vector2 grooveJoint::getGrooveB()
        {
            cpVect vector = cpGrooveJointGetGrooveB(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        vi::common::vector2 grooveJoint::getAnchor2()
        {
            cpVect vector = cpGrooveJointGetAnchr2(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        
#pragma mark -
#pragma mark Damped Spring
        dampedSpring::dampedSpring(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& anchor1, vi::common::vector2 const& anchor2, GLfloat restLength, GLfloat stiffness, GLfloat damping)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpDampedSpringNew(bodyA, bodyB, cpv(anchor1.x, anchor1.y), cpv(anchor2.x, anchor2.y), restLength, stiffness, damping);
        }
        
        void dampedSpring::setAnchor1(vi::common::vector2 const& anchor1)
        {
            cpDampedSpringSetAnchr1(cconstraint, cpv(anchor1.x, anchor1.y));
        }
        
        void dampedSpring::setAnchor2(vi::common::vector2 const& anchor2)
        {
            cpDampedSpringSetAnchr2(cconstraint, cpv(anchor2.x, anchor2.y));
        }
        
        void dampedSpring::setRestLength(GLfloat restLength)
        {
            cpDampedSpringSetRestLength(cconstraint, restLength);
        }
        
        void dampedSpring::setStiffness(GLfloat stiffness)
        {
            cpDampedSpringSetStiffness(cconstraint, stiffness);
        }
        
        void dampedSpring::setDamping(GLfloat damping)
        {
            cpDampedSpringSetDamping(cconstraint, damping);
        }
        
        
        vi::common::vector2 dampedSpring::getAnchor1()
        {
            cpVect vector = cpDampedSpringGetAnchr1(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        vi::common::vector2 dampedSpring::getAnchor2()
        {
            cpVect vector = cpDampedSpringGetAnchr2(cconstraint);
            return vi::common::vector2(vector.x, vector.y);
        }
        
        GLfloat dampedSpring::getRestLength()
        {
            return cpDampedSpringGetRestLength(cconstraint);
        }
        
        GLfloat dampedSpring::getStiffness()
        {
            return cpDampedSpringGetStiffness(cconstraint);
        }
        
        GLfloat dampedSpring::getDamping()
        {
            return cpDampedSpringGetDamping(cconstraint);
        }
      
        
#pragma mark -
#pragma mark Damped Rotary Spring
        dampedRotarySpring::dampedRotarySpring(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, GLfloat restAngle, GLfloat stiffness, GLfloat damping)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpDampedRotarySpringNew(bodyA, bodyB, restAngle, stiffness, damping);
        }

        void dampedRotarySpring::setRestAngle(GLfloat restAngle)
        {
            cpDampedRotarySpringSetRestAngle(cconstraint, restAngle);
        }
        
        void dampedRotarySpring::setStiffness(GLfloat stiffness)
        {
            cpDampedRotarySpringSetStiffness(cconstraint, stiffness);
        }
        
        void dampedRotarySpring::setDamping(GLfloat damping)
        {
            cpDampedRotarySpringSetDamping(cconstraint, damping);
        }
        
        
        
        GLfloat dampedRotarySpring::getRestAngle()
        {
            return cpDampedRotarySpringGetRestAngle(cconstraint);
        }
        
        GLfloat dampedRotarySpring::getStiffness()
        {
            return cpDampedRotarySpringGetStiffness(cconstraint);
        }
        
        GLfloat dampedRotarySpring::getDamping()
        {
            return cpDampedRotarySpringGetDamping(cconstraint);
        }
        
        
#pragma mark -
#pragma mark Rotary Limit Joint
        rotaryLimitJoint::rotaryLimitJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, GLfloat min, GLfloat max)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpRotaryLimitJointNew(bodyA, bodyB, min, max);
        }
        
        void rotaryLimitJoint::setMin(GLfloat min)
        {
            cpRotaryLimitJointSetMin(cconstraint, min);
        }
        
        void rotaryLimitJoint::setMax(GLfloat max)
        {
            cpRotaryLimitJointSetMax(cconstraint, max);
        }
        
        GLfloat rotaryLimitJoint::getMin()
        {
            return cpRotaryLimitJointGetMin(cconstraint);
        }
        
        GLfloat rotaryLimitJoint::getMax()
        {
            return cpRotaryLimitJointGetMax(cconstraint);
        }
        
        
#pragma mark -
#pragma mark Ratchet Joint
        ratchetJoint::ratchetJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, GLfloat phase, GLfloat ratchet)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpRatchetJointNew(bodyA, bodyB, phase, ratchet);
        }
        
        void ratchetJoint::setPhase(GLfloat phase)
        {
            cpRatchetJointSetPhase(cconstraint, phase);
        }
        
        void ratchetJoint::setRatchet(GLfloat ratchet)
        {
            cpRatchetJointSetRatchet(cconstraint, ratchet);
        }
        
        void ratchetJoint::setAngle(GLfloat angle)
        {
            cpRatchetJointSetAngle(cconstraint, angle);
        }
        
        
        GLfloat ratchetJoint::getPhase()
        {
            return cpRatchetJointGetPhase(cconstraint);
        }
        
        GLfloat ratchetJoint::getRatchet()
        {
            return cpRatchetJointGetRatchet(cconstraint);
        }
        
        GLfloat ratchetJoint::getAngle()
        {
            return cpRatchetJointGetAngle(cconstraint);
        }
        
        
#pragma mark -
#pragma mark Gear Joint
        gearJoint::gearJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, GLfloat phase, GLfloat ratio)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpGearJointNew(bodyA, bodyB, phase, ratio);
        }
        
        void gearJoint::setPhase(GLfloat phase)
        {
            cpGearJointSetPhase(cconstraint, phase);
        }
        
        void gearJoint::setRatio(GLfloat ratio)
        {
            cpGearJointSetRatio(cconstraint, ratio);
        }
        
        
        GLfloat gearJoint::getPhase()
        {
            return cpGearJointGetPhase(cconstraint);
        }
        
        GLfloat gearJoint::getRatio()
        {
            return cpGearJointGetRatio(cconstraint);
        }
        
        
#pragma mark -
#pragma mark Simple Motor
        simpleMotor::simpleMotor(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, GLfloat rate)
        {
            cpBody *bodyA = nodeA->getCPBody();
            cpBody *bodyB = nodeB->getCPBody();
            
            assert(bodyA);
            assert(bodyB);
            
            cconstraint = cpSimpleMotorNew(bodyA, bodyB, rate);
        }
        
        void simpleMotor::setRate(GLfloat rate)
        {
            cpSimpleMotorSetRate(cconstraint, rate);
        }
        
        GLfloat simpleMotor::getRate()
        {
            return cpSimpleMotorGetRate(cconstraint);
        }
    };
}

#endif
