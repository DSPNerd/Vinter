//
//  ViAnimationServer.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViAnimationServer.h"
#import "ViEvent.h"

namespace vi
{
    namespace animation
    {
        animationServer::~animationServer()
        {
            std::vector<animationStack *>::iterator iterator;
            for(iterator=committedAnimations.begin(); iterator!=committedAnimations.end(); iterator++)
            {
                animationStack *stack = *iterator;
                delete stack;
            }
            
            while(buildingAnimations.size() > 0)
            {
                animationStack *stack = buildingAnimations.top();
                buildingAnimations.pop();
                
                delete stack;
            }
        }
        
        
        void animationServer::run(double timestep)
        {
            bool hasRunningAnimation = false;
            
            for(int32_t i=(int32_t)committedAnimations.size()-1; i>=0; i--)
            {
                animationStack *stack = committedAnimations[i];
                
                if(stack->state == animationStackStateEnded || stack->state == animationStackStateStopped)
                {
                    vi::event::animationEvent event = vi::event::animationEvent(vi::event::animationEventTypeDidEnd, stack);
                    event.raise();
                    
                    committedAnimations.erase(committedAnimations.begin() + i);
                    delete stack;
                    
                    continue;
                }
                
                
                if(stack->waitForOtherAnimations && hasRunningAnimation)
                    continue;
                
                animationStackState previousState = stack->state;
                
                if(previousState == animationStackStateBuilding)
                {
                    vi::event::animationEvent event = vi::event::animationEvent(vi::event::animationEventTypeWillBegin, stack);
                    event.raise();
                }
                
                stack->run(timestep);
                hasRunningAnimation = true;
                
                if(previousState == animationStackStateBuilding)
                {
                    vi::event::animationEvent event = vi::event::animationEvent(vi::event::animationEventTypeDidBegin, stack);
                    event.raise();
                }
                else if(previousState == animationStackStateRunning && stack->state == animationStackStateBuilding)
                {
                    vi::event::animationEvent event = vi::event::animationEvent(vi::event::animationEventTypeWillRepeat, stack);
                    event.raise();
                }
            }
        }
        
        
        
        animationStack *animationServer::beginAnimation(std::string const& animationID)
        {
            animationStack *stack = new animationStack(animationID);
            buildingAnimations.push(stack);
            
            return stack;
        }
        
        animationStack *animationServer::topStack()
        {
            if(buildingAnimations.size() == 0)
                return NULL;
            
            animationStack *stack = buildingAnimations.top();
            return stack;
        }
        
        animationStack *animationServer::animationWithIdentifier(std::string const& animationID)
        {
            for(int32_t i=(int32_t)committedAnimations.size()-1; i>=0; i--)
            {
                animationStack *stack = committedAnimations[i];
                if(animationID.compare(stack->getIdentifier()) == 0)
                {
                    return stack;
                }
            }
            
            return NULL;
        }
        
        
        void animationServer::commitAnimation()
        {
            animationStack *stack = buildingAnimations.top();
            buildingAnimations.pop();
            
            committedAnimations.push_back(stack);
        }
        
        void animationServer::stopAnimationWithIdentifier(std::string const& animationID)
        {
            animationStack *stack = animationWithIdentifier(animationID);
            
            if(stack)
                stack->stop();
        }
    }
}
