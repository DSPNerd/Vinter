//
//  ViSpriteFactory.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViSpriteFactory.h"

namespace vi
{
    namespace scene
    {
        spriteFactory::spriteFactory()
        {
            mesh = new vi::common::mesh(4, 6);
            mesh->addVertex(0.0, 1.0, 0.0, 0.0);
            mesh->addVertex(1.0, 1.0, 1.0, 0.0);
            mesh->addVertex(1.0, 0.0, 1.0, 1.0);
            mesh->addVertex(0.0, 0.0, 0.0, 1.0);
            
            mesh->addIndex(0);
            mesh->addIndex(3);
            mesh->addIndex(1);
            mesh->addIndex(2);
            mesh->addIndex(1);
            mesh->addIndex(3);
            
            mesh->generateVBO();
        }
        
        spriteFactory::~spriteFactory()
        {
            delete mesh;
        }
        
    

        
        vi::scene::sprite *spriteFactory::createSprite(vi::graphic::texture *texture)
        {
            vi::scene::sprite *sprite = new vi::scene::sprite(texture, mesh);
            return sprite;
        }
        
        vi::common::mesh *spriteFactory::getMesh()
        {
            return mesh;
        }
    }
}
