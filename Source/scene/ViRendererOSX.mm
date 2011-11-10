//
//  ViRendererOSX.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import <Foundation/Foundation.h>
#import "ViRendererOSX.h"
#import "ViQuadtree.h"
#import "ViSceneNode.h"
#import "ViVector3.h"
#import "ViKernel.h"

namespace vi
{
    namespace graphic
    {
        rendererOSX::rendererOSX()
        {
            lastMesh = NULL;
            currentCamera = NULL;
            currentMaterial = NULL;
            
            uniformIvFuncs[0] = glUniform1iv;
            uniformIvFuncs[1] = glUniform2iv;
            uniformIvFuncs[2] = glUniform3iv;
            uniformIvFuncs[3] = glUniform4iv;
            
            uniformFvFuncs[0] = glUniform1fv;
            uniformFvFuncs[1] = glUniform2fv;
            uniformFvFuncs[2] = glUniform3fv;
            uniformFvFuncs[3] = glUniform4fv;
            
            uniformMatrixFvFuncs[0] = glUniformMatrix2fv;
            uniformMatrixFvFuncs[1] = glUniformMatrix3fv;
            uniformMatrixFvFuncs[2] = glUniformMatrix4fv;
        }
        
       
        
        void rendererOSX::renderSceneWithCamera(vi::scene::scene *scene, vi::scene::camera *camera, double timestep)
        {
            camera->bind();            
            currentCamera = camera;
            
            std::vector<vi::scene::sceneNode *> *nodes = scene->nodesInRect(camera->frame);
            this->renderNodeList(nodes, timestep, false);
            this->renderNodeList(scene->UINodes(), timestep, true);
            
            camera->unbind();
        }
        
        void rendererOSX::renderBatchList(std::vector<vi::scene::sceneNode *> *nodes, double timestep, bool uiNodes, vi::scene::sceneNode *parent)
        {
            vi::common::mesh *batchMesh = new vi::common::mesh((uint32_t)nodes->size() * 4, (uint32_t)nodes->size() * 6);
            vi::common::vector2 tsize = parent->getSize();
            
            std::vector<vi::scene::sceneNode *>::iterator iterator;
            
            for(iterator=nodes->begin(); iterator!=nodes->end(); iterator++)
            {
                vi::scene::sceneNode *node = *iterator;
                
                if(node->noPass == currentCamera)
                    continue;
                
                if(!uiNodes && node->getSize().length() > kViEpsilonFloat)
                {
                    if(!vi::common::rect(node->getPosition(), node->getSize()).intersectsRect(currentCamera->frame))
                        continue;
                }
                
                
                
                node->visit(timestep);
                
                vi::common::vector2 position = node->getPosition();
                position.y = -position.y;
                position.y += tsize.y - node->getSize().y;
                
                batchMesh->addMesh(node->mesh, position);
                
                
                if(node->hasChilds())
                {
                    vi::graphic::material *material = currentMaterial;
                    vi::common::vector2 nodePos = node->getPosition();
                    
                    translation += nodePos;
                    
                    if(node->getFlags() & vi::scene::sceneNodeFlagConcatenateChildren)
                    {
                        renderBatchList(node->getChilds(), timestep, uiNodes, node);
                    }
                    else
                    {
                        renderNodeList(node->getChilds(), timestep, uiNodes);
                    }
                    
                    translation -= nodePos;
                    setMaterial(material);
                }
            }
            
            renderMesh(batchMesh, uiNodes, parent->matrix);
            delete batchMesh;
        }
        
