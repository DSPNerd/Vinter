//
//  ViViewOSX.m
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
#import "ViBase.h"
#import "ViViewOSX.h"
#import "ViEvent.h"
#import "ViKernel.h"

@implementation ViViewOSX
@synthesize allowsCoreProfile;

- (vi::common::context *)context
{
    return context;
}

- (CGSize)size
{
    return [self bounds].size;
}

- (CGFloat)contentScaleFactor
{
    return 1.0;
}

#pragma mark -
#pragma mark Render events

- (void)bind
{
    context->activateContext();
}

- (void)unbind
{
    [context->getNativeContext() flushBuffer];
}

- (void)setAllowsCoreProfile:(BOOL)allows
{
    if(allowsCoreProfile != allows)
    {
        delete context;
        context = new vi::common::context(allows ? 150 : 120);
        context->activateContext();
        
        [self setOpenGLContext:context->getNativeContext()];
    }
}

#pragma mark -
#pragma mark Constructor / Destructor


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        context = new vi::common::context();
        context->activateContext();
        
        [self setOpenGLContext:context->getNativeContext()];
    }
    
    return self;
}

- (id)initWithFrame:(NSRect)frame pixelFormat:(NSOpenGLPixelFormat *)pixelFormat
{
    if((self = [super initWithFrame:frame pixelFormat:pixelFormat]))
    {
        context = new vi::common::context();
        context->activateContext();
        
        [self setOpenGLContext:context->getNativeContext()];
    }
    
	return self;
}

- (id)initWithFrame:(NSRect)frame
{
	return [self initWithFrame:frame pixelFormat:nil];
}

- (void)dealloc
{
    delete context;
    [super dealloc];
}

#pragma mark -
#pragma mark Input

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    vi::event::keyboardEvent event = vi::event::keyboardEvent(theEvent, vi::event::keyboardEventTypeDown);
    event.raise();
}

- (void)keyUp:(NSEvent *)theEvent
{
    vi::event::keyboardEvent event = vi::event::keyboardEvent(theEvent, vi::event::keyboardEventTypeUp);
    event.raise();
}


- (void)mouseDown:(NSEvent *)theEvent
{
    vi::event::mouseEvent event = vi::event::mouseEvent(theEvent, vi::event::mouseEventTypeDown);
    event.raise();
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    vi::event::mouseEvent event = vi::event::mouseEvent(theEvent, vi::event::mouseEventTypeDragged);
    event.raise();
}

- (void)mouseUp:(NSEvent *)theEvent
{
    vi::event::mouseEvent event = vi::event::mouseEvent(theEvent, vi::event::mouseEventTypeUp);
    event.raise();
}

@end
#endif
