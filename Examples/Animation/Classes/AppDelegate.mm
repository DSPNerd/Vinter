//
//  AppDelegate.mm
//  Animation
//
//  Created by Sidney Just on 20.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    renderer = new vi::graphic::rendererOSX();
    camera   = new vi::scene::camera(renderView);
    scene    = new vi::scene::scene(camera);
    kernel   = new vi::common::kernel(scene, renderer, [renderView context]);
    
    kernel->startRendering(30);
    
    sprite = new vi::scene::sprite(new vi::graphic::texture("Brick.png"));
    clock = new vi::scene::sprite(new vi::graphic::texture("Clock.png"));
    clock->setPosition(vi::common::vector2(0.0, 256.0));
    clock->layer = 2; // Render the clock above the sprite
    
    scene->addNode(sprite);
    scene->addNode(clock);
    

    // The animation server runs our animation, for convinience reasons, the scene already has a animation server for us that is synced with the framerate.
    vi::animation::animationServer *server;
    server = scene->getAnimationServer();
    
    // Build the sprite animation
    vi::animation::animationStack *stack = server->beginAnimation();
    stack->setRepeatCount(ViAnimationRepeatIndefinitely); // The animation should repeat endless
    stack->setAutoreverses(true); // And every second run should be reverse
    stack->setAnimationDuration(2.0);
    stack->setAnimationCurve(vi::animation::animationCurveExponentialEaseIn); // Accelerate exponetially from 0 velocity to the target velocity
    
    // Tell the animation system where we want the sprite to be positioned at the end of the animation path
    sprite->setPosition(vi::common::vector2(512.0, 512.0) - sprite->getSize());
    sprite->setRotation(ViDegreeToRadian(90.0));
    
    // We are done building the animation, lets communicate that with the animation server:
    server->commitAnimation();
    
    
    // Build the clock animation
    stack = server->beginAnimation();
    stack->setRepeatCount(ViAnimationRepeatIndefinitely);
    
    // The clock arm animation is special in a way that it uses an animation path, each path rotates the arm by 6° (360° / 60 seconds)
    for(int i=1; i<=60; i++)
    {
        clock->setRotation(i * ViDegreeToRadian(360.0 / 60.0));
        stack->addPath(); // Add a new path to the animation
    }
    
    // Ugly hack to set the clocks arm rotation back to 0.0 without a 360° CCW rotation, so that the animation can be repeated nicely.
    stack->setAnimationDuration(0.0);
    clock->setRotation(0);
    
    server->commitAnimation();
}

@end
