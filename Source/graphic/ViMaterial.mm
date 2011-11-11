//
//  ViMaterial.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViMaterial.h"

namespace vi
{
    namespace graphic
    {
        material::material(vi::graphic::texture *texture, vi::graphic::shader *tshader)
        {
            this->loadDefaultSettings();
            if(texture)
            {
                textures.push_back(texture);
                texlocations.push_back(0);
            }
            
            drawMode = GL_TRIANGLES;
            shader = (tshader != NULL) ? tshader : shader::getDefaultShader();
        }
        
        
        void material::loadDefaultSettings()
        {
            shader = NULL;
            culling = true;
            cullMode = GL_CCW;
            
            blending = false;
            blendSource = GL_ONE;
            blendDestination = GL_ONE_MINUS_SRC_ALPHA;
        }
        
        
        
        bool material::addParameter(std::string const& name, void *data, materialParameterType type, uint32_t count, uint32_t size)
        {
            if(!shader)
            {
                ViLog(@"Trying to add custom shader parameter without a shader!");
                return false;
            }
            
            std::vector<materialParameter>::iterator iterator;
            for(iterator=parameter.begin(); iterator!=parameter.end(); iterator++)
            {
                materialParameter param = *iterator;
                if(param.name.compare(name) == 0)
                {
                    param.data = data;
                    param.type = type;
                    param.size = size;
                    param.count = count;
                    
                    return true;
                }
            }
            
            
            materialParameter param = materialParameter();
            param.location = glGetUniformLocation(shader->program, name.c_str());
            
            if(param.location == -1)
                return false;
                
            
            param.name = name;
            param.data = data;
            param.type = type;
            param.size = size;
            param.count = count;
            
            parameter.push_back(param);
            return true;
        }
        
        bool material::addAttribute(std::string const& name, void *data, GLenum type, uint32_t size, uint32_t stride)
        {
            if(!shader)
            {
                ViLog(@"Trying to add custom vertex attribute without a shader!");
                return false;
            }
            
            std::vector<vertexAttribute>::iterator iterator;
            for(iterator=attributes.begin(); iterator!=attributes.end(); iterator++)
            {
                vertexAttribute attribute = *iterator;
                if(attribute.name.compare(name) == 0)
                {
                    attribute.data = data;
                    attribute.type = type;
                    attribute.size = size;
                    attribute.stride = stride;
                    
                    return true;
                }
            }
            
            
            
            vertexAttribute attribute = vertexAttribute();
            attribute.location = glGetAttribLocation(shader->program, name.c_str());
            
            if(attribute.location == -1)
                return false;
            
            attribute.name = name;
            attribute.data = data;
            attribute.type = type;
            attribute.size = size;
            attribute.stride = stride;
            
            attributes.push_back(attribute);
            return true;
        }
    }
}
