//
//  ViewController.mm
//  Vinter2D (iOS)
//
//  Created by Sidney Just on 06.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)handleRenderEvent:(vi::input::event *)event
{
    [fpsLabel setText:[NSString stringWithFormat:@"FPS: %.2f", 1/kernel->timestep]];
    
    if(sprite)
        sprite->rotation += ViDegreeToRadian(15.0f * kernel->timestep);
}

- (void)handleTouchEvent:(vi::input::event *)event
{
    if(event->type & vi::input::eventTypeTouchMoved)
    {
        UITouch *touch = [event->touches anyObject];
        
        vi::common::vector2 posThen = vi::common::vector2([touch previousLocationInView:event->view]);
        vi::common::vector2 posNow = vi::common::vector2([touch locationInView:event->view]);
        
        vi::common::vector2 diff = posNow - posThen;
        camera->frame.origin -= diff;
    }
}


- (void)handleEvent:(vi::input::event *)event
{
    if(event->type & vi::input::eventTypeTouch)
    {
        [self handleTouchEvent:event];
    }
    
    if(event->type & vi::input::eventTypeRender)
    {
        [self handleRenderEvent:event];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ------------------------
    // Basic setup that must be done prior to any other Vinter operation.
    // We create a renderer, a camera which draws into our rendering view, a scene and a kernel
    // The kernel object basically glues everything together. We give it the same context as our rendering view as both operate on the same thread
    // ------------------------
    renderer = new vi::graphic::rendererOSX();
    camera = new vi::scene::camera(renderView);
    scene  = new vi::scene::scene(camera);
    kernel = new vi::common::kernel(scene, renderer, [renderView context]);
    kernel->startRendering(30);
    
    dataPool = new vi::common::dataPool();
    
    
    // Set the default texture format, upon texture loading, vinter will try to convert the texture into this formart
    vi::graphic::texture::setDefaultFormat(vi::graphic::textureFormatRGBA5551);
    
    dispatch_queue_t workQueue = dispatch_queue_create("com.widerwille.workqueue", NULL);
    dispatch_async(workQueue, ^{
        // ------------------------
        // This dispatch queue creates some data in a background thread, it demonstrates the basic principle of multithreaded Vinter usage
        // Every thread that wants to make a call to the Vinter API needs its own, activated vi::common::context instance. As we also want to share
        // the resources this context creates with the main context, we have to create a shared context by passing another context as the shared context.
        // -------------------------
        __block vi::graphic::texturePVR *texture;
        
        vi::common::context *context = new vi::common::context([renderView context]); 
        context->activateContext();
        
        // Create texture and shaders
        texture = new vi::graphic::texturePVR("BrickC.pvr");
        
        // Its also possible to create sprites or other scene nodes in a background thread
        // However, please note that you can only add them to a scene on the main thread!
        sprite = new vi::scene::sprite(texture);
        sprite->mesh->generateVBO();
        
        delete context;

        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Add the sprite to the scene on the main thread.
            scene->addNode(sprite);
            
            // Also add the assets to the data pool on the main thread
            dataPool->setAsset(texture, "brickTexture");
        });
    });
    
    
    bridge = vi::common::objCBridge(self, @selector(handleEvent:));
    
    responder = new vi::input::responder();
    responder->callback = std::tr1::bind(&vi::common::objCBridge::parameter1Action<vi::input::event *>, &bridge, std::tr1::placeholders::_1);
    responder->touchMoved = true;
    responder->willDrawScene = true;
}


- (void)viewDidUnload
{
    // Free up everything we own
    scene->deleteAllNodes(); // Delete all objects in the scene
    dataPool->removeAllAssets(true); // Delete all loaded assets
    
    delete kernel;
    delete scene;
    delete camera;
    delete responder;
    delete dataPool;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
