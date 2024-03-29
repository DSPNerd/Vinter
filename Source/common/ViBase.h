//
//  ViBase.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#endif

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
#endif

#ifdef __ARM_NEON__
#include <arm_neon.h>
#endif

#ifndef ViNoPhysics
    #define ViPhysicsChipmunk
#endif

#ifdef ViPhysicsChipmunk
#include "chipmunk.h"
#endif

#include <cstdlib>

/**
 * @defgroup ViBase Common used stuff
 * @{
 **/
/**
 * The current major release.
 **/
#define ViVersionMajor 0
/**
 * The current minor release.
 **/
#define ViVersionMinor 4
/**
 * The current patch release.
 **/
#define ViVersionPatch 0

/**
 * Returns the current version (major, minor and patch) as single integer.
 * @remark Vinter follows the SemVer standard, you can read more about this here http://semver.org/
 **/
#define ViVersionCurrent (((ViVersionMajor) << 16) | ((ViVersionMinor) << 8) | (ViVersionPatch))


/**
 * Macro to convert radians to degrees.
 **/
#define ViRadianToDegree(radians) (radians) * 180.0f / M_PI
/**
 * Macro to convert degrees to radians.
 **/
#define ViDegreeToRadian(degrees) (degrees) * M_PI / 180.0f


/**
 * Returns a random floating point number in the range of (- value * 0.5) to (value * 0.5)
 **/
#define ViRandom(value) (((((GLfloat)rand()) / RAND_MAX) * value) - value * 0.5)

#define ViDeprecated __attribute__((deprecated))
#define ViDeprecatedLog() do{static bool logged=false; if(!logged){ViLog(@"%s is deprecated! You can and should remove all calls to it.", __PRETTY_FUNCTION__); logged=true;}}while(0)
#define ViDeprecatedLogReplacement(replacement) do{static bool logged=false; if(!logged){ViLog(@"%s is deprecated! You can and should replace all calls to it with %@.", __PRETTY_FUNCTION__, replacement); logged=true;}}while(0)

/**
 * The epsilon value for float and double comparison
 **/
#define kViEpsilonFloat 0.0000000001f


#ifndef NDEBUG
#   define __ViLog(...) NSLog(__VA_ARGS__)
#else
#   define __ViLog(...) (void)0
#endif

/**
 * Logs strings similar to NSLog into the console. Unlike NSLog, ViLog does nothing in release builds.
 **/
#define ViLog __ViLog

/**
 * @}
 **/
