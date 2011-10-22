//
//  ViShader.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViShader.h"
#import "ViDataPool.h"
#import "ViKernel.h"
#import "ViContext.h"

namespace vi
{
    namespace graphic
    {
        shader::shader(std::string vertexFile, std::string fragmentFile)
        {            
            generateShaderFromPaths(vertexFile, fragmentFile);
        }
        
        shader::shader(defaultShader shader)
        {
            switch (shader)
            {
                case defaultShaderTexture:
                    generateShaderFromPaths("/Vinter.bundle/Shaders/ViTextureShader.vsh", "/Vinter.bundle/Shaders/ViTextureShader.fsh");
                    break;
                    
                case defaultShaderShape:
                    generateShaderFromPaths("/Vinter.bundle/Shaders/ViShapeShader.vsh", "/Vinter.bundle/Shaders/ViShapeShader.fsh");
                    break;
                    
                case defaultShaderSprite:
                    generateShaderFromPaths("/Vinter.bundle/Shaders/ViSpriteShader.vsh", "/Vinter.bundle/Shaders/ViSpriteShader.fsh");
                    break;
                    
                default:
                    throw "Unknown default shader!";
                    break;
            }
        }
        
        shader::~shader()
        {
            if(program != -1)
                glDeleteProgram(program);
        }
        
        
        shader *shader::getDefaultShader()
        {
            vi::common::context *context = vi::common::context::getActiveContext();
            assert(context);
            
            shader *contextShader = context->getShader(vi::graphic::defaultShaderTexture);
            return contextShader;
        }
        
        
        
        void shader::generateShaderFromPaths(std::string vertexFile, std::string fragmentFile)
        {
            bool result;
            
            matProj = -1;
            matView = -1;
            matModel = -1;
            matProjViewModel = -1;
            
            position = -1;
            texcoord0 = -1;
            texcoord1 = -1;
            
            program = -1;
            
            @autoreleasepool
            {
                std::string vertexPath = vi::common::dataPool::pathForFile(vertexFile);
                std::string fragmentPath = vi::common::dataPool::pathForFile(fragmentFile);
                
                result = (vertexPath.length() > 0 && fragmentPath.length() > 0);
                if(result)
                    result = create([NSString stringWithUTF8String:vertexPath.c_str()], [NSString stringWithUTF8String:fragmentPath.c_str()]);
            }
            
            if(!result)
                throw "Failed to create shader!";
        }
        
        
        void shader::getUniforms()
        {            
            matProj = glGetUniformLocation(program, "matProj");
            matView = glGetUniformLocation(program, "matView");
            matModel = glGetUniformLocation(program, "matModel");
            matProjViewModel = glGetUniformLocation(program, "matProjViewModel");
            
            position = glGetAttribLocation(program, "vertPos");
            texcoord0 = glGetAttribLocation(program, "vertTexcoord0");
            texcoord1 = glGetAttribLocation(program, "vertTexcoord1");
        }
        
        
        
        bool shader::linkProgram()
        {
            GLint status, length;
            
            glLinkProgram(program);
            
            glGetProgramiv(program, GL_INFO_LOG_LENGTH, &length);
            glGetProgramiv(program, GL_LINK_STATUS, &status);
            
            if(length > 0)
            {
                GLchar *log = (GLchar *)malloc(length);
                glGetProgramInfoLog(program, length, &length, log);
                
                ViLog(@"Program link log:\n %s", log);
                free(log);
            }
            
            if(status == 0)
                return false;
            
            return true;
        }
        
        
        bool shader::compileShader(GLuint *shader, GLenum type, NSString *path)
        {
            GLint status, length;
            const GLchar *source = NULL;
            NSString *data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            
            
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
            GLuint glslVersion = vi::common::context::getActiveContext()->getGLSLVersion();
            data = [NSString stringWithFormat:@"#version %i\n%@", glslVersion, data];
#endif
            
            source = [data UTF8String];          
            if(!source)
                return false;
            
            *shader = glCreateShader(type);
            glShaderSource(*shader, 1, &source, NULL);
            glCompileShader(*shader);
            
            glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &length);
            glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
            if(length > 0)
            {
                GLchar *log = (GLchar *)malloc(length);
                glGetShaderInfoLog(*shader, length, &length, log);
                
                ViLog(@"%@: Shader compile log:\n%s", path, log);
                free(log);
            }
            
            if(status == 0)
                return false;
            
            return true;
        }
        
        bool shader::create(NSString *vertexPath, NSString *fragmentPath)
        {
            GLuint vertexShader = -1;
            GLuint fragmentShader = -1;
            
            program = glCreateProgram();
            if(program == -1)
            {
                ViLog(@"Failed to create program!");
                return false;
            }
            
            if(!compileShader(&vertexShader, GL_VERTEX_SHADER, vertexPath))
            {
                ViLog(@"Failed to create vertex shader!");
                return false;
            }
            
            if(!compileShader(&fragmentShader, GL_FRAGMENT_SHADER, fragmentPath))
            {
                ViLog(@"Failed to create fragment shader!");
                return false;
            }
            
            
            glAttachShader(program, vertexShader);
            glAttachShader(program, fragmentShader);
            
            if(!linkProgram())
            {
                ViLog(@"Failed to link program!");
                
                if(vertexShader != -1)
                {
                    glDeleteShader(vertexShader);
                    glDetachShader(program, vertexShader);
                }
                
                if(fragmentShader != -1)
                {
                    glDeleteShader(fragmentShader);
                    glDetachShader(program, fragmentShader);
                }
                
                if(program != -1)
                    glDeleteProgram(program);
                
                return false;
            }
            
            if(vertexShader != -1)
            {
                glDeleteShader(vertexShader);
                glDetachShader(program, vertexShader);
            }
            
            if(fragmentShader != -1)
            {
                glDeleteShader(fragmentShader);
                glDetachShader(program, fragmentShader);
            }
            
            getUniforms();
            vi::common::kernel::sharedKernel()->checkError();
            
            return true;
        }
    }
}
