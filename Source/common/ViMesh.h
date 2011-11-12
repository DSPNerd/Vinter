//
//  ViMesh.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <vector>
#import "ViBase.h"
#import "ViVector2.h"

namespace vi
{
    namespace common
    {      
        /**
         * Possible vertex features of an mesh
         **/
        typedef enum
        {
            /**
             * The mesh contains X, Y, U and V components per vertex
             **/
            vertexFeaturesXYUV = (1 << 1),
            /**
             * The mesh contains R, G, B and A components per vertex
             **/
            vertexFeaturesRGBA = (1 << 2)
        } vertexFeatures;
        
        /**
         * Mesh class without implied vertex layout
         **/
        class __mesh
        {
        public:
            __mesh();
            virtual ~__mesh();
            
            /**
             * Translates the mesh
             **/
            virtual void translate(vi::common::vector2 const& offset) {}
            /**
             * Scales the mesh
             **/
            virtual void scale(vi::common::vector2 const& scale) {}
            
            /**
             * Appends the given mesh and performs the given translation and scale operations on the newly appended mesh.
             **/
            virtual void addMesh(__mesh *mesh, vi::common::vector2 const& translation=vi::common::vector2(), vi::common::vector2 const& scale=vi::common::vector2(1.0, 1.0)) {}
            
            /**
             * Generates VBOs for the mesh
             * @param dyn If true, the mesh will generate a pair of VBOs for dynamic usage
             **/
            virtual void generateVBO(bool dyn=false);
            /**
             * Updates the VBO, if the VBO is dynamic, the VBOs are also toggled.
             **/
            virtual void updateVBO();
            
            /**
             * Adds the given vertex to the end of the vertices
             **/
            virtual void addVertex(float x, float y, float u, float v) {}
            /**
             * Adds the given index tot the end of the indices
             **/
            virtual void addIndex(uint16_t index) {}
            
            /**
             * Updates the vertex at the given index
             **/
            virtual void updateVertex(uint32_t index, float x, float y, float u, float v) {}
            /**
             * Updates the index at the given index
             **/
            virtual void updateIndex(uint32_t index, uint16_t newIndex) {}
            
            /**
             * Bitfield containing the features of the mesh.
             * @sa vertexFeatures
             **/
            int     features;
            /**
             * The size of one vertex in bytes
             **/
            size_t  vertexSize;
            
            /**
             * Pointer to the raw pointer data
             **/
            void        *vertices;
            /**
             * Pointer to the raw indices data
             **/
            uint16_t    *indices;
            
            
            /**
             * The number of vertices
             **/
            uint32_t vertexCount;
            /**
             * The number of indices
             **/
            uint32_t indexCount;
            
            /**
             * True if the mesh uses dynamic VBOs, otherwise false
             **/
            bool dynamic;
            /**
             * True if the mesh is dirty and wants to be redrawn
             **/
            bool dirty;
            /**
             * The handle to the current VBO
             **/
            GLuint vbo;
            /**
             * The handle to the current index VBO
             **/
            GLuint ivbo;
            
        protected:
            void resizeVertices(int32_t appendVertices);
            void resizeIndices(int32_t appendIndices);
            
            bool vboToggled;
            bool ownsData;
            
            GLuint vbo0, vbo1;
            GLuint ivbo0, ivbo1;
            
            uint32_t vertexCapacity;
            uint32_t indexCapacity;
        };
        
        
        
        /**
         * @brief Floating point X, Y, U, V vertex structure
         *
         * A structure capable of holding a vertex. A vertex contains X and Y axis information and U, V values.
         **/
        typedef struct
        {
            float x, y;
            float u, v;
        } vertex;
        
        /**
         * @brief Simple mesh
         *
         * A mesh contains and controls vertices with X, Y, U, V information
         **/
        class mesh : public __mesh
        {
        public:      
            /**
             * Constructor
             * @param tcount The desired number of vertices
             * @param indcount The desired number of indices
             **/
            mesh(uint32_t tcount=0, uint32_t indcount=0);
            /**
             * Constructor for a mesh that doesn't manage its own vertices and indices but uses the one provided to the constructor
             * @remark Meshes created with this method aren't mutable!
             **/
            mesh(vertex *tvertices, uint16_t *tinidices, uint32_t tcount, uint32_t indcount);        
            
            
            virtual void translate(vi::common::vector2 const& offset);
            virtual void scale(vi::common::vector2 const& scale);
            
			virtual void addVertex(float x, float y, float u, float v);
            virtual void addIndex(uint16_t index);
            
            virtual void updateVertex(uint32_t index, float x, float y, float u, float v);
            virtual void updateIndex(uint32_t index, uint16_t newIndex);
            
            
            virtual void addMesh(__mesh *mesh, vi::common::vector2 const& translation=vi::common::vector2(), vi::common::vector2 const& scale=vi::common::vector2(1.0, 1.0));         
            
            /**
             * Retuns the vertices of the mesh
             **/
            vertex   *getVertices();
            /**
             * Returns the indices of the mesh
             **/
            uint16_t *getIndices();
        };
        
        
        /**
         * @brief Floating point X, Y, U, V, R, G, B, A vertex structure
         *
         * A structure capable of holding a vertex. A vertex contains X and Y axis information, U, V values and color information.
         **/
        typedef struct
        {
            float x, y;
            float u, v;
            float r, g, b, a;
        } vertexRGBA;
        
        /**
         * @brief Mesh with color vertex attributes
         *
         * A mesh containing and controlling vertices with position, UV, and color attributes.
         **/
        class meshRGBA : public __mesh
        {
        public:      
            /**
             * Constructor
             * @param tcount The desired number of vertices
             * @param indcount The desired number of indices
             **/
            meshRGBA(uint32_t tcount=0, uint32_t indcount=0);
    
            virtual void translate(vi::common::vector2 const& offset);
            virtual void scale(vi::common::vector2 const& scale);
            
            
			virtual void addVertex(float x, float y, float u, float v);
            virtual void addIndex(uint16_t index);
            
            virtual void updateVertex(uint32_t index, float x, float y, float u, float v);
            virtual void updateIndex(uint32_t index, uint16_t newIndex);
            
            
            virtual void addMesh(__mesh *mesh, vi::common::vector2 const& translation=vi::common::vector2(), vi::common::vector2 const& scale=vi::common::vector2(1.0, 1.0));        
            
            /**
             * Retuns the vertices of the mesh
             **/
            vertexRGBA  *getVertices();
            /**
             * Returns the indices of the mesh
             **/
            uint16_t    *getIndices();
        };
    }
}