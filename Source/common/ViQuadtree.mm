//
//  ViQuadtree.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <algorithm>
#import "ViQuadtree.h"
#import "ViSceneNode.h"

namespace vi
{
    namespace common
    {
        bool nodesPredicate(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB);
        bool nodesPredicate(vi::scene::sceneNode *nodeA, vi::scene::sceneNode *nodeB)
        {
            if(!nodeA)
                return false;
            
            if(!nodeB)
                return false;
            
            return nodeA->layer < nodeB->layer;
        }
        
        quadtree::quadtree(vi::common::rect const& rect, uint32_t subdivision)
        {
            frame = rect;
            divisions = subdivision;
            
            parent = NULL;
            
            subnodes[0] = NULL;
            subnodes[1] = NULL;
            subnodes[2] = NULL;
            subnodes[3] = NULL;
        }
        
        quadtree::~quadtree()
        {
            for(int i=0; i<4; i++)
            {
                if(subnodes[i])
                    delete subnodes[i];
            }
        }
            
        
        
        void quadtree::subdivide()
        {
            if(!subnodes[0])
            {
                CGFloat width  = frame.size.x * 0.5f;
                CGFloat height = frame.size.y * 0.5f;
                
                subnodes[0] = new quadtree(vi::common::rect(frame.left(), frame.top(), width, height), divisions - 1);
                subnodes[0]->parent = this;
                
                subnodes[1] = new quadtree(vi::common::rect(frame.left() + width, frame.top(), width, height), divisions - 1);
                subnodes[1]->parent = this;
                
                subnodes[2] = new quadtree(vi::common::rect(frame.left() + width, frame.top() + height, width, height), divisions - 1);
                subnodes[2]->parent = this;
                
                subnodes[3] = new quadtree(vi::common::rect(frame.left(), frame.top() + height, width, height), divisions - 1);
                subnodes[3]->parent = this;
            }
        }
        
        vi::common::rect quadtree::getFrame()
        {
            return frame;
        }
        
        
        void quadtree::_objectsInRect(vi::common::rect const& rect, std::vector<vi::scene::sceneNode *> *vector)
        {
            if(objects.size() > 0)
            {   
                std::vector<vi::scene::sceneNode *>::iterator iterator;
                for(iterator=objects.begin(); iterator!=objects.end(); iterator++)
                {
                    vi::scene::sceneNode *node = *iterator;
                    vector->push_back(node);
                }
            }
            
            if(subnodes[0])
            {
                for(int i=0; i<4; i++)
                {
                    if(subnodes[i]->getFrame().intersectsRect(rect))
                    {
                        subnodes[i]->_objectsInRect(rect, vector);
                    }
                }
            }
        }
        
        void quadtree::objectsInRect(vi::common::rect const& rect, std::vector<vi::scene::sceneNode *> *vector)
        {
            if(frame.intersectsRect(rect))
            {
                this->_objectsInRect(rect, vector);
                std::sort(vector->begin(), vector->end(), nodesPredicate);
            }
        }
        
        
        void quadtree::_insertObject(vi::scene::sceneNode *object)
        {
            if(object->tree == this)
                return;
            
            if(object->tree)
                object->tree->removeObject(object);
            
        
            objects.push_back(object);
            object->tree = this;
        }
        
        void quadtree::insertObject(vi::scene::sceneNode *object)
        {
            if((object->flags & vi::scene::sceneNodeFlagNoclip) || (object->flags & vi::scene::sceneNodeFlagDynamic))
            {
                if(parent)
                {
                    parent->insertObject(object);
                    return;
                }
              
                this->_insertObject(object);
                return;
            }
            
            
            vi::common::rect quad = vi::common::rect(object->getPosition(), object->getSize());
            if(!frame.containsRect(quad))
            {
                if(parent)
                    parent->insertObject(object);
                    
                return;
            }
            
            if(!subnodes[0] && divisions > 0)
            {
                this->subdivide();
            }
            
            if(subnodes[0])
            {
                for(int i=0; i<4; i++)
                {
                    if(subnodes[i]->getFrame().containsRect(quad))
                    {
                        subnodes[i]->insertObject(object);
                        return;
                    }
                }
            }
            
            this->_insertObject(object);
        }
        
        
        
        void quadtree::updateObject(vi::scene::sceneNode *object)
        {
            if((object->flags & vi::scene::sceneNodeFlagNoclip) || (object->flags & vi::scene::sceneNodeFlagDynamic))
            {
                if(parent)
                {
                    parent->updateObject(object);
                    return;
                }
                
                this->_insertObject(object);
                return;
            }
            
            
            vi::common::rect quad = vi::common::rect(object->getPosition(), object->getSize());
            if(!frame.containsRect(quad))
            {
                if(parent)
                    parent->updateObject(object);
                
                return;
            }
            
            
            if(!subnodes[0] && divisions > 0)
            {
                this->subdivide();
            }
            
            if(subnodes[0])
            {
                for(int i=0; i<4; i++)
                {
                    if(subnodes[i]->getFrame().containsRect(quad))
                    {
                        subnodes[i]->updateObject(object);
                        return;
                    }
                }
            }
            
            this->_insertObject(object);
        }
        
        void quadtree::removeObject(vi::scene::sceneNode *object)
        {
			if(!object->tree)
				return;
			
			if(object->tree != this)
			{
				object->tree->removeObject(object);
				return;
			}
			
            std::vector<vi::scene::sceneNode *>::iterator iterator;
            for(iterator=objects.begin(); iterator!=objects.end(); iterator++)
            {
                vi::scene::sceneNode *node = *iterator;
                if(node == object)
                {
                    objects.erase(iterator);
                    object->tree = NULL;
                    
                    break;
                }
            }
        }
        
        
        void quadtree::deleteAllObjects()
        {
            std::vector<vi::scene::sceneNode *>::iterator iterator;
            for(iterator=objects.begin(); iterator!=objects.end(); iterator++)
            {
                vi::scene::sceneNode *node = *iterator;
                node->tree = NULL;
                
                delete node;
            }
            
            objects.clear();
            
            if(subnodes[0])
            {
                for(int i=0; i<4; i++)
                {
                    subnodes[i]->deleteAllObjects();
                }
            }
        }
    }
}
