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
        /**
         * @brief Class that runs animations
         *
         * A animation server is used to run animations by maintaining a list of animation stacks. Each animation server maintains it own
         * list of animation and runs them each time you run the server. Each vi::scen::scene already creates an animation server for convience reasons
         * which is bound to the engines framerate, however, if you need a animation server that runs with a fixed framerate, you need to create your own.
         **/
        class animationServer
        {
        public:
            /**
             * Destructor
             * Automatically deletes all animation stacks (running and non-commited ones). Don't call this from an animation callback!
             **/
            ~animationServer();
            
            /**
             * Runs all animation stacks and removes no longer running or stopped animations.
             **/
            void run(double timestep);
            
            
            /**
             * Creates and returns a new animation stack.
             * @param animationID Identifier used to reference the animation stack.
             * @sa commitAnimation()
             **/
            animationStack *beginAnimation(std::string const& animationID = "");
            /**
             * Returns the last stack created by beginAnimation() which isn't commited using commitAnimation()
             **/
            animationStack *topStack();
            /**
             * Returns the stack with the given identifier or NULL
             **/
            animationStack *animationWithIdentifier(std::string const& animationID);
            
            /**
             * Commits the last created animation.
             * @remark You need to call this function when you are done creating your animation in order to have the animation server run it.
             **/
            void commitAnimation();
            /**
             * Stops the animation with the given identifer.
             **/
            void stopAnimationWithIdentifier(std::string const& animationID);
            
        private:
            std::vector<animationStack *> committedAnimations;
            std::stack<animationStack *> buildingAnimations;
        };
    }
}
