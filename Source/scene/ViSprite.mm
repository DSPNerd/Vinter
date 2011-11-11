//
//  ViSprite.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViSprite.h"
#import "ViVector3.h"
#import "ViContext.h"

namespace vi
{
    namespace scene
    {
        sprite::sprite(vi::graphic::texture *texture, bool upsideDown)
        {
            createFromMeshAndMaterial(texture, NULL, NULL);
        }
        
        sprite::sprite(vi::graphic::texture *texture, vi::common::mesh *sharedMesh)
        {
            createFromMeshAndMaterial(texture, sharedMesh, NULL);
        }
        
        sprite::sprite(vi::graphic::texture *texture, vi::graphic::material *sharedMaterial)
        {
            createFromMeshAndMaterial(texture, NULL, sharedMaterial);
        }
        
        sprite::sprite(vi::graphic::texture *texture, vi::common::mesh *sharedMesh, vi::graphic::material *sharedMaterial)
        {
            createFromMeshAndMaterial(texture, sharedMesh, sharedMaterial);
        }
        
        
        void sprite::createFromMeshAndMaterial(vi::graphic::texture *texture, vi::common::mesh *sharedMesh, vi::graphic::material *sharedMaterial)
        {
            if(sharedMaterial && sharedMaterial->textures.size() > 0)
                texture = sharedMaterial->textures[0];
            
            if(texture)
                this->setSize(vi::common::vector2(texture->getWidth(), texture->getHeight()));
            
            
            
            vi::common::context *context = vi::common::context::getActiveContext();
            assert(context);
            
            
            atlasBegin = vi::common::vector2(0.0f, 0.0f);
            atlasSize  = this->getSize();
            atlasX = atlasY = 0.0f;
            atlasZ = atlasW = 1.0f;
            
            ownsMaterial = false;
            ownsMesh     = false;
            
            writeAtlasInfoIntoMesh = false;
            isUpsideDown = false;
            
            if(!sharedMaterial)
            {
                sharedMaterial = new vi::graphic::material(texture, context->getShader(vi::graphic::defaultShaderSprite));
                sharedMaterial->blending = true;
                sharedMaterial->blendSource = GL_ONE;
                sharedMaterial->blendDestination = GL_ONE_MINUS_SRC_ALPHA;
                sharedMaterial->addParameter("atlasTranslation", &atlasX, vi::graphic::materialParameterTypeFloat, 4, 1);
                
                ownsMaterial = true;
            }
            
            if(!sharedMesh)
            {
                sharedMesh = new vi::common::mesh(4, 6);
                sharedMesh->addVertex(0.0, 1.0, 0.0, 0.0);
                sharedMesh->addVertex(1.0, 1.0, 1.0, 0.0);
                sharedMesh->addVertex(1.0, 0.0, 1.0, 1.0);
                sharedMesh->addVertex(0.0, 0.0, 0.0, 1.0);
                
                sharedMesh->addIndex(0);
                sharedMesh->addIndex(3);
                sharedMesh->addIndex(1);
                sharedMesh->addIndex(2);
                sharedMesh->addIndex(1);
                sharedMesh->addIndex(3);
                
                ownsMesh = true;
            }
            
            mesh        = sharedMesh;
            material    = sharedMaterial;
        }
        
        
        sprite::~sprite()
        {
            if(ownsMaterial && material)
                delete material;
            
            if(ownsMesh && mesh)
                delete mesh;
        }
        
        
        void sprite::setSize(vi::common::vector2 const& tsize)
        {
            sceneNode::setSize(tsize);
            if(mesh && ownsMesh && writeSizeInformationIntoMesh)
            {                
                vi::common::vertex *vertices = ((vi::common::mesh *)mesh)->getVertices();
                
                vertices[0].x = 0.0;
                vertices[0].y = size.y;
                
                vertices[1].x = size.x;
                vertices[1].y = size.y;
                
                vertices[2].x = size.x;
                vertices[2].y = 0.0;
                
                vertices[3].x = 0.0;
                vertices[3].y = 0.0;
            }
        }
        
        void sprite::visit(double timestep)
        {            
            sceneNode::visit(timestep);
            
            if(!writeSizeInformationIntoMesh)
                matrix.scale(vi::common::vector3(size.x, size.y, 1.0f));
        }
        
        
        
        void sprite::setTexture(vi::graphic::texture *texture)
        {
            if(material && ownsMaterial)
            {
                if(material->textures.size() == 0)
                {
                    material->textures.push_back(texture);
                    material->texlocations.push_back(1);
                }
                else
                {
                    material->textures[0] = texture;
                }
                
                this->setAtlas(atlasBegin, atlasSize);
            }
        }
        
        void sprite::setAtlas(vi::common::vector2 const& begin, vi::common::vector2 const& size)
        {
            atlasBegin = begin;
            atlasSize  = size;
            
            if(material && material->textures.size() > 0)
            {                
                vi::graphic::texture *texture = material->textures[0];
                
                atlasX = begin.x / texture->getWidth();
                atlasY = begin.y / texture->getHeight();
                atlasZ = size.x / texture->getWidth();
                atlasW = size.y / texture->getHeight();
                
                if(writeAtlasInfoIntoMesh && ownsMesh)
                {
                    CGFloat endU = (begin.x + size.x) / texture->getWidth();
                    CGFloat endV = (begin.y + size.y) / texture->getHeight();
                    
                    vi::common::vertex *vertices = ((vi::common::mesh *)mesh)->getVertices();
                    
                    vertices[0].u = atlasX;
                    vertices[0].v = atlasY;
                    
                    vertices[1].u = endU;
                    vertices[1].v = atlasY;
                    
                    vertices[2].u = endU;
                    vertices[2].v = endV;
                    
                    vertices[3].u = atlasX;
                    vertices[3].v = endV;
                }
            }
            
            this->setSize(size);
        }
        
        void sprite::setWriteAtlasInformationIntoMesh()
        {
            writeAtlasInfoIntoMesh = true;
            setAtlas(atlasBegin, atlasSize);
        }
        
        void sprite::setWriteSizeInformationIntoMesh()
        {
            writeSizeInformationIntoMesh = true;
            if(mesh && ownsMesh)
            {
                setSize(size);
            }
        }
    }
}
