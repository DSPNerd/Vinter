//
//  ViEvent.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <vector>
#import "ViEvent.h"
#import "ViEventListener.h"

namespace vi
{
    namespace event
    {
        event::event(eventType ttype)
        {
            type = ttype;
            timestamp = [NSDate timeIntervalSinceReferenceDate];
            __lastListener = NULL;
        }
        
        event::~event()
        {
        }
        
        
        void event::raise()
        {
            std::vector<eventListener *> *listener = eventListener::getListenerVector();
            std::vector<eventListener *>::iterator iterator;
            
            for(iterator=listener->begin(); iterator!=listener->end(); iterator++)
            {
                eventListener *listener = *iterator;
                if(__lastListener && __lastListener == listener)
                {
                    __lastListener = NULL;
                    continue;
                }
                else if(__lastListener && __lastListener != listener)
                    continue;
                
                
                if(listener->canHandleEvent(this))
                {
                     __lastListener = (void *)listener;
                    listener->handleEvent(this);
                    
                    return;
                }
            }
        }
        
        
        
        
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
        mouseEvent::mouseEvent(NSEvent *otherEvent, mouseEventType tsubtype) : event(eventTypeMouse)
        {
            window          = [otherEvent window];
            timestamp       = (double)[otherEvent timestamp];
            wrappedEvent    = otherEvent;
            subtype         = tsubtype;
            
            
            buttonNumber    = (uint32_t)[otherEvent buttonNumber];
            clickCount      = (uint32_t)[otherEvent clickCount];
            
            
            CGPoint mouseLocation = [otherEvent locationInWindow];
            mouseLocation = [(NSView *)[window contentView] convertPoint:mouseLocation fromView:nil];
            
            mousePosition = vi::common::vector2(mouseLocation);
            
            mousePosition.y -= [(NSView *)[window contentView] frame].size.height;
            mousePosition.y = -mousePosition.y;
        }
        
        
        keyboardEvent::keyboardEvent(NSEvent *otherEvent, keyboardEventType tsubtype) : event(eventTypeKeyboard)
        {
            timestamp       = (double)[otherEvent timestamp];
            wrappedEvent    = otherEvent;
            subtype         = tsubtype;
            
            characters  = std::string([[otherEvent characters] UTF8String]);
            isRepeat    = [otherEvent isARepeat];
            keyCode     = [otherEvent keyCode];
        }
#endif
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        touchEvent::touchEvent(touchEventType tsubtype, UIEvent *otherEvent, UIView *tview) : event(eventTypeTouch)
        {
            timestamp       = (double)[otherEvent timestamp];
            subtype         = tsubtype;
            wrappedEvent    = otherEvent;
            view            = tview;
            
            touches     = [otherEvent touchesForView:tview];
            touchCount  = [touches count];
        }
#endif
        
        renderEvent::renderEvent(renderEventType tsubtype, vi::scene::scene *tscene, vi::common::kernel *tkernel) : event(eventTypeRenderer)
        {
            subtype = tsubtype;
            scene   = tscene;
            kernel  = tkernel;
            
            timestep = 0.0;
        }
        
        animationEvent::animationEvent(animationEventType tsubtype, vi::animation::animationStack *tstack) : event(eventTypeAnimation)
        {
            subtype = tsubtype;
            stack   = tstack;
        }
        
#ifdef ViPhysicsChipmunk
        physicEvent::physicEvent(physicEventType tsubtype, vi::scene::scene *tscene, cpArbiter *tarbiter) : event(eventTypePhysic)
        {
            subtype = tsubtype;
            scene   = scene;
            arbiter = tarbiter;
            
            returnValue = 1;
            
            cpBody *bodyA;
            cpBody *bodyB;
            cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
            
            nodeA = (vi::scene::sceneNode *)cpBodyGetUserData(bodyA);
            nodeB = (vi::scene::sceneNode *)cpBodyGetUserData(bodyB);
        }
#endif
    }
}
