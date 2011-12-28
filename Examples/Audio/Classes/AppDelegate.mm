//
//  AppDelegate.m
//  Audio
//
//  Created by Sidney Just on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    renderer = new vi::graphic::rendererOSX();
    camera   = new vi::scene::camera(renderView);
    scene    = new vi::scene::scene(camera);
    kernel   = new vi::common::kernel(scene, renderer, [renderView context]);
    
    kernel->startRendering(30);
    
    vi::audio::sound *test = new vi::audio::sound("audio.caf");
    vi::audio::source *source = new vi::audio::source(test);
    source->play();
}

@end
