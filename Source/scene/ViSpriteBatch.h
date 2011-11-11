//
//  ViSpriteBatch.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <vector>
#import "ViBase.h"
#import "ViTexture.h"
#import "ViSceneNode.h"
#import "ViSprite.h"

namespace vi
{
    namespace scene
    {
        /**
         * @brief Contains a large amount of sprites for efficient rendering.
         *
         * A sprite batch should be used when you render a large amount of sprites sharing the same texture, the sprite batch
         * will automatically create one large mesh containing all sprites. Instead of adding each sprite to a scene, you just add the sprite batch
         * which will then automatically render the mesh.
         * @remark Since Vinter 0.4.0, sprite batches use the direct optimization step done by the renderer to draw many smaller objects at once!
         **/
        class spriteBatch : public sceneNode
        {
        public:
            /**
             * Constructor for a new sprite batch with the given texture.
             **/
            spriteBatch(vi::graphic::texture *texture=NULL);
            /**
             * Destructor.
             **/
            ~spriteBatch();
            
            
            /**
             * Adds a new sprite to the sprite batch and returns it.
             * @retval Pointer to the newly created sprite, you can then alter the sprite as if it was attached to the scene.
             * @sa generateMesh()
             **/
            vi::scene::sprite *addSprite();
            /**
             * Removes the given sprite.
             * @sa generateMesh()
             **/
            void removeSprite(vi::scene::sprite *sprite);
            
            /**
             * Sets a new texture.
             * @sa generateMesh()
             **/
            void setTexture(vi::graphic::texture *texture);
            
            /**
             * Deprecated in Vinter 0.4.0
             **/
            ViDeprecated void generateMesh(bool generateVBO=true);
        };
    }
}
