//
//  ViAnimationServer.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <stack>
#include <vector>

#import "ViAnimation.h"
#import "ViAnimationStack.h"

namespace vi
{
    namespace animation
    {
        class animationServer
        {
        public:
            void run(double timestep);
            
            animationStack *beginAnimation();
            animationPath *beginAnimationPath();
            
            animationStack *topStack();
            void commitAnimation();
            
        private:
            std::vector<animationStack *> committedAnimations;
            std::stack<animationStack *> buildingAnimations;
        };
    }
}
