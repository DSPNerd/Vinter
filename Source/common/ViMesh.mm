//
//  ViMesh.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViMesh.h"

namespace vi
{
    namespace common
    {  
        mesh::mesh(uint32_t tcount, uint32_t indcount)
        {
            vbo  = vbo0  = vbo1  = -1;
            ivbo = ivbo0 = ivbo1 = -1;
            
            vboToggled  = false;
            dynamic     = false;
            ownsData    = true;
            
            vertexCount = 0;
			indexCount  = 0;
            
            vertexCapacity = MAX(tcount, 1);
            indexCapacity  = MAX(indcount, 1);
            
            vertices = (vertex *)malloc(vertexCapacity * sizeof(vertex));
			indices  = (uint16_t *)malloc(indexCapacity * sizeof(uint16_t));
        }
        
        mesh::mesh(vertex *tvertices, uint16_t *tinidices, uint32_t tcount, uint32_t indcount)
        {
            vbo  = vbo0  = vbo1  = -1;
            ivbo = ivbo0 = ivbo1 = -1;
            
            vboToggled  = false;
            dynamic     = false;
            ownsData    = false;
            
            vertexCount = vertexCapacity = tcount;
			indexCount = indexCapacity = indcount;
            
            vertices = tvertices;
			indices  = tinidices;
        }
        
        mesh::~mesh()
        {
            if(vertices && ownsData)
                free(vertices);
            
            if(indices && ownsData)
                free(indices);
            
            if(vbo0 != -1)
                glDeleteBuffers(1, &vbo0);
            if(ivbo0 != -1)
                glDeleteBuffers(1, &ivbo0);
            
            if(vbo1 != -1)
                glDeleteBuffers(1, &vbo1);
            if(ivbo1 != -1)
                glDeleteBuffers(1, &ivbo1);
        }
        
        
        
        
        void mesh::resizeVertices(int32_t appendVertices)
        {
            assert(ownsData);
            
            if(vertexCapacity > vertexCount + appendVertices)
                return;
            
            vertex *tvertices = (vertex *)realloc(vertices, (vertexCount + appendVertices) * sizeof(vertex));
            if(tvertices)
            {
                vertices = tvertices;
                vertexCapacity = vertexCount + appendVertices;
            }
        }
        