        void rendererOSX::renderNodeList(std::vector<vi::scene::sceneNode *> *nodes, double timestep, bool uiNodes)
        {
            std::vector<vi::scene::sceneNode *>::iterator iterator;
            
            for(iterator=nodes->begin(); iterator!=nodes->end(); iterator++)
            {
                vi::scene::sceneNode *node = *iterator;
                
                if(node->noPass == currentCamera)
                    continue;
                
                
                if(node->getSize().length() > kViEpsilonFloat)
                {
                    if(!vi::common::rect(node->getPosition(), node->getSize()).intersectsRect(currentCamera->frame) && !uiNodes)
                        continue;
                }

#ifndef NDEBUG
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 5
                if(glPushGroupMarkerEXT)
                    glPushGroupMarkerEXT(0, node->debugName ? node->debugName->c_str() : "scene node");
#endif
#endif
                
                node->visit(timestep);
                
                this->setMaterial(node->material);
                this->renderNode(node, uiNodes);
                
                if(node->hasChilds())
                {
                    vi::common::vector2 nodePos = node->getPosition();
                    translation += nodePos;
                    
                    if(node->getFlags() & vi::scene::sceneNodeFlagConcatenateChildren)
                    {
                        renderBatchList(node->getChilds(), timestep, uiNodes, node);
                    }
                    else
                    {
                        renderNodeList(node->getChilds(), timestep, uiNodes);
                    }
                    
                    translation -= nodePos;
                }
                
#ifndef NDEBUG
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 5
                if(glPopGroupMarkerEXT)
                    glPopGroupMarkerEXT();
#endif
#endif
            }
        }
        
        void rendererOSX::renderNode(vi::scene::sceneNode *node, bool isUINode)
        {
            if(!node->mesh)
                return;
            
            renderMesh(node->mesh, isUINode, node->matrix);
        }
        
