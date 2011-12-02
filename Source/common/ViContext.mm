//
//  ViContext.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <vector>
#import "ViContext.h"

namespace vi
{
    namespace common
    {
        // This mutex is used for atomic acces to the contextList, since the context class must be created and used from different threads, we need to make sure that
        // the context list is valid the whole time!
        static pthread_mutex_t contextMutex = PTHREAD_MUTEX_INITIALIZER; 
        static std::vector<vi::common::context *> contextList; // List containing all active contexts.
        
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
        NSOpenGLPixelFormat *contextCreatePixelFormat(GLuint glslVersion, GLuint *resultGlsl);
        NSOpenGLPixelFormat *contextCreatePixelFormat(GLuint glslVersion, GLuint *resultGlsl)
        {
            // This variable holds the actual used GLSL version.
            GLuint usedGlsl = 120;
            
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_7
            NSOpenGLPixelFormatAttribute attributes[] =
            {
                NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersionLegacy, // We start with the old OpenGL 2.0 profile and GLSL 1.20
                NSOpenGLPFADoubleBuffer,
                NSOpenGLPFAColorSize, 24,
                0
            };
            
            if(glslVersion == 150)
            {
                // If the user requested GLSL 1.50, we determine if the App is currently running on at least 10.7...
                SInt32 OSXversionMajor, OSXversionMinor;
                if(Gestalt(gestaltSystemVersionMajor, &OSXversionMajor) == noErr && Gestalt(gestaltSystemVersionMinor, &OSXversionMinor) == noErr)
                {
                    if(OSXversionMajor == 10 && OSXversionMinor >= 7)
                    {
                        // So it looks like the user is really running a Mac that supports the OpenGL 3.2 Core Profile, so we alter the attribute entry, replacing the
                        // OpenGL 2.0 entry:
                        attributes[0] = NSOpenGLPFAOpenGLProfile;
                        attributes[1] = NSOpenGLProfileVersion3_2Core;
                        
                        usedGlsl = 150; // Also mark that we are using GLSL 1.50
                    }
                }
            }
#else
            // Well, looks like we are on a old Mac OS X version, so we are forced to use the legacy profile:
            NSOpenGLPixelFormatAttribute attributes[] =
            {
                NSOpenGLPFADoubleBuffer,
                NSOpenGLPFAColorSize, 24,
                0
            };
#endif
            
            // Create the pixelformat
            NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
            assert(pixelFormat != NULL); // This should never fail...
            
            if(resultGlsl)
                *resultGlsl = usedGlsl;
            
            return [pixelFormat autorelease];
        }
#endif
        
        
        
        context::context(GLuint glslVersion)
        {
            // Set up everything for the context
            glsl    = glslVersion;
            active  = false;
            shared  = false;
            
            
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
            nativeContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
#endif
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            pixelFormat     = [vi::common::contextCreatePixelFormat(glslVersion, &glsl) retain]; // Request a new NSOpenGLPixelFormat which is appropriate for our use
            nativeContext   = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
#endif
        }
        
