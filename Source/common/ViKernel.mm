//
//  ViKernel.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann Sidney Just. All rights reserved.
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
        kernel::kernel(vi::scene::scene *scene, vi::graphic::renderer *trenderer)
        {
            if(!trenderer)
                throw "Trying to create a kernel instance without providing a renderer which is an illegal configuration!";
            
            scenes = new std::vector<vi::scene::scene *>();
            cameras = new std::vector<vi::scene::camera *>();
            
            renderer = trenderer;
            timestep = 0.0;
            lastDraw = 0.0;
            
            timer = nil;
            bridge = nil;
            
            if(scene)
                this->pushScene(scene);
        }
        
        kernel::~kernel()
        {
            delete scenes;
            delete cameras;
            delete renderer;
            
            stopRendering();
        }
        
        
        
        void kernel::drawScene()
        {
            if(scenes->size() > 0 && renderer != NULL)
            {
                vi::input::event(this, vi::input::eventTypeRender | vi::input::eventTypeRenderWillDraw);
                vi::scene::scene *scene = scenes->back();
                
                std::vector<vi::scene::camera *>::iterator iterator;
                for(iterator=cameras->begin(); iterator!=cameras->end(); iterator++)
                {
                    vi::scene::camera *camera = *iterator;
                    renderer->renderSceneWithCamera(scene, camera);
                }
                vi::input::event(this, vi::input::eventTypeRender | vi::input::eventTypeRenderDidDraw);
            }
            
            double currentTime = [NSDate timeIntervalSinceReferenceDate];
            
            if(lastDraw >= kViEpsilonFloat)
                timestep = currentTime - lastDraw;
                
            lastDraw = currentTime;
        }
        
        void kernel::startRendering(uint32_t maxFPS)
        {
            stopRendering();
            
            bridge = [[ViCppBridge alloc] init];
            bridge.function0 = std::tr1::bind(&vi::common::kernel::drawScene, this);
            
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0/maxFPS target:bridge selector:@selector(parameter0Action) userInfo:nil repeats:YES];
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
                [bridge release];
                [timer invalidate];
                
                bridge = nil;
                timer = nil;
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
        
        
        
        void kernel::addCamera(vi::scene::camera *camera)
        {
            cameras->push_back(camera);
        }
        
        void kernel::removeCamera(vi::scene::camera *camera)
        {
            std::vector<vi::scene::camera *>::iterator iterator;
            for(iterator=cameras->begin(); iterator!=cameras->end(); iterator++)
            {
                vi::scene::camera *cam = *iterator;
                if(cam == camera)
                {
                    cameras->erase(iterator);
                    break;
                }
            }
        }
        
        
        std::vector<vi::scene::scene *> kernel::getScenes()
        {
            std::vector<vi::scene::scene *> scenesCopy = std::vector<vi::scene::scene *>(*scenes);
            return scenesCopy;
        }
        
        std::vector<vi::scene::camera *> kernel::getCameras()
        {
            std::vector<vi::scene::camera *> camerasCopy = std::vector<vi::scene::camera *>(*cameras);
            return camerasCopy;
        }
        
        vi::graphic::renderer *kernel::getRenderer()
        {
            return renderer;
        }
    }
}
