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
        __mesh::__mesh()
        {
            vbo = vbo0 = vbo1 = -1;
            ivbo = ivbo0 = ivbo1 = -1;
            
            vboToggled  = false;
            dynamic     = false;
            ownsData    = true;
            
            vertexCount = 0;
			indexCount  = 0;
            
            vertexCapacity = 0;
            indexCapacity = 0;
            
            vertices = NULL;
            indices  = NULL;
        }
        
        __mesh::~__mesh()
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
        
        
        void __mesh::resizeVertices(int32_t appendVertices)
        {
            assert(ownsData);
            
            if(vertexCapacity > vertexCount + appendVertices)
                return;
            
            void *tvertices = realloc(vertices, (vertexCount + appendVertices) * vertexSize);
            if(tvertices)
            {
                vertices = tvertices;
                vertexCapacity = vertexCount + appendVertices;
            }
        }
        
        void __mesh::resizeIndices(int32_t appendIndices)
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
        
        
        void __mesh::generateVBO(bool dyn)
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
                glBufferData(GL_ARRAY_BUFFER, vertexCount * vertexSize, vertices, GL_STATIC_DRAW);
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
                glBufferData(GL_ARRAY_BUFFER, vertexCount * vertexSize, vertices, GL_DYNAMIC_DRAW);
                glBindBuffer(GL_ARRAY_BUFFER, 0);
                
                glGenBuffers(1, &ivbo0);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ivbo0);
                glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexCount * sizeof(uint16_t), indices, GL_DYNAMIC_DRAW);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
                
                glGenBuffers(1, &vbo1);
                glBindBuffer(GL_ARRAY_BUFFER, vbo1);
                glBufferData(GL_ARRAY_BUFFER, vertexCount * vertexSize, vertices, GL_DYNAMIC_DRAW);
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
        
        void __mesh::updateVBO()
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
                glBufferSubData(GL_ARRAY_BUFFER, 0, vertexCount * vertexSize, vertices);
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
                glBufferSubData(GL_ARRAY_BUFFER, 0, vertexCount * vertexSize, vertices);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
                
                glBindBuffer(GL_ARRAY_BUFFER, ivbo1);
                glBufferSubData(GL_ARRAY_BUFFER, 0, indexCount * sizeof(uint16_t), indices);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
            }
        }
        
        
        
        
        
        
        mesh::mesh(uint32_t tcount, uint32_t indcount)
        {
            features = vertexFeaturesXYUV;
            
            ownsData    = true;
            vertexSize  = sizeof(vertex);
            
            vertexCapacity = MAX(tcount, 1);
            indexCapacity  = MAX(indcount, 1);
            
            vertices = (vertex *)malloc(vertexCapacity * sizeof(vertex));
			indices  = (uint16_t *)malloc(indexCapacity * sizeof(uint16_t));
        }
        
        mesh::mesh(vertex *tvertices, uint16_t *tinidices, uint32_t tcount, uint32_t indcount)
        {
            features = vertexFeaturesXYUV;
            
            ownsData    = false;
            vertexSize  = sizeof(vertex);
            
            vertexCount = vertexCapacity = tcount;
			indexCount = indexCapacity = indcount;
            
            vertices = tvertices;
			indices = tinidices;
        }
        
        vertex *mesh::getVertices()
        {
            return (vertex *)vertices;
        }
        
        uint16_t *mesh::getIndices()
        {
            return indices;
        }
        
        
        
        void mesh::translate(vi::common::vector2 const& offset)
        {
            vertex *tvertices = (vertex *)vertices;
            
            for(uint32_t i=0; i<vertexCount; i++)
            {
                tvertices[i].x += offset.x;
                tvertices[i].y += offset.y;
            }
            
            dirty = true;
        }
		
        void mesh::scale(vi::common::vector2 const& scale)
        {
            vertex *tvertices = (vertex *)vertices;
            
            for(uint32_t i=0; i<vertexCount; i++)
            {
                tvertices[i].x *= scale.x;
                tvertices[i].y *= scale.y;
            }
            
            dirty = true;
        }
        
        void mesh::addVertex(float x, float y, float u, float v)
        {
            if(!ownsData)
                return;
            
            resizeVertices(1);
            vertex *tvertices = (vertex *)vertices;
            
            tvertices[vertexCount].x = x;
            tvertices[vertexCount].y = y;
            tvertices[vertexCount].u = u;
            tvertices[vertexCount].v = v;
            
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
        
        
        
        void mesh::updateVertex(uint32_t index, float x, float y, float u, float v)
        {
            if(!ownsData || index >= vertexCount)
                return;
            
            vertex *tvertices = (vertex *)vertices;
            
            tvertices[index].x = x;
            tvertices[index].y = y;
            tvertices[index].u = u;
            tvertices[index].v = v;
            
            dirty = true;
        }
        
        void mesh::updateIndex(uint32_t index, uint16_t newIndex)
        {
            if(!ownsData || index >= indexCount)
                return;
            
            indices[index] = newIndex;
            dirty = true;
        }

        void mesh::addMesh(__mesh *mesh, vi::common::vector2 const& translation, vi::common::vector2 const& scale)
        {
            resizeVertices(mesh->vertexCount);
            resizeIndices(mesh->indexCount);
            
            for(uint32_t i=0; i<mesh->indexCount; i++)
            {
                indices[indexCount] = mesh->indices[i] + vertexCount;
                indexCount ++;
            }
            
            vertex *tvertices = (vertex *)vertices;
            
            for(uint32_t i=0; i<mesh->vertexCount; i++)
            {
                tvertices[vertexCount] = ((vertex *)mesh->vertices)[i];
                
                if(mesh->features & vertexFeaturesRGBA)
                {
                    vertexRGBA *vertex = (vertexRGBA *)mesh->vertices;
                    tvertices[vertexCount].x = vertex[i].x;
                    tvertices[vertexCount].y = vertex[i].y;
                    tvertices[vertexCount].u = vertex[i].u;
                    tvertices[vertexCount].v = vertex[i].v;
                }
                else
                {
                    tvertices[vertexCount] = ((vertex *)mesh->vertices)[i];
                }
                
                tvertices[vertexCount].x *= scale.x;
                tvertices[vertexCount].y *= scale.y;
                tvertices[vertexCount].x += translation.x;
                tvertices[vertexCount].y += translation.y;
                
                vertexCount ++;
            }            
            
            dirty = true;
        }
        
        
        
        
        meshRGBA::meshRGBA(uint32_t tcount, uint32_t indcount)
        {
            features = vertexFeaturesXYUV | vertexFeaturesRGBA;
            
            ownsData    = true;
            vertexSize  = sizeof(vertexRGBA);
            
            vertexCapacity = MAX(tcount, 1);
            indexCapacity  = MAX(indcount, 1);
            
            vertices = (vertex *)malloc(vertexCapacity * sizeof(vertexRGBA));
			indices  = (uint16_t *)malloc(indexCapacity * sizeof(uint16_t));
        }
        
        void meshRGBA::translate(vi::common::vector2 const& offset)
        {
            vertexRGBA *tvertices = (vertexRGBA *)vertices;
            
            for(uint32_t i=0; i<vertexCount; i++)
            {
                tvertices[i].x += offset.x;
                tvertices[i].y += offset.y;
            }
            
            dirty = true;
        }
        
        void meshRGBA::scale(vi::common::vector2 const& scale)
        {
            vertexRGBA *tvertices = (vertexRGBA *)vertices;
            
            for(uint32_t i=0; i<vertexCount; i++)
            {
                tvertices[i].x *= scale.x;
                tvertices[i].y *= scale.y;
            }
            
            dirty = true;
        }
        
        
        void meshRGBA::addVertex(float x, float y, float u, float v)
        {
            if(!ownsData)
                return;
            
            resizeVertices(1);
            vertexRGBA *tvertices = (vertexRGBA *)vertices;
            
            tvertices[vertexCount].x = x;
            tvertices[vertexCount].y = y;
            tvertices[vertexCount].u = u;
            tvertices[vertexCount].v = v;
            
            tvertices[vertexCount].r = 1.0;
            tvertices[vertexCount].g = 1.0;
            tvertices[vertexCount].b = 1.0;
            tvertices[vertexCount].a = 1.0;

            vertexCount ++;
            dirty = true;
        }
        
        void meshRGBA::addIndex(uint16_t index)
        {
            if(!ownsData)
                return;
            
            resizeIndices(1);
            
            indices[indexCount] = index;
            indexCount ++;
            
            dirty = true;
        }
        
        
        
        void meshRGBA::updateVertex(uint32_t index, float x, float y, float u, float v)
        {
            if(!ownsData || index >= vertexCount)
                return;
            
            vertex *tvertices = (vertex *)vertices;
            
            tvertices[index].x = x;
            tvertices[index].y = y;
            tvertices[index].u = u;
            tvertices[index].v = v;
            
            dirty = true;
        }
        
        void meshRGBA::updateIndex(uint32_t index, uint16_t newIndex)
        {
            if(!ownsData || index >= indexCount)
                return;
            
            indices[index] = newIndex;
            dirty = true;
        }
        
        
        void meshRGBA::addMesh(__mesh *mesh, vi::common::vector2 const& translation, vi::common::vector2 const& scale)
        {
            resizeVertices(mesh->vertexCount);
            resizeIndices(mesh->indexCount);
            
            for(uint32_t i=0; i<mesh->indexCount; i++)
            {
                indices[indexCount] = mesh->indices[i] + vertexCount;
                indexCount ++;
            }
            
            vertexRGBA *tvertices = (vertexRGBA *)vertices;
            
            for(uint32_t i=0; i<mesh->vertexCount; i++)
            {
                if(mesh->features & vertexFeaturesRGBA)
                {
                    tvertices[vertexCount] = ((vertexRGBA *)mesh->vertices)[i];
                }
                else
                {
                    vertex *tvertex = (vertex *)mesh->vertices;
                    
                    tvertices[vertexCount].x = tvertex[i].x;
                    tvertices[vertexCount].y = tvertex[i].y;
                    tvertices[vertexCount].u = tvertex[i].u;
                    tvertices[vertexCount].v = tvertex[i].v;
                    
                    tvertices[vertexCount].r = 1.0;
                    tvertices[vertexCount].g = 1.0;
                    tvertices[vertexCount].b = 1.0;
                    tvertices[vertexCount].a = 1.0;
                }
                
                
                
                tvertices[vertexCount].x *= scale.x;
                tvertices[vertexCount].y *= scale.y;
                tvertices[vertexCount].x += translation.x;
                tvertices[vertexCount].y += translation.y;
                
                vertexCount ++;
            }            
            
            dirty = true;
        }
        
        
        vertexRGBA *meshRGBA::getVertices()
        {
            return (vertexRGBA *)vertices;
        }
        
        uint16_t *meshRGBA::getIndices()
        {
            return indices;
        }
    }
}
