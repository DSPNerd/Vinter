//
//  ViEventListener.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViEventListener.h"

namespace vi
{
    namespace event
    {
        static std::vector<eventListener *> listener;
        
        
        eventListener::eventListener()
        {
            listener.push_back(this);
            eventPredicate = 0;
        }
        
        eventListener::~eventListener()
        {
            std::vector<eventListener *>::iterator iterator;
            for(iterator=listener.begin(); iterator!=listener.end(); iterator++)
            {
                eventListener *tlistener = *iterator;
                if(tlistener == this)
                {
                    listener.erase(iterator);
                    break;
                }
            }
        }
        
        
        
        bool eventListener::canHandleEvent(vi::event::event *event)
        {
            return (event->type & eventPredicate);
        }
        
        void eventListener::handleEvent(vi::event::event *event)
        {
            if(eventCallback)
                eventCallback(event);
        }
        
        
        std::vector<eventListener *> *eventListener::getListenerVector()
        {
            return &listener;
        }
    }
}
