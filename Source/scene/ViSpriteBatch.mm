//
//  ViSpriteBatch.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViSpriteBatch.h"
#import "ViContext.h"
#import "ViMaterial.h"

namespace vi
{
    namespace scene
    {
        spriteBatch::spriteBatch(vi::graphic::texture *texture)
        {
            vi::common::context *context = vi::common::context::getActiveContext();
            assert(context);
            
            material = new vi::graphic::material(texture, context->getShader(vi::graphic::defaultShaderTexture));
            material->blending = true;
            material->blendSource = GL_ONE;
            material->blendDestination = GL_ONE_MINUS_SRC_ALPHA;
            
            setFlags(flags | vi::scene::sceneNodeFlagConcatenateChildren);
        }
        
        spriteBatch::~spriteBatch()
        {
            delete material;
        }
        
        vi::scene::sprite *spriteBatch::addSprite()
        {
            vi::scene::sprite *sprite = new vi::scene::sprite(NULL, material);
            
            sprite->setWriteAtlasInformationIntoMesh();
            sprite->setWriteSizeInformationIntoMesh();
            
            addChild(sprite);
            return sprite;
        }
        
        void spriteBatch::removeSprite(vi::scene::sprite *sprite)
        {
            removeChild(sprite);
            delete sprite;
        }
        
        void spriteBatch::setTexture(vi::graphic::texture *texture)
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
            
            // Apply texture...
        }
        
        void spriteBatch::generateMesh(bool generateVBO)
        {
            ViDeprecatedLog();
        }
    }
}
