//
//  ViAnimationStack.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViBase.h"
#import "ViAnimationServer.h"

namespace vi
{
    namespace animation
    {        
        animationStack::animationStack()
        {
            state = animationStackStateBuilding;
            accumulatedTime = 0.0;
            
            lastPath = new vi::animation::animationPath();
            lastPath->animationDelay = 0.0;
            lastPath->animationDuration = 1.0;
            lastPath->updateValues = false;
            lastPath->curve = animationCurveLinearTweening;
            animations.push_back(lastPath);
            
            animationIterator = 0;
            
            autoreverse = false;
            waitForOtherAnimations = false;
            firstRun = true;
            
            repeatCount = 0;
            direction = 1;
        }
        
        
        void animationStack::run(double timestep)
        {
            if(state == animationStackStateEnded)
                return;
            
            if(state == animationStackStateBuilding)
            {
                vi::animation::animationPath *path = *(animations.begin() + animationIterator);
                
                std::vector<vi::animation::animation *>::iterator iterator;
                for(iterator=path->animations.begin(); iterator!=path->animations.end(); iterator++)
                {
                    vi::animation::animation *tanimation = *iterator;
                    
                    tanimation->setDuration(path->animationDuration);
                    tanimation->setAnimationCurve(path->curve);
                    
                    if(path->updateValues && !firstRun)
                        tanimation->updateValues();
                }
                
                state = animationStackStateWaiting;
            }
            
            
            vi::animation::animationPath *path = *(animations.begin() + animationIterator);
            if(state == animationStackStateWaiting)
            {
                if(path->animationDelay > 0)
                {
                    accumulatedTime += timestep;
                    
                    if(accumulatedTime >= path->animationDelay)
                    {
                        accumulatedTime = 0.0;
                        state = animationStackStateRunning;
                    }
                    
                    return;
                }
            }
            
            
            state = animationStackStateRunning;
            
            double overflow = (accumulatedTime + timestep) - path->animationDuration;
            accumulatedTime = MIN(accumulatedTime + timestep, path->animationDuration);
            
            
            
            bool needsReverse = (accumulatedTime >= path->animationDuration && repeatCount > 0 && autoreverse);
            
            std::vector<vi::animation::animation *>::iterator iterator;
            for(iterator=path->animations.begin(); iterator!=path->animations.end(); iterator++)
            {
                vi::animation::animation *tanimation = *iterator;
                tanimation->apply(accumulatedTime);
                
                if(needsReverse)
                    tanimation->reverse();
            }
            
            
            if(accumulatedTime >= path->animationDuration)
            {
                animationIterator += direction;
                state = animationStackStateBuilding;
                accumulatedTime = 0.0;
                
                if((direction == 1 && animationIterator == animations.size()) || (direction == -1 && animationIterator == -1))
                {
                    if(repeatCount > 0)
                    {
                        firstRun = false;
                        accumulatedTime = 0.0;
                        animationIterator = 0;
                        
                        if(autoreverse && direction == 1)
                        {
                            animationIterator = (int)animations.size() - 1;
                            direction = -1;
                        }
                        else if(autoreverse && direction == -1)
                        {
                            direction = 1;
                        }
                        
                        
                        if(repeatCount == ViAnimationRepeatIndefinitely)
                        {
                            if(overflow > kViEpsilonFloat)
                                run(overflow);
                                
                            return;
                        }
                        
                        repeatCount --;
                        if(overflow > kViEpsilonFloat)
                            run(overflow);
                        
                        return;
                    }
                    
                    state = animationStackStateEnded;
                }
            }
        }
        
        
        void animationStack::addAnimation(vi::animation::animation *animation)
        {
            lastPath->animations.push_back(animation);
        }
        
        void animationStack::addPath()
        {
            animationPath *path = new vi::animation::animationPath();
            path->animationDuration = lastPath->animationDuration;
            path->animationDelay = lastPath->animationDelay;
            path->updateValues = lastPath->updateValues;
            path->curve = lastPath->curve;
            
            animations.push_back(path);
            
            lastPath = path;
        }
        
        
        void animationStack::setAnimationDelay(double delay)
        {
            lastPath->animationDelay = delay;
        }
        
        void animationStack::setAnimationDuration(double duration)
        {
            lastPath->animationDuration = duration;
        }
        
        void animationStack::setAnimationCurve(animationCurve tcurve)
        {
            lastPath->curve = tcurve;
        }
        
        void animationStack::setUpdateValues(bool updateValues)
        {
            lastPath->updateValues = updateValues;
        }
        
        void animationStack::setAutoreverses(bool tautoreverse)
        {
            autoreverse = tautoreverse;
        }
        
        void animationStack::setWaitForOtherAnimations(bool twaitForOtherAnimations)
        {
            waitForOtherAnimations = twaitForOtherAnimations;
        }
        
        void animationStack::setRepeatCount(uint32_t trepeatCount)
        {
            repeatCount = trepeatCount;
        }
    }
}
