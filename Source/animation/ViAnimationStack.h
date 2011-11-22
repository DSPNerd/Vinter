//
//  ViAnimationStack.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <vector>
#include <stack>
#import "ViAnimation.h"

#define ViAnimationRepeatIndefinitely UINT32_MAX

namespace vi
{
    namespace animation
    {
        typedef enum
        {
            animationStackStateBuilding,
            animationStackStateWaiting,
            animationStackStateRunning,
            animationStackStateEnded
        } animationStackState;
        
        class animationServer;
        class animationPath;
        
        
        struct animationPath
        {
            std::vector<vi::animation::animation *> animations;
            
            double animationDelay;
            double animationDuration;
            animationCurve curve;
        };

        class animationStack
        {
            friend class animationServer;
            friend class animationPath;
        public:
            animationStack();
            
            void run(double timestep);
            void addAnimation(vi::animation::animation *animation);
            void addPath();
            
            void setAnimationDelay(double delay);
            void setAnimationDuration(double duration);
            void setAnimationCurve(animationCurve curve);
            void setAutoreverses(bool autoreverse);
            void setWaitForOtherAnimations(bool waitForOtherAnimations);
            void setRepeatCount(uint32_t repeatCount);
            
        private:
            animationStackState state;
            double accumulatedTime;
            
            bool autoreverse;
            bool waitForOtherAnimations;
            uint32_t repeatCount;
            char direction;
            
            vi::animation::animationPath *lastPath;
            int32_t animationIterator;
            std::vector<vi::animation::animationPath *> animations;
        };
    }
}
