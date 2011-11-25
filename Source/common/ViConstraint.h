//
//  ViConstraint.h
//  Physics
//
//  Created by Sidney Just on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViBase.h"
#import "ViSceneNode.h"

#ifdef ViPhysicsChipmunk

namespace vi
{
    namespace common
    {
        class constraint
        {
        public:
            virtual ~constraint();
            
            vi::scene::sceneNode *getNodeA();
            vi::scene::sceneNode *getNodeB();
            
            void setMaxForce(GLfloat maxForce);
            void setErrorBias(GLfloat bias);
            
            GLfloat getMaxForce();
            GLfloat getErrorBias();
            GLfloat getImpulse();
            
        protected:
            constraint();
            
            bool breakable;
            cpConstraint *cconstraint;
        };
        
        
        
        class pinJoint : public constraint
        {
        public:
            pinJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& anchor1, vi::common::vector2 const& anchor2);
            
            
            void setAnchor1(vi::common::vector2 const& anchor1);
            void setAnchor2(vi::common::vector2 const& anchor2);
            void setDistance(GLfloat distance);
            
            vi::common::vector2 getAnchor1();
            vi::common::vector2 getAnchor2();
            GLfloat getDistance();
        };
        
        class slideJoint : public constraint
        {
        public:
            slideJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& anchor1, vi::common::vector2 const& anchor2, GLfloat min, GLfloat max);
            
            void setAnchor1(vi::common::vector2 const& anchor1);
            void setAnchor2(vi::common::vector2 const& anchor2);
            void setMin(GLfloat min);
            void setMax(GLfloat max);
            
            vi::common::vector2 getAnchor1();
            vi::common::vector2 getAnchor2();
            GLfloat getMin();
            GLfloat getMax();
        };
        
        class pivotJoint : public constraint
        {
        public:
            pivotJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& anchor1, vi::common::vector2 const& anchor2);
            pivotJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& pivot);
            
            void setAnchor1(vi::common::vector2 const& anchor1);
            void setAnchor2(vi::common::vector2 const& anchor2);
            
            vi::common::vector2 getAnchor1();
            vi::common::vector2 getAnchor2();
        };
        
        class grooveJoint : public constraint
        {
        public:
            grooveJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& grooveA, vi::common::vector2 const& grooveB, vi::common::vector2 const& anchor2);
        
            void setGrooveA(vi::common::vector2 const& grooveA);
            void setGrooveB(vi::common::vector2 const& grooveB);
            void setAnchor2(vi::common::vector2 const& anchor2);
            
            vi::common::vector2 getGrooveA();
            vi::common::vector2 getGrooveB();
            vi::common::vector2 getAnchor2();
        };
        
        class dampedSpring : public constraint
        {
        public:
            dampedSpring(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, vi::common::vector2 const& anchor1, vi::common::vector2 const& anchor2, GLfloat restLength, GLfloat stiffness, GLfloat damping);
        
            void setAnchor1(vi::common::vector2 const& anchor1);
            void setAnchor2(vi::common::vector2 const& anchor2);
            void setRestLength(GLfloat restLength);
            void setStiffness(GLfloat stiffness);
            void setDamping(GLfloat damping);
            
            vi::common::vector2 getAnchor1();
            vi::common::vector2 getAnchor2();
            GLfloat getRestLength();
            GLfloat getStiffness();
            GLfloat getDamping();
        };
        
        class dampedRotarySpring : public constraint
        {
        public:
            dampedRotarySpring(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, GLfloat restAngle, GLfloat stiffness, GLfloat damping);
            
            void setRestAngle(GLfloat restLength);
            void setStiffness(GLfloat stiffness);
            void setDamping(GLfloat damping);
            
            GLfloat getRestAngle();
            GLfloat getStiffness();
            GLfloat getDamping();
        };
        
        class rotaryLimitJoint : public constraint
        {
        public:
            rotaryLimitJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, GLfloat min, GLfloat max);
            
            void setMin(GLfloat min);
            void setMax(GLfloat max);
            
            GLfloat getMin();
            GLfloat getMax();
        };
        
        class ratchetJoint : public constraint
        {
        public:
            ratchetJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, GLfloat phase, GLfloat ratchet);
            
            void setPhase(GLfloat phase);
            void setRatchet(GLfloat ratchet);
            void setAngle(GLfloat angle);
            
            GLfloat getPhase();
            GLfloat getRatchet();
            GLfloat getAngle();
        };
        
        class gearJoint : public constraint
        {
        public:
            gearJoint(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, GLfloat phase, GLfloat ratio);
            
            void setPhase(GLfloat phase);
            void setRatio(GLfloat ratio);
            
            GLfloat getPhase();
            GLfloat getRatio();
        };
        
        class simpleMotor : public constraint
        {
        public:
            simpleMotor(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB, GLfloat rate);
            
            void setRate(GLfloat rate);
            GLfloat getRate();
        };
    }
}

#endif
