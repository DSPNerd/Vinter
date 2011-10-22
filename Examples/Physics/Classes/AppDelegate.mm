//
//  AppDelegate.m
//  Physics
//
//  Created by Sidney Just on 22.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    renderer = new vi::graphic::rendererOSX();
    camera = new vi::scene::camera(renderView);
    scene = new vi::scene::scene(camera);
    kernel = new vi::common::kernel(scene, renderer, [renderView context]);
    kernel->startRendering(30);
    
    texture = new vi::graphic::texture("Brick.png");
    sprite = new vi::scene::sprite(texture);
    sprite->enablePhysics();
    
    scene->addNode(sprite);
}

@end
