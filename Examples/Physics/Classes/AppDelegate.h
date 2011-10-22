//
//  AppDelegate.h
//  Physics
//
//  Created by Sidney Just on 22.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Vinter.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSWindow *window;
    IBOutlet ViViewOSX *renderView;
    
    vi::common::kernel *kernel;
    vi::scene::camera *camera;
    vi::scene::scene *scene;
    vi::graphic::rendererOSX *renderer;
    
    vi::graphic::texture *texture;
    vi::scene::sprite *sprite;
}

@end
