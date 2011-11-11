//
//  AppDelegate.mm
//  Particles
//
//  Created by Sidney Just on 10.11.11.
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
    
    // Initiliaze the effect parameters
    effect = vi::scene::baseParticleEffect();
    effect.lifespan = 3.0;
    effect.randomLifespan = 2.0;
    effect.randomPosition = vi::common::vector2(30.0, 30.0);
    
    effect.speed = vi::common::vector2(0.0, 180.0);
    effect.randomSpeed = vi::common::vector2(40.0, 90.0); // Allow the particles to fan out a bit
    
    effect.targetSpeed = vi::common::vector2(0.0, 80.0);

    effect.color = vi::graphic::color(0.647, 0.006, 0.180, 1.0);
    effect.targetColor = vi::graphic::color(0.035, 0.044, 0.647, 1.0);
    
    
    
    // Create a template particle
    vi::scene::baseParticle *particle = new vi::scene::baseParticle(&effect);
    
    // Create the emitter, tell it to spawn the particle over and over again and then add it to the scene.
    vi::graphic::texture *texture = new vi::graphic::texture("Particle.png");
    emitter = new vi::scene::particleEmitter(texture);
    emitter->setPosition(vi::common::vector2(200.0, 400.0));
    emitter->autoEmitParticle(particle, 5, 800);
    
    scene->addNode(emitter);
}

@end
