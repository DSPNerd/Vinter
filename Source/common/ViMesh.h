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
#import "ViColor.h"

namespace vi
{
    namespace common
    {      
        typedef struct
        {
            GLfloat x, y;
            GLfloat u, v;
            GLfloat r, g, b, a;
        } vertex;
        
        class mesh
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
            
            ~mesh();
            
            
            void translate(vi::common::vector2 const& offset);
            void scale(vi::common::vector2 const& scale);
            
			void addVertex(GLfloat x, GLfloat y, GLfloat u, GLfloat v);
            void addIndex(uint16_t index);
            
            void updateVertex(uint32_t index, GLfloat x, GLfloat y, GLfloat u, GLfloat v);
            void updateColor(uint32_t index, vi::common::color const& color);
            void updateIndex(uint32_t index, uint16_t newIndex);           
            
            void addMesh(mesh *appendMesh, vi::common::vector2 const& translation=vi::common::vector2(), vi::common::vector2 const& scale=vi::common::vector2(1.0, 1.0));         
            
            
            /**
             * Generates VBOs for the mesh
             * @param dyn If true, the mesh will generate a pair of VBOs for dynamic usage
             **/
            void generateVBO(bool dyn=false);
            /**
             * Updates the VBO, if the VBO is dynamic, the VBOs are also toggled.
             **/
            void updateVBO();
            
            
            vertex   *getVertices();
            uint16_t *getIndices();
            
            
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
            
            vertex *vertices;
            uint16_t *indices;
        };
    }
}