        void rendererOSX::renderMesh(vi::common::mesh *mesh, bool isUIMesh, vi::common::matrix4x4 const& matrix)
        {
            vi::common::matrix4x4 cameraMatrix = !isUIMesh ? currentCamera->viewMatrix : vi::common::matrix4x4();
            
            if(isUIMesh)
                cameraMatrix.makeTranslate(vi::common::vector3(0.0, currentCamera->frame.size.y, 0.0));
            
            
            vi::common::matrix4x4 nodeMatrix = matrix;
            if(translation.length() >= kViEpsilonFloat)
                nodeMatrix.translate(vi::common::vector3(translation.x, -translation.y, translation.z));
            
            
            if(currentMaterial->shader->matProj != -1)
				glUniformMatrix4fv(currentMaterial->shader->matProj, 1, GL_FALSE, currentCamera->projectionMatrix.matrix);
            
            if(currentMaterial->shader->matView != -1)
                glUniformMatrix4fv(currentMaterial->shader->matView, 1, GL_FALSE, cameraMatrix.matrix);
			
            if(currentMaterial->shader->matModel != -1)
                glUniformMatrix4fv(currentMaterial->shader->matModel, 1, GL_FALSE, nodeMatrix.matrix);
            
            if(currentMaterial->shader->matProjViewModel != -1)
            {
                vi::common::matrix4x4 matProjViewModel = currentCamera->projectionMatrix * cameraMatrix * nodeMatrix;
                glUniformMatrix4fv(currentMaterial->shader->matProjViewModel, 1, GL_FALSE, matProjViewModel.matrix);
            }
            
            
            std::vector<vi::graphic::materialParameter>::iterator iterator;
            for(iterator=currentMaterial->parameter.begin(); iterator!=currentMaterial->parameter.end(); iterator++)
            {
                vi::graphic::materialParameter parameter = *iterator;
                
                if(parameter.location == -1)
                    continue;
                
                
                switch(parameter.type)
                {
                    case vi::graphic::materialParameterTypeInt:
                    {
                        uniformIvFuncs[parameter.count - 1](parameter.location, parameter.size, (const GLint *)parameter.data);
                    }
                        break;
                        
                    case vi::graphic::materialParameterTypeFloat:
                    {
                        uniformFvFuncs[parameter.count - 1](parameter.location, parameter.size, (const GLfloat *)parameter.data);
                    }
                        break;
                        
                    case vi::graphic::materialParameterTypeMatrix:
                    {
                        uniformMatrixFvFuncs[parameter.count - 2](parameter.location, parameter.size, GL_FALSE, (const GLfloat *)parameter.data);
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            
            if(mesh->vbo == -1)
            {
                glBindBuffer(GL_ARRAY_BUFFER, 0);
                
                if(lastMesh != mesh || mesh->dirty)
                {
                    lastMesh = mesh;
                    
                    if(currentMaterial->shader->position != -1)
                        glDisableVertexAttribArray(currentMaterial->shader->position);
                    
                    if(currentMaterial->shader->texcoord0 != -1)
                        glDisableVertexAttribArray(currentMaterial->shader->texcoord0);
                    
                    
                    
                    if(currentMaterial->shader->position != -1)
                    {
                        glEnableVertexAttribArray(currentMaterial->shader->position);
                        glVertexAttribPointer(currentMaterial->shader->position, 2, GL_FLOAT, 0, sizeof(vi::common::vertex), &mesh->vertices[0].x);
                    }
                    
                    if(currentMaterial->shader->texcoord0 != -1)
                    {
                        glEnableVertexAttribArray(currentMaterial->shader->texcoord0);
                        glVertexAttribPointer(currentMaterial->shader->texcoord0, 2, GL_FLOAT, 0, sizeof(vi::common::vertex), &mesh->vertices[0].u);
                    }
                }
            }
            else
            {
                if(lastMesh != mesh || mesh->dirty)
                {
                    glBindBuffer(GL_ARRAY_BUFFER, mesh->vbo);
                    
                    if(currentMaterial->shader->position != -1)
                        glDisableVertexAttribArray(currentMaterial->shader->position);
                    
                    if(currentMaterial->shader->texcoord0 != -1)
                        glDisableVertexAttribArray(currentMaterial->shader->texcoord0);
                    
                    
                    if(currentMaterial->shader->position != -1)
                    {
                        glEnableVertexAttribArray(currentMaterial->shader->position);
                        glVertexAttribPointer(currentMaterial->shader->position, 2, GL_FLOAT, 0, sizeof(vi::common::vertex), (const void *)0);
                    }
                    
                    if(currentMaterial->shader->texcoord0 != -1)
                    {
                        glEnableVertexAttribArray(currentMaterial->shader->texcoord0);
                        glVertexAttribPointer(currentMaterial->shader->texcoord0, 2, GL_FLOAT, 0, sizeof(vi::common::vertex), (const void *)8);
                    }
                }
            }
            
            
            if(mesh->ivbo == -1)
			{
				glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
				glDrawElements(currentMaterial->drawMode, mesh->indexCount, GL_UNSIGNED_SHORT, mesh->indices);
			}
            else
            {
                if(lastMesh != mesh || mesh->dirty)
                {
                    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh->ivbo);
                }
                
				glDrawElements(currentMaterial->drawMode, mesh->indexCount, GL_UNSIGNED_SHORT, 0);
			}
            
            lastMesh = mesh;
            lastMesh->dirty = false;
        }
        
        
        
        void rendererOSX::setMaterial(vi::graphic::material *material)
        {
            if(!material)
                return;
            
            if(!material->shader)
            {
                static bool complaintAboutShader = false;
                if(!complaintAboutShader)
                {
                    ViLog(@"Tried to enable a material in a shader based renderer but the material had no shader! This error will be reported once");
                    complaintAboutShader = true;
                }
                
                return;
            }
            
            if(currentMaterial != material)
            {
                glUseProgram(material->shader->program);
                
                if(!currentMaterial || (currentMaterial->textures != material->textures || currentMaterial->texlocations != material->texlocations))
                {
                    if(material->textures.size() > 0)
                    {
                        for(int i=0; i<material->texlocations.size(); i++)
                        {
                            if(material->texlocations[i] == -1)
                                break;
                            
                            glActiveTexture(GL_TEXTURE0 + i);
                            glBindTexture(GL_TEXTURE_2D, material->textures[i]->getTexture());
                        }
                    }
                }
                
                if(!currentMaterial || currentMaterial->culling != material->culling)
                {
                    if(material->culling)
                    {
                        glEnable(GL_CULL_FACE);
                        glFrontFace(material->cullMode);
                    }
                    else
                        glDisable(GL_CULL_FACE);
                }
                
                if(!currentMaterial || (currentMaterial->blending != material->blending || currentMaterial->blendSource != material->blendSource || currentMaterial->blendDestination != material->blendDestination))
                {
                    if(material->blending)
                    {
                        glEnable(GL_BLEND);
                        glBlendFunc(material->blendSource, material->blendDestination);
                    }
                    else
                        glDisable(GL_BLEND);
                }
                
                currentMaterial = material;
            }
        }
    }
}