        void mesh::resizeIndices(int32_t appendIndices)
        {
            assert(ownsData);
            
            if(indexCapacity > indexCount + appendIndices)
                return;
            
            uint16_t *tindicies = (uint16_t *)realloc(indices, (indexCount + appendIndices) * sizeof(uint16_t));
            if(tindicies)
            {
                indices = tindicies;
                indexCapacity = indexCount + appendIndices;
            }
        }
        
        
        
        
        void mesh::generateVBO(bool dyn)
        {
            dynamic = dyn;
            
            if(vbo0 != -1)
                glDeleteBuffers(1, &vbo0);
            if(ivbo0 != -1)
                glDeleteBuffers(1, &ivbo0);
            
            if(vbo1 != -1)
                glDeleteBuffers(1, &vbo1);
            if(ivbo1 != -1)
                glDeleteBuffers(1, &ivbo1);
            
            
            vbo = ivbo = -1;
            vbo0 = ivbo0 = -1;
            vbo1 = ivbo1 = -1;
            
            vboToggled = false;
            
            if(!dynamic)
            {
                glGenBuffers(1, &vbo0);
                glBindBuffer(GL_ARRAY_BUFFER, vbo0);
                glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(vertex), vertices, GL_STATIC_DRAW);
                glBindBuffer(GL_ARRAY_BUFFER, 0);
                
                glGenBuffers(1, &ivbo0);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ivbo0);
                glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexCount * sizeof(uint16_t), indices, GL_STATIC_DRAW);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
            }
            else
            {
                glGenBuffers(1, &vbo0);
                glBindBuffer(GL_ARRAY_BUFFER, vbo0);
                glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(vertex), vertices, GL_DYNAMIC_DRAW);
                glBindBuffer(GL_ARRAY_BUFFER, 0);
                
                glGenBuffers(1, &ivbo0);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ivbo0);
                glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexCount * sizeof(uint16_t), indices, GL_DYNAMIC_DRAW);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
                
                glGenBuffers(1, &vbo1);
                glBindBuffer(GL_ARRAY_BUFFER, vbo1);
                glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(vertex), vertices, GL_DYNAMIC_DRAW);
                glBindBuffer(GL_ARRAY_BUFFER, 0);
                
                glGenBuffers(1, &ivbo1);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ivbo1);
                glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexCount * sizeof(uint16_t), indices, GL_DYNAMIC_DRAW);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
            }
            
            vbo = vbo0;
            ivbo = ivbo0;
            
            dirty = true;
        }
        
        void mesh::updateVBO()
        {
            if(!dynamic)
            {
                generateVBO(false);
                return;
            }
            
            dirty = true;
            vboToggled = !vboToggled;
            
            if(vboToggled)
            {
                vbo = vbo1;
                ivbo = ivbo1;
                
                glBindBuffer(GL_ARRAY_BUFFER, vbo0);
                glBufferSubData(GL_ARRAY_BUFFER, 0, vertexCount * sizeof(vertex), vertices);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
                
                glBindBuffer(GL_ARRAY_BUFFER, ivbo0);
                glBufferSubData(GL_ARRAY_BUFFER, 0, indexCount * sizeof(uint16_t), indices);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
            }
            else
            {
                vbo = vbo0;
                ivbo = ivbo0;
                
                glBindBuffer(GL_ARRAY_BUFFER, vbo1);
                glBufferSubData(GL_ARRAY_BUFFER, 0, vertexCount * sizeof(vertex), vertices);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
                
                glBindBuffer(GL_ARRAY_BUFFER, ivbo1);
                glBufferSubData(GL_ARRAY_BUFFER, 0, indexCount * sizeof(uint16_t), indices);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
            }
        }
        
        
        vertex *mesh::getVertices()
        {
            return vertices;
        }
        
        uint16_t *mesh::getIndices()
        {
            return indices;
        }
        
        
        
        void mesh::translate(vi::common::vector2 const& offset)
        {
            for(uint32_t i=0; i<vertexCount; i++)
            {
                vertices[i].x += offset.x;
                vertices[i].y += offset.y;
            }
            
            dirty = true;
        }
		
        void mesh::scale(vi::common::vector2 const& scale)
        {
            for(uint32_t i=0; i<vertexCount; i++)
            {
                vertices[i].x *= scale.x;
                vertices[i].y *= scale.y;
            }
            
            dirty = true;
        }
        
        
        void mesh::addVertex(GLfloat x, GLfloat y, GLfloat u, GLfloat v)
        {
            if(!ownsData)
                return;
            
            resizeVertices(1);
            
            vertices[vertexCount].x = x;
            vertices[vertexCount].y = y;
            vertices[vertexCount].u = u;
            vertices[vertexCount].v = v;
            vertices[vertexCount].r = 1.0;
            vertices[vertexCount].g = 1.0;
            vertices[vertexCount].b = 1.0;
            vertices[vertexCount].a = 1.0;
            
            vertexCount ++;
            dirty = true;
        }
        
        void mesh::addIndex(uint16_t index)
        {
            if(!ownsData)
                return;
            
            resizeIndices(1);
            
            indices[indexCount] = index;
            
            indexCount ++;
            dirty = true;
        }
        
        
        
        void mesh::updateVertex(uint32_t index, GLfloat x, GLfloat y, GLfloat u, GLfloat v)
        {
            if(!ownsData || index >= vertexCount)
                return;

            vertices[index].x = x;
            vertices[index].y = y;
            vertices[index].u = u;
            vertices[index].v = v;
            
            dirty = true;
        }
        
        void mesh::updateColor(uint32_t index, vi::common::color const& color)
        {
            if(!ownsData || index >= vertexCount)
                return;
            
            vertices[index].r = color.r;
            vertices[index].g = color.g;
            vertices[index].b = color.b;
            vertices[index].a = color.a;
            
            dirty = true;
        }
        
        void mesh::updateIndex(uint32_t index, uint16_t newIndex)
        {
            if(!ownsData || index >= indexCount)
                return;
            
            indices[index] = newIndex;
            dirty = true;
        }

        
        
        
        void mesh::addMesh(mesh *appendMesh, vi::common::vector2 const& translation, vi::common::vector2 const& scale)
        {
            resizeVertices(appendMesh->vertexCount);
            resizeIndices(appendMesh->indexCount);
            
            for(uint32_t i=0; i<appendMesh->indexCount; i++)
            {
                indices[indexCount] = appendMesh->indices[i] + vertexCount;
                indexCount ++;
            }
            
            for(uint32_t i=0; i<appendMesh->vertexCount; i++)
            {
                vertices[vertexCount] = appendMesh->vertices[i];
                
                vertices[vertexCount].x *= scale.x;
                vertices[vertexCount].y *= scale.y;
                vertices[vertexCount].x += translation.x;
                vertices[vertexCount].y += translation.y;
                
                vertexCount ++;
            }            
            
            dirty = true;
        }
    }
}
