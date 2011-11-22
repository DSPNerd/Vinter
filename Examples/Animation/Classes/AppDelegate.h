//
//  AppDelegate.h
//  Animation
//
//  Created by Sidney Just on 20.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Vinter.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
@private
    IBOutlet NSWindow  *window;
    IBOutlet ViViewOSX *renderView;
    
    vi::common::kernel *kernel;
    vi::scene::scene *scene;
    vi::scene::camera *camera;
    vi::graphic::rendererOSX *renderer;
    
    vi::scene::sprite *sprite;
    vi::scene::sprite *clock;
}

@end
