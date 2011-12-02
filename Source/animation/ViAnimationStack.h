//
//  ViAnimationStack.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <string>
#include <vector>
#import "ViAnimation.h"

/**
 * Constant used to specific indefinitely repeating animations.
 **/
#define ViAnimationRepeatIndefinitely UINT32_MAX

namespace vi
{
    namespace animation
    {
        /**
         * Possible states of an animation stack
         **/
        typedef enum
        {
            /**
             * The animation stack never ran so far and is currently being build
             **/
            animationStackStateBuilding,
            /**
             * The animation stack already ran, but its currently waiting for an animation delay to pass
             **/
            animationStackStateWaiting,
            /**
             * The animation is currently running
             **/
            animationStackStateRunning,
            /**
             * The animation did end and won't be repeated
             **/
            animationStackStateEnded,
            /**
             * The animation was stopped by the user
             **/
            animationStackStateStopped
        } animationStackState;
        
        class animationServer;
        class animationPath;
        struct animationPath;

        /**
         * @brief Class describing an animation
         *
         * A animation stack consists out of one or more animation pathes each describing the state of all animated objects at a single point in time.
         **/
        class animationStack
        {
            friend class animationServer;
            friend class animationPath;
        public:
            /**
             * Runs the animation stack
             **/
            void run(double timestep);
            /**
             * Adds the given animation to the current animation path. When the animation path is run, the animation object is asked each
             * frame to apply its current by value to the object it animates.
             **/
            void addAnimation(vi::animation::animation *animation);
            /**
             * Finishes the current path node and adds a new one. The animation stack will run the pathes in the order they were created.
             * @remark The newly created path will inherit all properties like delay, duration and curve from the previous path!
             **/
            void addPath();
            
            /**
             * Sets the animation delay in seconds. The stack will wait for the specified amount before running the animation. Defaults to 0.0
             * @remark This value is set per path node!
             **/
            void setAnimationDelay(double delay);
            /**
             * Sets the animation duration in seconds. The stack will make sure that the animation completes when the animation ran for the specified duration. Defaults to 1.0
             * @remark This value is set per path node!
             **/
            void setAnimationDuration(double duration);
            /**
             * Sets the animation curve. Defaults to animationCurveLinearTweening
             * @remark This value is set per path node!
             **/
            void setAnimationCurve(animationCurve curve);
            /**
             * If this is set to true (default false), the animation stack will reverse the animation before repeating it.
             **/
            void setAutoreverses(bool autoreverse);
            /**
             * If this is set to true (default false), the animation stack will force the aniamtion to use the current values of the animated properties instead of replaying the same sequence
             * @remark Only used when the animation repeats!
             * @remark This value is set per path node!
             **/
            void setUpdateValues(bool updateValues);
            /**
             * If true (default false), the animation will wait for other animations to finish before running.
             * @remark This value is set per path node!
             **/
            void setWaitForOtherAnimations(bool waitForOtherAnimations);
            /**
             * Sets the number of times the animation should repeat. Defaults to 0.
             **/
            void setRepeatCount(uint32_t repeatCount);
            
            
            /**
             * Forces the animation to stop
             * @remark All animated properties won't be set to their end values!
             **/
            void stop();
            
            
            /**
             * Returns the identifier of the stack
             **/
            std::string getIdentifier();
            /**
             * Returns the current state of the stack
             **/
            animationStackState getState();
            
            
        private:
            animationStack(std::string const& animationID="");
            ~animationStack();
            
            std::string identifier;
            animationStackState state;
            double accumulatedTime;
            
            bool firstRun;
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
