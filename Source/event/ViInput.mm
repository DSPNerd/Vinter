//
//  ViInput.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViInput.h"

namespace vi
{
    namespace event
    {
        input::input()
        {
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            downKeys = 0;
            accumulatedString = [[NSMutableString alloc] init];
#endif
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
            touches = NULL;
            touchCount = 0;
#endif
        }
        
        input::~input()
        {
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            [accumulatedString release];
#endif
            
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
            [touches release];
#endif
        }
        
        
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        bool input::canHandleEvent(vi::event::event *event)
        {
            return (event->type & eventTypeTouch);
        }
        
        void input::handleEvent(vi::event::event *event)
        {
            [touches release];
            
            vi::event::touchEvent *tEvent = (vi::event::touchEvent *)event;
            touchCount  = tEvent->touchCount;
            touches     = [tEvent->touches retain];
            
            event->raise(); // Re-Raise the event so other can catch it too
        }
        
        
        uint32_t input::getTouchCount()
        {
            return touchCount;
        }
        
        NSSet *input::getTouches()
        {
            return touches;
        }
#endif
        
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
        bool input::canHandleEvent(vi::event::event *event)
        {
            return (event->type & eventTypeKeyboard || event->type & eventTypeMouse);
        }
        
        void input::handleEvent(vi::event::event *event)
        {
            if(event->type == eventTypeKeyboard)
            {               
                vi::event::keyboardEvent *kEvent = (vi::event::keyboardEvent *)event;
                NSString *characters = [kEvent->wrappedEvent charactersIgnoringModifiers];
                
                if(kEvent->subtype == vi::event::keyboardEventTypeDown)
                {
                    if(kEvent->isRepeat == false)
                    {
                        downKeys ++;
                        inputKeyCodes.push_back(kEvent->keyCode);
                        [accumulatedString appendString:characters];
                    }
                }
                else
                {
                    downKeys --;
                    [accumulatedString replaceCharactersInRange:[accumulatedString rangeOfString:characters] withString:@""];
 
                    
                    std::vector<uint16_t>::iterator iterator;
                    for(iterator=inputKeyCodes.begin(); iterator!=inputKeyCodes.end(); iterator++)
                    {
                        uint16_t keyCode = *iterator;
                        if(keyCode == kEvent->keyCode)
                        {
                            inputKeyCodes.erase(iterator);
                            break;
                        }
                    }
                }
            }
            
            event->raise(); // Re-Raise the event so other can catch it too
        }
        
        
        bool input::anyKeyDown()
        {
            return (downKeys > 0);
        }
        
        bool input::isKeyDown(std::string const& key)
        {
            return ([accumulatedString rangeOfString:[NSString stringWithUTF8String:key.c_str()] options:NSCaseInsensitiveSearch].location != NSNotFound);
        }
        
        bool input::isKeyDown(uint16_t keyCode)
        {
            std::vector<uint16_t>::iterator iterator;
            for(iterator=inputKeyCodes.begin(); iterator!=inputKeyCodes.end(); iterator++)
            {
                if(*iterator == keyCode)
                    return true;
            }
            
            return false;
        }
        
        std::string input::getInputString()
        {
            const char *characters = [accumulatedString cStringUsingEncoding:NSASCIIStringEncoding];
            return (characters) ? std::string(characters) : std::string("");
        }
#endif
    }
}
