//
//  ViEventListener.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <tr1/functional>
#include <vector>
#import "ViEvent.h"

namespace vi
{
    namespace event
    {
        class eventListener
        {
            friend class event;
        public:
            eventListener();
            virtual ~eventListener();
            
            virtual bool canHandleEvent(vi::event::event *event);
            virtual void handleEvent(vi::event::event *event);
            
            
            std::tr1::function<void (vi::event::event *)> eventCallback;
            uint32_t eventPredicate;
            
        private:
            static std::vector<eventListener *> *getListenerVector();
        };
    }
}
