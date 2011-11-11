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
            sceneNodeFlagDynamic = 2,
            /**
             * If this flag is set, the renderer is allowed to batch up all the childs of the node in order to speed up rendering
             **/
            sceneNodeFlagConcatenateChildren = 4
        };
        
        typedef enum
        {
            /**
             * A rectangular physic shape
             **/
            sceneNodePhysicTypeBox,
            /**
             * Type of a circle like physic shape
             **/
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
         * <br />
         * Nodes can be registered as physical nodes since Vinter 0.4.0, this is done by wrapping a Chipmunk shape and body, 
         * for more information please visit http://chipmunk-physics.net/
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
            virtual void setPosition(vi::common::vector2 const& point);
            /**
             * Sets a new size
             **/
            virtual void setSize(vi::common::vector2 const& tsize);
            /**
             * Sets the flags of the node. Flags are represented as OR'ed bit field
             **/
            virtual void setFlags(uint32_t flags);
            
            
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
            
            /**
             * Sets a new debug name which is used as name for the OpenGL debug marker pushed when rendering the node.
             * @param deleteAutomatically True if the node should delete the name on its own, otherwise false.
             **/
            void setDebugName(std::string *name, bool deleteAutomatically=true);
            
#ifdef ViPhysicsChipmunk
            /**
             * Registers the node as a physical node.
             **/
            void enablePhysics(sceneNodePhysicType type=sceneNodePhysicTypeBox);
            /**
             * Adds the node as a static object into the scene
             * @param end The end, in world coordinates, of the node. You can imagine the static body as a straight line that goes from the position of the node to this point
             **/
            void makeStaticObject(vi::common::vector2 const& end);
            /**
             * Disables and removes the node from the physics calculation
             **/
            void disablePhysics();
            
            /**
             * Returns true if the node is a physical node.
             **/
            bool isPhysicalBody();
            
            
            /**
             * Sets a new rotation for the node
             * @remark Use this instead of setting the rotation member directly for physical nodes
             **/
            void setRotation(GLfloat rotation);
            
            /**
             * Sets the mass of the node
             **/
            void setMass(GLfloat mass);
            /**
             * Sets a new moment of inertia
             * @remark You should always set the suggestedInertia() which is calculated from the mass and the shape of the node.
             **/
            void setInertia(GLfloat inertia);
            /**
             * Sets the given elasticity.
             **/
            void setElasticity(GLfloat elasticity);
            /**
             * Sets the given friction
             **/
            void setFriction(GLfloat friction);
            /**
             * Sets the surface velocity which is used when calculating friction.
             **/
            void setSurfaceVelocity(vi::common::vector2 const& velocity);
            /**
             * Sets the collision group of the node. Nodes with the same collision group don't collide with each other, unless the group is 0
             **/ 
            void setGroup(uint32_t group);
            
            
            /**
             * Returns the mass of the node.
             **/
            GLfloat getMass();
            /**
             * Returnst the moment of inertia of the node
             **/
            GLfloat getInertia();
            /**
             * Returns the elasticity of the node
             **/
            GLfloat getElasticity();
            /**
             * Returns the friction of the node
             **/
            GLfloat getFriction();
            /**
             * Returns the surface velocity of the node
             **/
            vi::common::vector2 getSurfaceVelocitiy();
            /**
             * Returns the current collision group of the node
             **/
            uint32_t getGroup();
            
            
            /**
             * Resets all current forces acting on the node.
             * @remark Only works with physical nodes
             **/
            void resetForce();
            /**
             * Applies the given force to the node, unlike impulses, a force is applied all the time to the node, much like a motor.
             * @remark Only works with physical nodes
             **/
            void applyForce(vi::common::vector2 const& force, vi::common::vector2 const& offset=vi::common::vector2());
            /**
             * Applies the given impulse to the node
             * @remark Only works with physical nodes
             **/
            void applyImpulse(vi::common::vector2 const& impulse, vi::common::vector2 const& offset=vi::common::vector2());
            
            /**
             * Restricts the angular velocity of the node
             **/
            void restrictAngularVelocity(GLfloat aVel);
            /**
             * Restricts the angular velocity of the node
             **/
            void restrictVelocity(GLfloat velocity);
            
            /**
             * Returns the angular velocity limit of the node
             **/
            GLfloat getAngularVelocityLimit();
            /**
             * Returns the velocity limit of the node
             **/
            GLfloat getVelocityLimit();
            
            /**
             * Returns the current angular velocity of the node.
             * @remark Only works with physical nodes
             **/
            GLfloat getAngularVelocity();
            /**
             * Returns the current velocity of the node.
             * @remark Only works with physical nodes
             **/
            vi::common::vector2 getVelocity();
            
            /**
             * Forces the node to fall asleep, useful when creating a level to initialize the node as sleeping
             * @remark Only works with physical nodes
             **/
            void sleep();
            /**
             * If the node is sleeping, invoking this method will wake it up.
             * @remark Only works with physical nodes
             **/
            void activate();
            /**
             * Returns true if the physical body of the node is sleeping.
             * @remark Only works with physical nodes
             **/
            bool isSleeping();
            
            /**
             * Returns the suggested moment of inertia for the node, based on its shape and mass.
             * @remark You don't need to enable physics to call this function!
             **/
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
            vi::common::__mesh *mesh;
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
            
            /**
             * Name of the node, default NULL.
             * @remark In debug builds this name is used to add OpenGL debug markers for easier debugging.
             **/
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
            
            /**
             * The quadtree the scene node is currently inserted to, or NULL
             **/
            vi::common::quadtree *tree;
            /**
             * The scene the node is associated with
             **/
            vi::scene::scene *scene;
            /**
             * Parent node
             **/
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