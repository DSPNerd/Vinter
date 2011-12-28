//
//  ViSound.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import <Foundation/Foundation.h>
#include <string>

#import "ViAudio.h"
#import "ViAsset.h"

namespace vi
{
    namespace audio
    {
        class source;
        
        class sound : public vi::common::asset
        {
            friend class source;
        public:
            sound(std::string const& name);
            sound(NSURL *url);
            ~sound();
            
        private:
            void *loadPCMData(NSURL *url, ALsizei *outSize, ALenum *outFormat, ALsizei *outFrequency);
            void createFromData(void *data, size_t size, ALenum format, size_t frequency);
            
            void *PCMData;
            ALuint buffer;
        };
    }
}
