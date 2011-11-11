//
//  AppDelegate.h
//  Particles
//
//  Created by Sidney Just on 10.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Vinter.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
@private
    IBOutlet NSWindow *window;
    IBOutlet ViViewOSX *renderView;
    
    vi::common::kernel *kernel;
    vi::scene::camera *camera;
    vi::scene::scene *scene;
    vi::graphic::rendererOSX *renderer;
     
    vi::scene::baseParticleEffect effect;
    vi::scene::particleEmitter *emitter;
}

@end
