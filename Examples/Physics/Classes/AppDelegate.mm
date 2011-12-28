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
    
    texture = new vi::graphic::texture("BlueBall.png");
    sprite = new vi::scene::sprite(texture);
    sprite->enablePhysics(vi::scene::sceneNodePhysicTypeCircle);
    sprite->setElasticity(0.3);
    sprite->setFriction(0.4);
    sprite->setMass(10.0);
    
    sprite->setInertia(sprite->suggestedInertia());
    sprite->applyImpulse(vi::common::vector2(5000.0f, 0.0f));
    
    scene->addNode(sprite);
    
    
    
    vi::scene::sceneNode *ground = new vi::scene::sceneNode();
    ground->setPosition(vi::common::vector2(-100.0f, 400.0f));
    ground->makeStaticObject(ground->getPosition(), vi::common::vector2(800.0f, 500.0f));
    ground->setFriction(0.8);
    ground->setElasticity(0.3);
    
    scene->addNode(ground);
    
    
    vi::scene::sceneNode *wall = new vi::scene::sceneNode();
    wall->setPosition(vi::common::vector2(600.0, 500.0));
    wall->makeStaticObject(wall->getPosition(), vi::common::vector2(600.0, 0.0));
    wall->setFriction(0.8);
    wall->setElasticity(0.4);
    
    scene->addNode(wall);
}

@end
