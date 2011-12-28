//
//  ViSound.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import "ViSound.h"
#import "ViDataPool.h"

namespace vi
{
    namespace audio
    {
        typedef ALvoid AL_APIENTRY (*alBufferDataStaticPtr)(const ALint bid, ALenum format, ALvoid *data, ALsizei size, ALsizei freq);
        
        sound::sound(std::string const& name)
        {
            PCMData = NULL;
            
            std::string path = vi::common::dataPool::pathForFile(name);
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:path.c_str()]];
            
            if(url)
            {
                ALsizei size, frequency;
                ALenum format;
                
                void *data = loadPCMData(url, &size, &format, &frequency);
                createFromData(data, size, format, frequency);
            }
        }
        
        sound::sound(NSURL *url)
        {
            PCMData = NULL;
            
            ALsizei size, frequency;
            ALenum format;
            
            void *data = loadPCMData(url, &size, &format, &frequency);
            createFromData(data, size, format, frequency);
        }
        
        sound::~sound()
        {
            alDeleteBuffers(0, &buffer);
            
            if(PCMData)
                free(PCMData);
        }
        
        
        
        void *sound::loadPCMData(NSURL *url, ALsizei *outSize, ALenum *outFormat, ALsizei *outFrequency)
        {
            ExtAudioFileRef					reference;
            AudioStreamBasicDescription		inputDescription;
            AudioStreamBasicDescription		outputDescription;
            
            OSStatus						status;	
            SInt64							lengthInFrames;
            UInt32							propertySize = sizeof(AudioStreamBasicDescription);
            
            
            ExtAudioFileOpenURL((CFURLRef)url, &reference);
            ExtAudioFileGetProperty(reference, kExtAudioFileProperty_FileDataFormat, &propertySize, &inputDescription);
            
            
            outputDescription.mSampleRate = inputDescription.mSampleRate;
            outputDescription.mChannelsPerFrame = inputDescription.mChannelsPerFrame;
            
            outputDescription.mFormatID = kAudioFormatLinearPCM;
            outputDescription.mBytesPerPacket = 2 * outputDescription.mChannelsPerFrame;
            outputDescription.mBytesPerFrame = 2 * outputDescription.mChannelsPerFrame;
            outputDescription.mFramesPerPacket = 1;
            outputDescription.mBitsPerChannel = 16;
            outputDescription.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
            
            ExtAudioFileSetProperty(reference, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), &outputDescription);
            ExtAudioFileGetProperty(reference, kExtAudioFileProperty_FileLengthFrames, &propertySize, &lengthInFrames);
            
            
            size_t size = lengthInFrames * outputDescription.mBytesPerFrame;
            void *data = malloc(size);
            if(data)
            {
                AudioBufferList buffer;
                buffer.mNumberBuffers = 1;
                buffer.mBuffers[0].mDataByteSize = (UInt32)size;
                buffer.mBuffers[0].mNumberChannels = outputDescription.mChannelsPerFrame;
                buffer.mBuffers[0].mData = data;
                
                status = ExtAudioFileRead(reference, (UInt32 *)&lengthInFrames, &buffer);
                if(status == noErr)
                {
                    if(outSize)
                        *outSize = (ALsizei)size;
                    
                    if(outFormat)
                        *outFormat = outputDescription.mChannelsPerFrame == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
                    
                    if(outFrequency)
                        *outFrequency = outputDescription.mSampleRate;
                }
                else
                {
                    free(data);
                    data = NULL;
                }
            }
            
            if(reference)
                ExtAudioFileDispose(reference);
            
            return data;
        }
        
        void sound::createFromData(void *data, size_t size, ALenum format, size_t frequency)
        {
            static bool staticBufferSupport = true;
            static alBufferDataStaticPtr staticBufferDataPtr = NULL;
            
            if(staticBufferSupport)
            {
                if(!staticBufferDataPtr)
                {
                    staticBufferDataPtr = (alBufferDataStaticPtr)alcGetProcAddress(NULL, (const ALCchar *)"alBufferDataStatic");
                    if(!staticBufferDataPtr)
                    {
                        staticBufferSupport = false;
                        createFromData(data, size, format, frequency);
                        return;
                    }
                }
                
                staticBufferDataPtr(buffer, format, data, (ALsizei)size, (ALsizei)frequency);
                PCMData = data; // Store the pointer for later disposal
            }
            else
            {
                alGenBuffers(1, &buffer);
                alBufferData(buffer, format, data, (ALsizei)size, (ALsizei)frequency);
                free(data);
            }
        }
    }
}
