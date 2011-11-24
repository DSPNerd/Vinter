##Overview
Vinter is a Mac OS X and iOS graphic engine featuring full shader based rendering. The engine is mainly written in C++ with a few small parts written in Objective-C. It can be used in any Objective-C and C++ projects targeting iOS 3.0 or Mac OS X 10.6 and later. As the renderer only provides shader based rendering, the target system must support shaders (this requirement is probably met by every Mac that shipped with 10.5. iOS devices support shaders since the iPhone 3GS and iPod Touch 3rd Gen. It is also supported on every iPad).

The goal of the engine is to be as easy to use as possible, without being too bloated like other engines. We try to keep the API as clean as possible and we are working hard to add missing stuff (see the "missing stuff" section for more info).

##Features
- Shader based rendering
- OpenGL ES 2.0 rendering, OpenGL 2.0 rendering (GSlang 1.20) and OpenGL 3.2 rendering (GSlang 1.50, only on Mac OS X 10.7)
- Loading of assets in arbitrary background threads
- Tweening support similar to UIKits animation system
- Support for TMX maps <http://mapeditor.org/>
- Render to texture
- Flexible particle system
- Native Chipmunk support <http://chipmunk-physics.net/>
- PVR texture support (compressed and uncompressed)
- RGBA8888, RGBA4444, RGBA5551 and RGB565 texture format support with conversion
- Sprites (with and without atlas textures)
- Quadtree based scene management
- OpenGL ES debug marker support (iOS 5+)

##Demo Videos
- [Animations](http://www.youtube.com/watch?v=FeQbEP_Mpng "Demonstrating the animation system")
- [Particles](http://www.youtube.com/watch?v=8xYYvCu-DDM "Demonstrating the particle system")

##Missing stuff
Although there is support for physical nodes via the Chipmunk wrapper, there are some missing setters and getters and no wrapper for joints and constraints.
