//
//  AppDelegate.h
//  TMXMaps
//
//  Created by Sidney Just on 20.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Vinter2D/Vinter.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
@private
    IBOutlet NSWindow *window;
    IBOutlet ViViewOSX *renderView;
    
    vi::common::kernel *kernel;
    vi::scene::camera *camera;
    vi::scene::scene *scene;
    vi::graphic::rendererOSX *renderer;
    
    vi::scene::tmxNode *tmxScene;
    
    vi::event::eventListener listener;
    vi::event::input input;
    vi::common::objCBridge bridge;
}

- (IBAction)loadOrthogonalMapAction:(id)sender;
- (IBAction)loadIsometricMapAction:(id)sender;

@end
