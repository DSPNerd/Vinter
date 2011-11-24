//
//  ViAnimationServer.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <stack>
#include <vector>
#include <string>

#import "ViAnimation.h"
#import "ViAnimationStack.h"

namespace vi
{
    namespace animation
    {
        class animationServer
        {
        public:
            ~animationServer();
            
            void run(double timestep);
            
            
            animationStack *beginAnimation(std::string const& animationID = "");
            animationStack *topStack();
            animationStack *animationWithIdentifier(std::string const& animationID);
            
            void commitAnimation();
            void stopAnimationWithIdentifier(std::string const& animationID);
            
        private:
            std::vector<animationStack *> committedAnimations;
            std::stack<animationStack *> buildingAnimations;
        };
    }
}
