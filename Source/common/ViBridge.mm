//
//  ViBridge.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViBridge.h"
#import "ViBase.h"

namespace vi
{
    namespace common
    {
        objCBridge::objCBridge(id ttarget, SEL tselector)
        {
            staticNull = NULL;
            invocation = nil;
            
            setTarget(ttarget, tselector);
        }
        
        objCBridge::objCBridge(objCBridge const& other)
        {
            target      = other.target;
            selector    = other.selector;
            targetResponds  = other.targetResponds;
            neededArguments = other.neededArguments;
            
            invocation = [other.invocation retain];
        }
        
        objCBridge::~objCBridge()
        {
            [invocation release];
        }
        
        
        
        objCBridge& objCBridge::operator= (objCBridge const& other)
        {
            target      = other.target;
            selector    = other.selector;
            targetResponds  = other.targetResponds;
            neededArguments = other.neededArguments;
            
            invocation = [other.invocation retain];
            return *this;
        }
        
        
        void objCBridge::setTarget(id ttarget, SEL tselector)
        {
            target      = ttarget;
            selector    = tselector;
            
            // Reset the state of the bridge
            [invocation release];
            
            targetResponds  = false;
            neededArguments = 0;
            invocation      = nil;
            
            
            // Check if the target responds to the selector
            if([target respondsToSelector:selector])
            {
                // Build the invocation
                NSMethodSignature *signature = [target methodSignatureForSelector:selector];
                neededArguments = (int32_t)[signature numberOfArguments] - 2; // We need to subtract the two hidden arguments
                
                invocation = [[NSInvocation invocationWithMethodSignature:signature] retain];
                [invocation setTarget:target];
                [invocation setSelector:selector];
                
                targetResponds = true;
            }
        }
        
        void objCBridge::invokeWithArguments(void *arg1, void *arg2, void *arg3)
        {
            if(targetResponds)
            {
                // Copy the arguments and fill not provided ones up with NULL
                for(int32_t i=0; i<neededArguments; i++)
                {
                    switch(i)
                    {
                        case 0:
                            [invocation setArgument:arg1 atIndex:2];
                            break;
                            
                        case 1:
                            [invocation setArgument:arg2 atIndex:3];
                            break;
                            
                        case 2:
                            [invocation setArgument:arg3 atIndex:4];
                            break;
                            
                        default:
                            [invocation setArgument:&staticNull atIndex:i + 2];
                            break;
                    }
                }
                
                [invocation invoke];
            }
            else
            {
                // Woops!
                ViLog(@"Tried to invoke %s, but %@ doesn't respond to it!", (const char *)selector, target);
            }
        }
    }
}


@implementation ViCppBridge
@synthesize function0, function1, function2, function3;

- (void)parameter0Action
{
    if(function0)
        function0();
}

- (void)parameter1Action:(void *)value
{
    if(function1)
    {
        function1(value);
    }
    else
    {
        [self parameter0Action];
    }
}

- (void)parameter2Action:(void *)value1 :(void *)value2
{
    if(function2)
    {
        function2(value1, value2);
    }
    else
    {
        [self parameter1Action:value1];
    }
}

- (void)parameter3Action:(void *)value1 :(void *)value2 :(void *)value3
{
    if(function3)
    {
        function3(value1, value2, value3);
    }
    else
    {
        [self parameter2Action:value1 :value2];
    }
}

@end