        context::context(vi::common::context *otherContext)
        {
            assert(otherContext);
            
            // Set up everything for the context
            glsl    = otherContext->glsl; // We use the same GLSL Version as our "parent"
            active  = false;
            shared  = true;
            sharedContext = otherContext;
            
            
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
            nativeContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:[otherContext->nativeContext sharegroup]];
#endif
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            pixelFormat     = [otherContext->pixelFormat retain]; // We also share the same pixel format as our "parent" context
            nativeContext   = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:otherContext->nativeContext];
#endif
        }
        
        
        context::~context()
        {
            deactivateContext(); // This flushes the context automatically
            
            // Delete all created shader objects.
            std::map<vi::graphic::defaultShader, vi::graphic::shader *>::iterator iterator;
            for(iterator=defaultShaders.begin(); iterator!=defaultShaders.end(); iterator++)
            {
                vi::graphic::shader *shader = (*iterator).second;
                delete shader;
            }
            
            
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            // We need to get rid of the pixel format, since we retained it to inherit it to shared contexts
            [pixelFormat release];
#endif
            [nativeContext release];
        }
        
        
        
        void context::activateContext()
        {
            if(!active)
            {
                // We are going to alter the context list, so we have to obtain the mutex in order to do this atomically!
                pthread_mutex_lock(&contextMutex);
                thread = pthread_self();
                
                std::vector<vi::common::context *>::iterator iterator;
                for(iterator=contextList.begin(); iterator!=contextList.end(); iterator++)
                {
                    vi::common::context *context = *iterator;                    
                    if(pthread_equal(context->thread, thread))
                    {
                        // This context was active on the thread we want to be active on now, so we deactiveate it now.
                        context->active = false;
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
                        if(context->shared)
                        {
                            // Disable the multithreaded OpenGL engine that was enabled before for the context.
                            CGLContextObj contextObj = (CGLContextObj)[nativeContext CGLContextObj];
                            CGLDisable(contextObj, kCGLCEMPEngine);
                        }
#endif
                        
                        contextList.erase(iterator);
                        break;
                    }
                }
                
                
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
                [EAGLContext setCurrentContext:nativeContext];
#endif
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
                [nativeContext makeCurrentContext];
                
                if(shared)
                {
                    // Enable the multithreaded OpenGL engine
                    CGLContextObj context = (CGLContextObj)[nativeContext CGLContextObj];
                    CGLEnable(context, kCGLCEMPEngine);
                }
#endif   
                
                
                // Lets add us to the currently active context list and mark us as active
                contextList.push_back(this);
                active = true;
                
                pthread_mutex_unlock(&contextMutex);
            }
        }
        
        void context::deactivateContext()
        {
            if(active)
            {
                // We are going to alter the context list, so we have to obtain the mutex in order to do this atomically!
                pthread_mutex_lock(&contextMutex);
                glFlush(); // Flush OpenGL buffer
                
                std::vector<vi::common::context *>::iterator iterator;
                for(iterator=contextList.begin(); iterator!=contextList.end(); iterator++)
                {
                    vi::common::context *context = *iterator;
                    if(context == this)
                    {
                        // Erase us from the context list
                        contextList.erase(iterator);
                        break;
                    }
                }
                
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
                if(shared)
                {
                    // If we are a shared context, we disable the multithread OpenGL engine now since we activated it before.
                    CGLContextObj context = (CGLContextObj)[nativeContext CGLContextObj];
                    CGLDisable(context, kCGLCEMPEngine);
                }
                
                // Disable the current context
                [NSOpenGLContext clearCurrentContext];
#endif  
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
                // Disable the current context
                [EAGLContext setCurrentContext:nil];
#endif
                
                active = false;
                pthread_mutex_unlock(&contextMutex);
            }
        }
        
        
        
        vi::common::context *context::getActiveContext()
        {
            // The operation must be done atomically since we iterate through the list of contexts and we must make sure that no other thread
            // alters its content, otherwise we might end up reading dead memory or worse...
            pthread_mutex_lock(&contextMutex); 
            
            pthread_t thread = pthread_self(); // this is the thread we are looking for!
            
            std::vector<vi::common::context *>::iterator iterator;
            for(iterator=contextList.begin(); iterator!=contextList.end(); iterator++)
            {
                vi::common::context *context = *iterator;
                if(pthread_equal(context->thread, thread))
                {
                    // We found a context that says that it is associated with the current thread, so we return it.
                    pthread_mutex_unlock(&contextMutex);
                    return context;
                }
            }
            
            // No context for you!
            pthread_mutex_unlock(&contextMutex);
            return NULL;
        }
        
        
        void context::flush()
        {
            if(active)
                glFlush();
        }
        
        
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        EAGLContext *context::getNativeContext()
        {
            return nativeContext;
        }
#endif
        
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
        NSOpenGLContext *context::getNativeContext()
        {
            return nativeContext;
        }
#endif
        
        GLuint context::getGLSLVersion()
        {
            return glsl;
        }
        
        vi::graphic::shader *context::getShader(vi::graphic::defaultShader type)
        {
            if(shared)
            {
                vi::graphic::shader *shader = sharedContext->getShader(type);
                glFlush(); // Make sure that the shader is really available 
                
                return shader;
            }
            
            
            // If the shader is already created, we return the cached shader
            std::map<vi::graphic::defaultShader, vi::graphic::shader *>::iterator iterator;
            iterator = defaultShaders.find(type);
            
            if(iterator != defaultShaders.end())
            {
                vi::graphic::shader *shader = (*iterator).second;
                return shader;
            }
            
            
            // Well, looks like the shader hasn't been requested yet. Lets create it!
            vi::graphic::shader *shader = new vi::graphic::shader(type);
            defaultShaders[type] = shader;
            
            return shader;
        }
    }
}
