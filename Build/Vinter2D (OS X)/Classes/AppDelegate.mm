//
//  AppDelegate.mm
//  Vinter
//
//  Created by Sidney Just on 8/30/11.
//  Copyright 2011 by Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)handleEvent:(vi::event::renderEvent *)event
{
    if(event->subtype == vi::event::renderEventTypeWillDrawScene)
    {
        [window setTitle:[NSString stringWithFormat:@"Vinter2D (%.0f FPS)", 1.0 / event->timestep]];
        
        vi::common::vector2 pos = camera->frame.origin;
        vi::common::vector2 accel = vi::common::vector2(80 * (input.isKeyDown("d") - input.isKeyDown("a")), 
                                                        80 * (input.isKeyDown("s") - input.isKeyDown("w")));
        
        pos.x += round(accel.x * event->timestep);
        pos.y += round(accel.y * event->timestep);
        
        camera->frame.origin = pos;
        
        if(sprite)
            sprite->rotation += ViDegreeToRadian(15.0f * event->timestep);
    }
}


- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // ------------------------
    // Basic setup that must be done prior to any other Vinter operation.
    // We create a renderer, a camera which draws into our rendering view, a scene and a kernel
    // The kernel object basically glues everything together. We give it the same context as our rendering view as both operate on the same thread
    // ------------------------
    renderer = new vi::graphic::rendererOSX();
    camera = new vi::scene::camera(renderView);
    scene = new vi::scene::scene(camera);
    kernel = new vi::common::kernel(scene, renderer, [renderView context]);
    kernel->startRendering(30); // And then start the rendering
    
    dataPool = new vi::common::dataPool();
    
    dispatch_queue_t workQueue = dispatch_queue_create("com.widerwille.workqueue", NULL);
    dispatch_async(workQueue, ^{
        // ------------------------
        // This dispatch queue creates some data in a background thread, it demonstrates the basic principle of multithreaded Vinter usage
        // Every thread that wants to make a call to the Vinter API needs its own, activated vi::common::context instance. As we also want to share
        // the resources this context creates with the main context, we have to create a shared context by passing another context as the shared context.
        // ------------------------ 
        __block vi::graphic::texture *texture;
        
        vi::common::context *context = new vi::common::context([renderView context]); 
        context->activateContext();
        
        // Create texture and shaders
        texture = new vi::graphic::texture("Brick.png");
        
        // Its also possible to create sprites or other scene nodes in a background thread
        // However, please note that you can only add them to a scene on the main thread!
        sprite = new vi::scene::sprite(texture);
        sprite->mesh->generateVBO();
        sprite->layer = 2;
        
        delete context; // The context will automatically flush all the changes it made
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Add the sprite to the scene on the main thread.
            scene->addNode(sprite);
            
            dataPool->setAsset(texture, "brickTexture");
        });
    });
    
    
    
    bridge = vi::common::objCBridge(self, @selector(handleEvent:));
    listener.eventPredicate = vi::event::eventTypeRenderer;
    listener.eventCallback = std::tr1::bind(&vi::common::objCBridge::parameter1Action<vi::event::event *>, &bridge, std::tr1::placeholders::_1);}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    scene->deleteAllNodes(); // Delete all objects in the scene
    dataPool->removeAllAssets(true); // Delete all loaded assets
    
    delete kernel;
    delete scene;
    delete camera;
    delete dataPool;
}

@end
