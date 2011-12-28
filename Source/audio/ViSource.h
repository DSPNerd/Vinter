//
//  ViSource.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <vector>

#import "ViAudio.h"
#import "ViSound.h"
#import "ViVector2.h"
#import "ViVector3.h"

namespace vi
{
    namespace audio
    {
        class source
        {
        public:
            source(vi::audio::sound *sound);
            ~source();
            
            void setSound(vi::audio::sound *sound);
            
            void setPosition(vi::common::vector2 const& position);
            void setPosition(vi::common::vector3 const& position);
            
            void setLoops(bool loops);
            
            void play();
            void pause();
            void stop();
            void rewind();
            
            
        private:
            std::vector<vi::audio::sound *>sounds;
            ALuint _source;
        };
    }
}
