//
//  ViInput.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViEvent.h"
#import "ViEventListener.h"

namespace vi
{
    namespace event
    {
        class input : public vi::event::eventListener
        {
        public:
            input();
            virtual ~input();
            
            virtual bool canHandleEvent(vi::event::event *event);
            virtual void handleEvent(vi::event::event *event);
            
            
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
            uint32_t getTouchCount();
            NSSet *getTouches();
#endif
            
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            bool anyKeyDown();
            bool isKeyDown(std::string const& key);
            bool isKeyDown(uint16_t keyCode);
            
            std::string getInputString();
#endif
            
        private:          
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
            uint32_t touchCount;
            NSSet *touches;
#endif
            
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            int32_t downKeys;
            
            NSMutableString *accumulatedString;
            std::vector<uint16_t> inputKeyCodes;
#endif
        };
    }
}
