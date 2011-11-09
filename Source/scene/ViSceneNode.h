//
//  ViSceneNode.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <string>
#include <vector>
#import "ViBase.h"
#import "ViMesh.h"
#import "ViVector2.h"
#import "ViCamera.h"
#import "ViMatrix4x4.h"

namespace vi 
{
    namespace common
    {
        class quadtree;
        class matrix4x4;
    }
    
    namespace graphic
    {
        class renderer;
        class material;
    }
    
    namespace scene
    {
        class scene;
        
        enum
        {
            /**
             * No clip flag. If set, the node won't be clipped
             **/
            sceneNodeFlagNoclip = 1,
            /**
             * Dynamic nodes are never clipped, just like node with no clip, but they also make less calls to the quadtree.
             * Use this for nodes that are often move across the tree to save performance.
             **/
            sceneNodeFlagDynamic = 2
        };
        
        typedef enum
        {
            sceneNodePhysicTypeBox,
            sceneNodePhysicTypeCircle
        } sceneNodePhysicType;
        
        /**
         * @brief A scene node represents a object inside a scene
         *
         * A scene node by itself is a void object which can't be rendered because it doesn't contain a material or mesh. However, it can be subclassed
         * to allow it to render more useful stuff. Usually you create a mesh and material in a scene nodes subclass which is then rendered by the renderer.
         * All other logic is implemented inside the scene node, like updating the matrix and updating itself on position changes etc.<br />
         * <br />
         * Scene nodes can also contain childs. A child is an object that is clipped together with its parent (so update the size of the parent if needed),
         * it will also be rendered relative to its parent by the renderer. Childs can also contain childs again.
         **/
        class sceneNode
        {
            friend class vi::common::quadtree;
            friend class vi::scene::scene;
            friend class vi::graphic::renderer;
        public:
            /**
             * Constructor
             **/
            sceneNode(vi::common::vector2 const& pos=vi::common::vector2(), vi::common::vector2 const& tsize=vi::common::vector2(), uint32_t tlayer = 0);
            virtual ~sceneNode();
            
            /**
             * Function invoked before the node is rendered
             * @remark The function will set the matrix of the node to represent the current position and rotation.
             **/
            virtual void visit(double timestep);

            /**
             * Sets a new position
             **/
            void setPosition(vi::common::vector2 const& point);
            /**
             * Sets a new size
             **/
            void setSize(vi::common::vector2 const& tsize);
            /**
             * Sets the flags of the node. Flags are represented as OR'ed bit field
             **/
            void setFlags(uint32_t flags);
            
            
            /**
             * Returns the position of the node
             **/
            vi::common::vector2 getPosition();
            /**
             * Returns the size of the node
             **/
            vi::common::vector2 getSize();
            /**
             * Returns the flags of the node. Flags are represented as OR'ed bit field
             **/
            uint32_t getFlags();
            
            /**
             * Returns true if the node has any childrens.
             **/
            bool hasChilds();
            /**
             * Returns a vector with all the childrens of the node
             * @remark Don't delete the vector!
             **/
            std::vector<vi::scene::sceneNode *> *getChilds();
            
            /**
             * Adds the given scene node as child
             * @remark If the node already has a parent, it will automatically removed from that parent.
             **/
            void addChild(vi::scene::sceneNode *child);
            /**
             * Removes the given child.
             **/
            void removeChild(vi::scene::sceneNode *child);
            
            
            void setDebugName(std::string *name, bool deleteAutomatically=true);
            
#ifdef ViPhysicsChipmunk
            void enablePhysics(sceneNodePhysicType type=sceneNodePhysicTypeBox);
            void makeStaticObject(vi::common::vector2 const& end);
            void disablePhysics();
            
            void setRotation(GLfloat rotation);
            
            void setMass(GLfloat mass);
            void setInertia(GLfloat inertia);
            void setElasticity(GLfloat elasticity);
            void setFriction(GLfloat friction);
            void setSurfaceVelocity(vi::common::vector2 const& velocity);
            void setGroup(uint32_t group);
            
            void resetForce();
            void applyForce(vi::common::vector2 const& force, vi::common::vector2 const& offset=vi::common::vector2());
            void applyImpulse(vi::common::vector2 const& impulse, vi::common::vector2 const& offset=vi::common::vector2());
            
            void restrictAngularVelocity(GLfloat aVel);
            void restrictVelocity(GLfloat velocity);
            
            void sleep();
            void activate();
            bool isSleeping();
            
            GLfloat suggestedInertia();
#endif
            
            /**
             * The rotation of the node
             **/
            GLfloat rotation;
            /**
             * The layer of the node. Nodes with a higher layer are drawn above nodes with a lower layer.
             **/
            uint32_t layer;
            
            
            /**
             * The mesh of the node. Default value is NULL
             **/
            vi::common::mesh *mesh;
            /**
             * The material of the node. Default value is NULL
             **/
            vi::graphic::material *material;
            
            /**
             * The matrix of the node
             **/
            vi::common::matrix4x4 matrix;
            /**
             * A camera which shouldn't render the node. This is useful if you want render something onto the texture of the scne node but don't want to
             * render the node also into the texture (now you are thinking with portals)
             **/
            vi::scene::camera *noPass;
            
            std::string *debugName;
        protected:
            /**
             * The position of the scene node. If you change this directly, call update() to update the node within its tree.
             **/
            vi::common::vector2 position;
            /**
             * The size of the scene node. If you change this directly, call update() to update the node within its tree.
             **/
            vi::common::vector2 size;
            /**
             * The bitfield of flags of the scene node. If you change this directly, call update() to update the node within its tree.
             **/
            uint32_t flags;
            
            /**
             * Tells the quadtree of the node to update itself in order to represent the node correctly again after a change.
             **/
            void update();
            
            
            vi::common::quadtree *tree;
            vi::scene::scene *scene;
            vi::scene::sceneNode *parent;
            
        private:
#ifdef ViPhysicsChipmunk
            cpBody  *body;
            cpShape *shape;
            
            bool waitingForActivation;
            bool initializedInertia;
            bool isStatic;
            bool bodyIsSleeping;
            
            cpFloat mass;
            cpFloat inertia;
            cpFloat elasticity;
            cpFloat friction;
            cpFloat angVelLimit;
            cpFloat velLimit;
            
            cpVect surfaceVelocity;
            uint32_t group;
            
            vi::common::vector2 staticEnd;
            sceneNodePhysicType physicType;
#endif
           
            bool deleteDebugName;
            bool knownDynamic;
            
            std::vector<vi::scene::sceneNode *> childs;
        };
    }
}