//
//  ViSprite.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViBase.h"
#import "ViSceneNode.h"
#import "ViTexture.h"
#import "ViRenderer.h"

namespace vi
{
    namespace scene
    {
        class spriteBatch;
        
        /**
         * @brief A simple sprite with support for atlas mapping
         *
         * A sprite is a rectangular object which renders a texture or a part of an texture into its rectangle.
         **/
        class sprite : public sceneNode
        {
            friend class spriteBatch;
        public:
            /**
             * Constructor
             * @param texture The texture for the sprite or NULL. The sprite will automatically update its size to the size of the texture.
             * @param upsideDown true if the sprite should be rendered upside down, otherwise false
             **/
            sprite(vi::graphic::texture *texture, bool upsideDown=false);
            /**
             * Constructor for a sprite with a shared mesh.
             **/
            sprite(vi::graphic::texture *texture, vi::common::mesh *sharedMesh);
            /**
             * Constructor for a sprite with a shared material
             * @remark The sprite information inside the material is always used if available.
             **/
            sprite(vi::graphic::texture *texture, vi::graphic::material *sharedMaterial);
            /**
             * Constructor for a sprite with a shared mesh and material
             * @remark The sprite information inside the material is always used if available.
             **/
            sprite(vi::graphic::texture *texture, vi::common::mesh *sharedMesh, vi::graphic::material *sharedMaterial);
            
            /**
             * Destructor. Automatically deletes the material and in case that the sprite doesn't share a mesh, it also deletes the mes.
             **/
            virtual ~sprite();
            
            /**
             * Updates the size of the sprite
             * @sa setWriteSizeInformationIntoMesh()
             **/
            virtual void setSize(vi::common::vector2 const& size);
            
            /**
             * Sets a new texture. The sprite will automatically update its atlas information according to the new texture when using this function.
             * @param texture The new texture.
             **/
            void setTexture(vi::graphic::texture *texture);
            /**
             * Sets new atlas informations. The atlas information is used to render only a part of the texture, defined by begin and size.
             **/
            void setAtlas(vi::common::vector2 const& begin, vi::common::vector2 const& size);
            
            /**
             * Tells the sprite to write atlas information into the UV members of the mesh
             **/
            void setWriteAtlasInformationIntoMesh();
            /**
             * Tells the sprite to write the size information into the mesh instead of using matrix scalation
             **/
            void setWriteSizeInformationIntoMesh();
            
            /**
             * Prepares the matrix of the sprite for drawing
             **/
            virtual void visit(double timestep);
            
        protected:     
            vi::common::vector2 atlasBegin;
            vi::common::vector2 atlasSize;
            
            struct
            {
                GLfloat atlasX, atlasY; // Translation
                GLfloat atlasZ, atlasW;
            };
            
        private:
            void createFromMeshAndMaterial(vi::graphic::texture *texture, vi::common::mesh *sharedMesh, vi::graphic::material *sharedMaterial);
            
            bool writeAtlasInfoIntoMesh;
            bool writeSizeInformationIntoMesh;
            
            bool isUpsideDown;
            bool ownsMesh;
            bool ownsMaterial;
        };
    }
}
