//
//  Vinter.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#ifndef VINTER_H_
#define VINTER_H_

#import "ViBase.h"
#import "ViAsset.h"
#import "ViDataPool.h"
#import "ViXML.h"

#import "ViVector2.h"
#import "ViVector3.h"
#import "ViRect.h"
#import "ViLine.h"
#import "ViMatrix4x4.h"
#import "ViQuadtree.h"
#import "ViConstraint.h"

#import "ViKernel.h"
#import "ViContext.h"
#import "ViScene.h"
#import "ViSceneNode.h"
#import "ViSprite.h"
#import "ViSpriteFactory.h"
#import "ViSpriteBatch.h"
#import "ViTMXNode.h"
#import "ViTMXLayer.h"
#import "ViParticleEmitter.h"
#import "ViParticle.h"

#import "ViAnimation.h"
#import "ViAnimationStack.h"
#import "ViAnimationServer.h"

#import "ViAudio.h"
#import "ViSound.h"
#import "ViSource.h"

#import "ViTexture.h"
#import "ViTexturePVR.h"
#import "ViColor.h"
#import "ViMesh.h"

#import "ViEvent.h"
#import "ViEventListener.h"
#import "ViInput.h"
#import "ViBridge.h"

#import "ViRenderer.h"
#import "ViRendererOSX.h"

#import "ViViewProtocol.h"
#import "ViViewOSX.h"
#import "ViViewiOS.h"

/**
 * Main namespace containing all other namespaces proved by Vinter.
 **/
namespace vi
{
    /**
     * Namespace containing the animation system
     **/
    namespace animation
    {
    }
    /**
     * Common namespace containing common used classes and data structures
     **/
    namespace common
    {
    }
    /**
     * Namespace containing the event system
     **/
    namespace event
    {
    }
    /**
     * Namespace which contains graphic related classes
     **/
    namespace graphic
    {
    }
    /**
     * Namespace containing objects that are visible or build a scene
     **/
    namespace scene
    {
    }
}

#endif


/** 
 * @mainpage Vinter API reference
 * <img src="http://vinter2d.org/stuff/logo.png" align="center" alt="Logo"/>
 * <div align="center"><a href="http://vinter2d.org">Project home</a></div>
 *
 * @section intro_sec Introduction
 * This is the Vinter API reference, it is generated based on Vinter 0.4.0.<br />
 * If you are new to Vinter, head over to the <a href="http://vinter2d.org/viki/">wiki</a> and read the tutorials or look into the example projects in the Vinter source directory.
 * <br /><br />
 * @subpage changelog
 * <br /><br />
 * @subpage license
 **/

/**
 * @page changelog Changelog
 * <b>Version 0.4.0</b><br />
 * Added chipmunk support<br />
 * Added support for animations<br />
 * Added tracing functions into the scene, vi::scene::scene::trace()<br />
 * Added support to render nodes in UI space rathern than in world space<br />
 * Added support for OpenGL debug markers (only in debug builds, vi::scene::sceneNode::setDebugName())<br />
 * Added a flag for scene nodes that tells the renderer that it can batch the nodes child into one mesh for faster rendering<br />
 * Added support for colored meshes via the vi::common::meshRGBA class<br />
 * Added support for custom vertex attributes for shaders<br />
 * Added support for particles via the vi::scene::particleEmitter and vi::scene::particle classes<br />
 * Added a concrete particle subclass, vi::scene::baseParticle, that allows basic particle effects<br />
 * Added new constructors for sprites to allow creation of sprites with a shared material<br />
 * Added the possibility to directly write atlas information of sprites into the mesh<br />
 * Added a new default shader for particles<br />
 * Changed the behavior of adding custom material attributes (aka uniforms), instead of readding a new uniform the material now updates the old one.<br />
 * Refactored the mesh class so that it supports vertex colors.<br />
 * Refactored the event system and moved it from the input to the newly created event namespace<br />
 * Moved the color class from the graphic to the common namespace (you can do a quick search&replace to update your code!)<br />
 * Moved the renderer and rendererOSX files physically from the scene folder to the graphic folder, no namespace change.<br />
 * Removed the ViTriangulate and ViShape classes<br />
 * <br />
 * <br />
 * <b>Version 0.3.0</b><br />
 * Added multithreading support via the vi::common::context class<br />
 * Added the vi::common::dataPool class for storing assets.<br />
 * Added support for TMX maps.<br />
 * Added the vi::scene::spriteBatch class that allows you to create large sprite batches<br />
 * Added a special sprite shader that can render all sprites from a single VBO, even with different atlas informations.<br />
 * Added a macros to get the current Vinter version.<br />
 * Added macros to convert radian to degree and vice versa (ViRadianToDegree() and ViDegreeToRadaian())
 * Added custom meshes (vertices, indices) via the vi::common::mesh class<br />
 * Added a dynamic flag for scene nodes<br />
 * Extended and rewrote parts of the documentation<br />
 * Extended the vi::common::color class.<br />
 * Changed the vi::common::matrix4x4 class to use much faster NEON optimized matrix multiplication.<br />
 * Changed the Sprite class to allow setting a atlas for shared meshes.<br />
 * Changed the rotation of scene nodes so that the node now rotates around the center of itself.<br />
 * Changed the rotation property of scene nodes from degree to radian<br />
 * Fixed a bug in the shader class which prevented it from cleaning up memory upon deletion.<br />
 * Fixed the ViLog Macro<br />
 * Fixed the ViQuadtree.h and .mm location (was scene, is now common)<br />
 * Fixed a bug where vi::graphic::texturePVR would load more mipmaps than it allocates memory <br />
 * Removed the quaternion und vector4 classes since they aren't used anymore<br />
 * <br />
 * <br />
 * <b>Version 0.2.5</b><br />
 * Added rendering via a CADisplayLink (iOS only). The engine will use CADisplayLink instead of NSTimer unless the engine runs on iOS 3.0.
 * <br />
 * <br />
 * <b>Version 0.2.4</b><br />
 * Added support for childs for scene nodes. (see vi::scene::sceneNode)<br />
 * Added a sprite factory class that allows creating multiple sprites which share the same mesh<br />
 * Added caching for VBOs in the renderer<br />
 * Added some helper functions into the kernel and color class<br />
 * Changed the way quadtrees and the scene class return data (they now use a pointer instead of returning the results on the stack)<br />
 * Fixed two state bugs in the renderer which may resulted in non switched textures and blend modes.<br />
 * <br />
 * <br />
 * <b>Version 0.2.3</b><br />
 * Added support for PVR textures (both compressed and uncompressed)<br />
 * Added a function for getting pathes for files that respects naming conventions like @2x and ~ipad<br />
 * <br />
 * <br />
 * <b>Version 0.2.2</b><br />
 * Added support for RGBA 4444, RGBA 5551 and RGB 565 texture formats.<br />
 * <br />
 * <br />
 * <b>Version 0.2.1</b><br />
 * Added documentation for the vi::scene, vi::graphic and vi::input namespace<br />
 * Added a scale factor variable into texture and kernel<br />
 * Fixed retina display rendering bugs<br />
 * <br />
 * <br />
 * <b>Version 0.1</b><br />
 * Initial version.<br />
 * <br />
 * <br />
 **/

/**
 * @page license License
 * Copyright (c) 2011 by Nils Daumann and Sidney Just<br />
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated <br />
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation <br />
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, <br />
 * and to permit persons to whom the Software is furnished to do so, subject to the following conditions:<br />
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.<br />
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, <br />
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR <br />
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE <br />
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, <br />
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.<br />
 **/

