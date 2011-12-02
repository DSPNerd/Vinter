//
//  ViBridge.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <tr1/functional>
#import <Foundation/Foundation.h>

namespace vi
{
    namespace common
    {
        /**
         * @brief Forwards C++ method invocations to an Objective-C target
         * @details This class takes a target and selector, which are invoked when one of the methods provided by this class is invoked. This is useful for forwarding
         * C++ callbacks to an Objective-C function.
         * When you invoke a method with the wrong number of parameters, eg. the receiving object expects three parameters but you invoke parameter1Action(), the missing arguments
         * will be replaced by NULL. If you pass to many parameters, the not needed parameters are ditched instead.
         * @see ViCppBridge
         **/
        class objCBridge
        {
        public:
            /**
             * @brief Constructor
             * @param target The target that should receive the method
             * @param selector The selector that should be invoked on the target;
             * @see setTarget()
             **/
            objCBridge(id target=nil, SEL selector=NULL);   
            /**
             * @brief Copy Constructor
             **/
            objCBridge(objCBridge const& other);
            
            /**
             * @brief Destructor
             **/
            ~objCBridge();
            
            
            objCBridge& operator= (objCBridge const& other);

            
            
            /**
             * @brief Sets a new target and selector
             * @param target The target that should receive the method
             * @param selector The selector that should be invoked on the target;
             **/
            void setTarget(id target, SEL selector);
            
            
            
            /**
             * @brief Invokes the selector on the target without passing any parameter.
             * @note The signature of the receiving method should look like this: `- (void)foo`
             **/
            void parameter0Action()
            {
                invokeWithArguments(&staticNull, &staticNull, &staticNull);
            }
            
            /**
             * @brief Invokes the selector on the target passing all given parameters.
             * @note The signature of the receiving method should look like this: `- (void)foo:(T)param`
             **/
            template <class T>
            void parameter1Action(T value)
            {
                invokeWithArguments(&value, &staticNull, &staticNull);
            }
            
            /**
             * @brief Invokes the selector on the target passing all given parameters.
             * @note The signature of the receiving method should look like this: `- (void)foo:(T1)param1 :(T2)param2`
             **/
            template <class T1, class T2>
            void parameter2Action(T1 value1, T2 value2)
            {
                invokeWithArguments(&value1, &value2, &staticNull);
            }
            
            /**
             * @brief Invokes the selector on the target passing all given parameters.
             * @note The signature of the receiving method should look like this: `- (void)foo:(T1)param1 :(T2)param2 :(T3)param3`
             **/
            template <class T1, class T2, class T3>
            void parameter3Action(T1 value1, T2 value2, T3 value3)
            {
                invokeWithArguments(&value1, &value2, &value3);
            }
            
            
        private:
            void invokeWithArguments(void *arg1, void *arg2, void *arg3);
            
            bool    targetResponds;
            int32_t neededArguments;
            
            id  target;
            SEL selector;
            
            void *staticNull;
            NSInvocation *invocation;
        };
    }
}


/**
 * @brief Forwards Objective-C invocations to an C++ target
 * @details This class forwards methods that are invoked on it to a bound function.
 * @see vi::common::objcBridge
 **/
@interface ViCppBridge : NSObject
{
}


/**
 * @brief A function without a parameter, invoked when parameter0Action is invoked.
 **/
@property (nonatomic, assign) std::tr1::function<void ()> function0;
/**
 * @brief A function with one parameter, invoked when parameter1Action is invoked.
 **/
@property (nonatomic, assign) std::tr1::function<void (void *)> function1;
/**
 * @brief A function with two parameters, invoked when parameter2Action is invoked.
 **/
@property (nonatomic, assign) std::tr1::function<void (void *, void *)> function2;
/**
 * @brief A function with three parameters, invoked when parameter3Action is invoked.
 **/
@property (nonatomic, assign) std::tr1::function<void (void *, void *, void *)> function3;


/**
 * @brief Invokes function0
 * @details If function0 isn't set, this function won't do anything.
 * @see function0
 **/
- (void)parameter0Action;
/**
 * @brief Invokes function1
 * @details If function1 isn't set, the function will call parameter0Action instead.
 * @see function1
 **/
- (void)parameter1Action:(void *)value;
/**
 * @brief Invokes function2
 * @details If function2 isn't set, the function will call parameter1Action instead.
 * @see function2
 **/
- (void)parameter2Action:(void *)value1 :(void *)value2;
/**
 * @brief Invokes function3
 * @details If function3 isn't set, the function will call parameter2Action instead.
 * @see function3
 **/
- (void)parameter3Action:(void *)value1 :(void *)value2 :(void *)value3;

@end
