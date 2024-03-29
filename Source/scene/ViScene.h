//
//  ViScene.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <vector>

#import "ViBase.h"
#import "ViAudio.h"
#import "ViVector2.h"
#import "ViVector3.h"
#import "ViAnimationServer.h"

namespace vi
{
    namespace common
    {
        class quadtree;
        class rect;
    }
    
    namespace graphic
    {
        class renderer;
    }
    
    namespace scene
    {
        class sceneNode;
        class camera;
        
        /**
         * Structure holding information about hits of the scenes tracing functionality
         **/
        typedef struct
        {
            /**
             * The distance between the hit object and the starting point of the trace
             **/
            GLfloat distance;
            /**
             * The position, in world spcae, where the trace hit
             **/
            vi::common::vector2 position;
            /**
             * The node that was hit by the trace
             **/
            vi::scene::sceneNode *node;
        } hitInfo;
        
        
        /**
         * @brief A scene manages scene nodes for rendering
         **/
        class scene
        {
            friend class vi::scene::sceneNode;
        public:
            /**
             * Construcor for a scene. The minX, minY, maxX and maxY values are used to generate quadtree of this size for scene management.
             * The subdivisions is the number of subdivisions the quadtree is allowed make to partitionate the level,
             * this means for a 8192x8192 quadtree with 4 subdivions that the smalles patch is 2048x2048. You should try to not get smaller than roughly
             * one screen of the device you are targeting.
             **/
            scene(vi::scene::camera *camera=NULL, float minX=-4096, float minY=-4096, float maxX=4096, float maxY=4096, uint32_t subdivisions = 4);
            /**
             * Destructor, automatically destroy the quadtree with it, but keeps the objects in it alive.
             * If you want to delete the objects inside the scene along with the scene, call deleteAllNodes() first.
             **/
            ~scene();
            
            /**
             * Returns the scenes animation server.
             * @remark The animation server is bound to the engines framerate and most likely the one you want to use if you want to animate things.
             **/
            vi::animation::animationServer *getAnimationServer();
            
            
            /**
             * Adds the given camera to the render list.
             * @remark Only add cameras you want to get rendered as every camera requires the scene to be drawn again!
             **/
            void addCamera(vi::scene::camera *camera);
            /**
             * Removes the given camera from the render list.
             **/
            void removeCamera(vi::scene::camera *camera);
            /**
             * Returns a copy of the current camera list.
             **/
            std::vector<vi::scene::camera *> getCameras();
            
            
            /**
             * Adds the given node as UI node
             **/
            void addUINode(vi::scene::sceneNode *node);
            /**
             * Removes the given UI node
             **/
            void removeUINode(vi::scene::sceneNode *node);
            /**
             * Deletes all UI nodes.
             **/
            void deleteAllUINodes();
        
            
            /**
             * Adds the given scene node to the scene
             **/
            void addNode(vi::scene::sceneNode *node);
            /**
             * Removes the given scene node from the scene
             **/
            void removeNode(vi::scene::sceneNode *node);
            
            /**
             * Deletes all nodes, calling their destructors
             **/
            void deleteAllNodes();
            
            
            void activate(ALCdevice *device);
            void deactivate();
            
            
            /**
             * Returns the nodes inside the given rectangle.
             **/
            std::vector<vi::scene::sceneNode *> *nodesInRect(vi::common::rect const& rect);
            /**
             * Returns all nodes that should be rendered in screen space rather than in world space.
             **/
            std::vector<vi::scene::sceneNode *> *UINodes();
            
            /**
             * Updates the physical space and tells the renderer to render the scene with all cameras added to the scene.
             **/
            void draw(vi::graphic::renderer *renderer, double timestep);
            
            
            /**
             * Sends a line trace from the starting position to the end position and returns the first hit scene node.
             **/
            vi::scene::sceneNode *trace(vi::common::vector2 const& from, vi::common::vector2 const& to, uint32_t layer, hitInfo *info=NULL);
            /**
             * Returns the first node that intersects with the given rectangle.
             **/
            vi::scene::sceneNode *trace(vi::common::rect const& rect, uint32_t layer, hitInfo *info=NULL);
            
            
#ifdef ViPhysicsChipmunk
            /**
             * Sets the gravity of the scene
             * Default 0.0 | 100.0
             **/
            void setGravity(vi::common::vector2 const& gravity); 
            /**
             * Sets the damping of the scene
             * Default 1.0
             **/
            void setDamping(GLfloat damping);
            /**
             * Sets the collision slop of the physical space, this is the amount overlapping of nodes that is still allowed.
             * Default 0.1
             **/
            void setCollisionSlop(GLfloat slop);
            
            void pausePhysics();
            void unpausePhysics();
            
            /**
             * Enables spatial hashing for the physic scene.
             * Spatial hashing can speed up the collision detection and resolving if you have a scene with many equally sized nodes.
             * @remark Visit http://chipmunk-physics.net/release/ChipmunkLatest-Docs/#cpSpace-SpatialHash for more information about how to tune this
             **/
            void enableSpatialHash(GLfloat dimension, uint32_t count);
            
            /**
             * Returns the current gravity
             **/
            vi::common::vector2 getGravity();
            /**
             * Returns the current damping
             **/
            GLfloat getDamping();
            /**
             * Returns teh collision slop.
             **/
            GLfloat getCollisionSlop();
#endif
            
        private:            
            std::vector<vi::scene::camera *> *cameras;
            std::vector<vi::scene::sceneNode *>nodes;
            std::vector<vi::scene::sceneNode *>uiNodes;
            
            vi::animation::animationServer *animationServer;
            vi::common::quadtree *quadtree;
            
            ALCcontext *context;
            
#ifdef ViPhysicsChipmunk
            bool physicsPaused;
            
            double totalPhysicsTime;
            cpSpace *space;
#endif
        };
    }
}
