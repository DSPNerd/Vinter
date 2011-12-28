//
//  ViSource.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViSource.h"

namespace vi
{
    namespace audio
    {
        source::source(vi::audio::sound *sound)
        {
            alGenSources(0, &_source);
            setSound(sound);
        }
        
        source::~source()
        {
            alDeleteSources(0, &_source);
        }
        
        
        void source::setSound(vi::audio::sound *sound)
        {
            alSourcei(_source, AL_BUFFER, sound->buffer);
        }
        
        
        void source::setPosition(vi::common::vector2 const& position)
        {
            float positionAL[] = {position.x, 0.0f, position.y};
            alSourcefv(_source, AL_POSITION, positionAL);
        }
        
        void source::setPosition(vi::common::vector3 const& position)
        {
            float positionAL[] = {position.x, position.z, position.y};
            alSourcefv(_source, AL_POSITION, positionAL);
        }
        
        
        void source::setLoops(bool loops)
        {
            alSourcei(_source, AL_LOOPING, loops ? AL_TRUE : AL_FALSE);
        }
        
        
        void source::play()
        {
            alSourcePlay(_source);
        }
        
        void source::pause()
        {
            alSourcePause(_source);
        }
        
        void source::stop()
        {
            alSourceStop(_source);
        }
        
        void source::rewind()
        {
            alSourceRewind(_source);
        }
    }
}

