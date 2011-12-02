//
//  ViContext.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <pthread.h>
#include <map>
#import "ViBase.h"
#import "ViShader.h"

namespace vi
{
    namespace common
    {
        /**
         * @brief A per thread object managing an OpenGL (ES) context.
         * @details <p>The context class is the key class for multithreading in Vinter. Each context manages its own OpenGL (ES) state that is used whenever you create or
         * use assets, eg. by creating a texture or drawing into a framebuffer. When you issue a OpenGL command, either directly, or through Vinter, the context that
         * is associated with the current thread is used to execute the command. This also means that you need one context per thread that wants to issue OpenGL commands!</p>
         * <p>By default a new context isn't associated with any other living context, this means that the new context manages its own OpenGL (ES) state.
         * However, in most cases, you want to create a new context to load/create new assets in a background thread and then use them in the mainthread to draw your scene
         * or do some other stuff. To allow this, the context class allows you to create a new context that shares its data, eg. texture, shadre programs etc, with
         * another context. This way you can use the context class to load assets in a background thread</p>
         **/
        class context
        {
            friend class vi::graphic::shader;            
        public:
            /**
             * @brief Constructor
             * @details Constructor for a context which doesn't share its data with another context.
             * @param glslVersion The desired GSlang version you want, without the dot. Eg. 120 for GLSL 1.20. Currently supported are 120 and 150 (10.7 only!).
             * @remark The passed GLSL Version is just a hint for the context, if the desired version isn't available, the context will fallback to a working version.
             * @note Only Mac OS X makes use of the GLSL Version, on iOS the passed version is ignored.
             **/
            context(GLuint glslVersion=120);
            /**
             * @brief Constructor for a shared context
             * @details Creates a new context that shares data with the given context
             * @param otherContext The context that the new context should share data with. Must not be NULL!
             **/
            context(vi::common::context *otherContext);
            /**
             * @brief Destructor
             * @details Automatically deactivates and flushes the current context.
             * @see deactivateContext();
             * @see flush();
             **/
            ~context();
            
            
            /**
             * @brief Activates the context for the current thread.
             * @details Activating a context makes the context the current context of the calling thread, any following OpenGL (ES) command on this thread will be 
             * executed by the current context.
             * @see deactivateContext();
             **/
            void activateContext();
            /**
             * @brief Deactivates the previously activated context.
             * @details Deactivates the context if it was the current context of the calling thread. Automatically flushes the context.
             * @see flush();
             **/
            void deactivateContext();
            
            
            
            /**
             * @brief Flushes the current context.
             * @details OpenGL (ES) buffers some issued commands for speed reasons, that means that a OpenGL (ES) command might return even if it hasn't performed
             * the actual operation yet. Normally this is not a problem because if you issue a command that depends on the state of a buffered operation, the buffer is
             * first emptied to make sure that the new OpenGL (ES) operation operates correct. However, when you are working with multiple contexts, you must flush
             * the buffer in order to make everything available for the other context. For example, if you create a second context which creates some textures,
             * you must flush the context before accessing the textures on the first context.
             **/
            void flush();
            
            
            /**
             * @brief Returns the GLSL Version of the context.
             * @result The GLSL Version of the context.
             * @note Only useful on OS X, since iOS doesn't support multiple GLSL Versions.
             **/
            GLuint getGLSLVersion();
            
            /**
             * @brief Returns a shared shader object.
             * @details This function creates and returns a shared shader object that can be used when working with the context.
             * @note The shader is owned by the context and must not be deleted!
             **/
            vi::graphic::shader *getShader(vi::graphic::defaultShader shader);
            
            
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
            /**
             * @brief Returns the native EAGLContext object used by the context
             **/
            EAGLContext *getNativeContext();
#endif
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            /**
             * @brief Returns the native NSOpenGLContext object used by the context.
             **/
            NSOpenGLContext *getNativeContext();
#endif
            
            
            /**
             * @brief Returns the active context of the calling thread.
             * @result The active context of the calling thread or NULL if the thread doesn't have a context.
             **/
            static vi::common::context *getActiveContext();
            
        private:            
            bool active;
            bool shared;
            
            pthread_t   thread;
            context     *sharedContext;
            
            GLuint glsl; // Only used on OS X
            std::map<vi::graphic::defaultShader, vi::graphic::shader *> defaultShaders;
            
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
            EAGLContext *nativeContext;
#endif
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            NSOpenGLContext *nativeContext;
            NSOpenGLPixelFormat *pixelFormat;
#endif
        };
    }
}
