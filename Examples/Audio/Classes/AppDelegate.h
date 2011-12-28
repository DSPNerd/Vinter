//
//  AppDelegate.h
//  Audio
//
//  Created by Sidney Just on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Vinter2D/Vinter.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
@private
    IBOutlet NSWindow  *window;
    IBOutlet ViViewOSX *renderView;
    
    vi::common::kernel *kernel;
    vi::scene::scene *scene;
    vi::scene::camera *camera;
    vi::graphic::rendererOSX *renderer;
}

@end
