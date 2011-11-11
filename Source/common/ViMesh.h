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
        typedef enum
        {
            vertexFeaturesXYUV = 1,
            vertexFeaturesRGBA = 2
        } vertexFeatures;
        
        class __mesh
        {
        public:
            __mesh();
            virtual ~__mesh();
            
            virtual void translate(vi::common::vector2 const& offset) {}
            virtual void scale(vi::common::vector2 const& scale) {}
            
            virtual void addMesh(__mesh *mesh, vi::common::vector2 const& translation=vi::common::vector2(), vi::common::vector2 const& scale=vi::common::vector2(1.0, 1.0)) {}
            
            virtual void generateVBO(bool dyn=false);
            virtual void updateVBO();
            
            virtual void addVertex(float x, float y, float u, float v) {}
            virtual void addIndex(uint16_t index) {}
            
            virtual void updateVertex(uint32_t index, float x, float y, float u, float v) {}
            virtual void updateIndex(uint32_t index, uint16_t newIndex) {}
            
            
            int     features;
            size_t  vertexSize;
            
            void        *vertices;
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
         * @brief A class which maintains a list of vertices
         *
         * The mesh class stores a dynamic set of vertices and, if wanted, a vbo or two vbos for dynamic updating.
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
            
            
            /**
             * Translates the mesh by the given offset.
             **/
            virtual void translate(vi::common::vector2 const& offset);
            virtual void scale(vi::common::vector2 const& scale);
            
            /**
             * Adds a new vertex to te vertex list
             * @remark This method fails if the meshs vertices and indices aren't managed by the mesh.
             **/
			virtual void addVertex(float x, float y, float u, float v);
            virtual void addIndex(uint16_t index);
            
            virtual void updateVertex(uint32_t index, float x, float y, float u, float v);
            virtual void updateIndex(uint32_t index, uint16_t newIndex);
            
            
            virtual void addMesh(__mesh *mesh, vi::common::vector2 const& translation=vi::common::vector2(), vi::common::vector2 const& scale=vi::common::vector2(1.0, 1.0));         
            
            vertex   *getVertices();
            uint16_t *getIndices();
        };
        
        
        
        typedef struct
        {
            float x, y;
            float u, v;
            float r, g, b, a;
        } vertexRGBA;
        
        class meshRGBA : public __mesh
        {
        public:      
            meshRGBA(uint32_t tcount=0, uint32_t indcount=0);
    
            virtual void translate(vi::common::vector2 const& offset);
            virtual void scale(vi::common::vector2 const& scale);
            
            
			virtual void addVertex(float x, float y, float u, float v);
            virtual void addIndex(uint16_t index);
            
            virtual void updateVertex(uint32_t index, float x, float y, float u, float v);
            virtual void updateIndex(uint32_t index, uint16_t newIndex);
            
            
            virtual void addMesh(__mesh *mesh, vi::common::vector2 const& translation=vi::common::vector2(), vi::common::vector2 const& scale=vi::common::vector2(1.0, 1.0));        
            
            vertexRGBA  *getVertices();
            uint16_t    *getIndices();
        };
    }
}