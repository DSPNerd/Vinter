//
//  ViKernel.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <tr1/functional>
#import "ViKernel.h"
#import "ViRenderer.h"
#import "ViEvent.h"

namespace vi
{
    namespace common
    {
        static kernel *_sharedKernel = NULL;
        
        kernel::kernel(vi::scene::scene *scene, vi::graphic::renderer *trenderer, vi::common::context *tcontext)
        {
            ViLog(@"Running Vinter v%i.%i.%i:%i", ViVersionMajor, ViVersionMinor, ViVersionPatch, ViVersionCurrent);
            ViLog(@"Prepare for dragons!");
            
            if(!trenderer)
                throw "Trying to create a kernel instance without providing a renderer which is an illegal configuration!";
            
            srand((unsigned int)time(NULL));
            scenes = new std::vector<vi::scene::scene *>();
            
            ownsContext = false;
            context = tcontext;
            renderer = trenderer;
            
            timestep = 0.0;
            lastDraw = 0.0;
            scaleFactor = 1.0f;
            
            timer = nil;
            bridge = nil;
            _sharedKernel = this;
            
            if(scene)
            {
                this->pushScene(scene);
                std::vector<vi::scene::camera *> cameras = scene->getCameras();
                std::vector<vi::scene::camera *>::iterator iterator;
                
                for(iterator=cameras.begin(); iterator!=cameras.end(); iterator++)
                {
                    vi::scene::camera *camera = *iterator;
                    if(camera->view)
                    {
                        scaleFactor = [camera->view contentScaleFactor];
                        break;
                    }
                }
            }
            
            if(!context)
            {
                context = new vi::common::context();
                ownsContext = true;
            }
            
            context->activateContext();
        }
        
        kernel::~kernel()
        {
            stopRendering();
            
            delete scenes;
            delete renderer;
            
            if(ownsContext)
                delete context;
            
            if(_sharedKernel == this)
                _sharedKernel = NULL;
        }
        
        
        
        
        
        vi::common::kernel *kernel::sharedKernel()
        {
            return _sharedKernel;
        }
        
        
        bool kernel::checkForExtension(std::string openglExtension)
        {
            std::string extensions((const char *)glGetString(GL_EXTENSIONS));
            return (extensions.rfind(openglExtension) != std::string::npos);
        }
        
        void kernel::drawScene()
        {
            vi::event::renderEvent event = vi::event::renderEvent(vi::event::renderEventTypeWillBeginRendering, NULL, this);
            event.timestep = timestep;
            event.raise();
            
            if(scenes->size() > 0 && renderer != NULL)
            {
                vi::scene::scene *scene = scenes->back();
                scene->draw(renderer, timestep);
            }
            
            
            double currentTime = [NSDate timeIntervalSinceReferenceDate];
            
            if(lastDraw >= kViEpsilonFloat)
                timestep = currentTime - lastDraw;
                
            lastDraw = currentTime;
            
            event = vi::event::renderEvent(vi::event::renderEventTypeDidFinishRendering, NULL, this);
            event.timestep = timestep;
            event.raise();
        }
        
        void kernel::startRendering(uint32_t maxFPS)
        {
            stopRendering();
            
            bridge = [[ViCppBridge alloc] init];
            bridge.function0 = std::tr1::bind(&vi::common::kernel::drawScene, this);
            
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
            if([CADisplayLink class])
            {
                timer = [CADisplayLink displayLinkWithTarget:bridge selector:@selector(parameter0Action)];
                [timer setFrameInterval:floor((1.0f / maxFPS) * 60.0f)];
                [timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            }
            else
                timer = [NSTimer scheduledTimerWithTimeInterval:1.0/maxFPS target:bridge selector:@selector(parameter0Action) userInfo:nil repeats:YES];
#endif
            
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0/maxFPS target:bridge selector:@selector(parameter0Action) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
#endif
        }
        
        void kernel::madeSignificantTimeChange()
        {
            lastDraw = 0.0f;
            timestep = 0.0f;
        }
        
        void kernel::stopRendering()
        {
            if(timer)
            {
                [timer invalidate];
                [bridge release];
                
                timer = nil;
                bridge = nil;
            }
        }
        
        
        
        void kernel::pushScene(vi::scene::scene *scene)
        {
            if(!scene)
            {
                this->popScene();
                return;
            }
            
            scenes->push_back(scene);
        }
        
        void kernel::popScene()
        {
            scenes->pop_back();
        }
        
        
        
        
        void kernel::setContext(vi::common::context *tcontext)
        {
            if(ownsContext)
                delete context;
            
            context = tcontext;
            ownsContext = false;
        }
        
        vi::common::context *kernel::getContext()
        {
            return context;
        }
        
        void kernel::checkError()
        {
#ifndef NDEBUG
            GLenum error = glGetError();
            if(error == GL_NO_ERROR)
                return;
            
            switch(error)
            {
                case GL_INVALID_ENUM:
                    ViLog(@"GL_INVALID_ENUM error raised. (An unacceptable value is specified for an enumerated argument.)");
                    break;
                    
                case GL_INVALID_VALUE:
                    ViLog(@"GL_INVALID_VALUE error raised. (A numeric argument is out of range.)");
                    break;
                   
                case GL_INVALID_OPERATION:
                    ViLog(@"GL_INVALID_OPERATION error raised. (The specified operation is not allowed in the current state.)");
                    break;
                    
#ifdef GL_STACK_OVERFLOW
                case GL_STACK_OVERFLOW:
                    ViLog(@"GL_STACK_OVERFLOW error raised. (A command would cause a stack overflow so it was ignored.)");
                    break;
#endif
                    
#ifdef GL_STACK_UNDERFLOW
                case GL_STACK_UNDERFLOW:
                    ViLog(@"GL_STACK_UNDERFLOW error raised. (A command would cause a stack underflow so it was ignored.)");
                    break;
#endif
                    
                case GL_OUT_OF_MEMORY:
                    ViLog(@"GL_OUT_OF_MEMORY error raised. (There is not enough memory left to execute the command.)");
                    ViLog(@"OpenGL is in an undefined state now, prepare, here be dragons!");
                    break;
                    
                default:
                    break;
            }
#endif
        }
        
        
        std::vector<vi::scene::scene *> kernel::getScenes()
        {
            std::vector<vi::scene::scene *> scenesCopy = std::vector<vi::scene::scene *>(*scenes);
            return scenesCopy;
        }
        
        vi::graphic::renderer *kernel::getRenderer()
        {
            return renderer;
        }
    }
}
