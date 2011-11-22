//
//  ViAnimationServer.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViAnimationServer.h"

namespace vi
{
    namespace animation
    {
        void animationServer::run(double timestep)
        {
            bool hasRunningAnimation = false;
            
            for(int32_t i=(int32_t)committedAnimations.size()-1; i>=0; i--)
            {
                animationStack *stack = committedAnimations[i];
                
                if(stack->waitForOtherAnimations && hasRunningAnimation)
                    continue;
                
                
                stack->run(timestep);
                hasRunningAnimation = true;
                
                if(stack->state == animationStackStateEnded)
                {
                    committedAnimations.erase(committedAnimations.begin() + i);
                    delete stack;
                }
            }
        }
        
        
        
        animationStack *animationServer::beginAnimation()
        {
            animationStack *stack = new animationStack();
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
        
        void animationServer::commitAnimation()
        {
            animationStack *stack = buildingAnimations.top();
            buildingAnimations.pop();
            
            committedAnimations.push_back(stack);
        }
    }
}
