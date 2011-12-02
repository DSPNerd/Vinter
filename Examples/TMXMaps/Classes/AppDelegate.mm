//
//  AppDelegate.mm
//  TMXMaps
//
//  Created by Sidney Just on 20.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (IBAction)loadOrthogonalMapAction:(id)sender
{
    if(tmxScene)
    {
        scene->removeNode(tmxScene);
        delete tmxScene;
    }
    
    tmxScene = new vi::scene::tmxNode("OrthogonalMap.tmx");
    scene->addNode(tmxScene);
}

- (IBAction)loadIsometricMapAction:(id)sender
{
    if(tmxScene)
    {
        scene->removeNode(tmxScene);
        delete tmxScene;
    }
    
    tmxScene = new vi::scene::tmxNode("IsometricMap.tmx");
    scene->addNode(tmxScene);
}



- (void)handleEvent:(vi::event::renderEvent *)event
{
    if(event->subtype == vi::event::renderEventTypeWillDrawScene)
    {
        [window setTitle:[NSString stringWithFormat:@"TMXMaps (%.0f FPS)", 1.0 / event->timestep]];
        
        vi::common::vector2 pos = camera->frame.origin;
        vi::common::vector2 accel = vi::common::vector2(80 * (input.isKeyDown("d") - input.isKeyDown("a")), 
                                                        80 * (input.isKeyDown("s") - input.isKeyDown("w")));
        
        pos.x += round(accel.x * event->timestep);
        pos.y += round(accel.y * event->timestep);
        
        camera->frame.origin = pos;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    renderer = new vi::graphic::rendererOSX();
    camera = new vi::scene::camera(renderView);
    scene = new vi::scene::scene(camera);
    kernel = new vi::common::kernel(scene, renderer, [renderView context]);
    kernel->startRendering(60);
    
    [self loadOrthogonalMapAction:self];
    
    bridge = vi::common::objCBridge(self, @selector(handleEvent:));
    listener.eventPredicate = vi::event::eventTypeRenderer;
    listener.eventCallback = std::tr1::bind(&vi::common::objCBridge::parameter1Action<vi::event::event *>, &bridge, std::tr1::placeholders::_1);
}

@end
