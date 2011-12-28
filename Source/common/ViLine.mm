//
//  ViLine.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViLine.h"

namespace vi
{
    namespace common
    {
        line::line(vi::common::line const& line)
        {
            start = line.start;
            end = line.end;
        }
        
        line::line(vi::common::vector2 const& tstart, vi::common::vector2 const& tend)
        {
            start = tstart;
            end = tend;
        }
        
        bool line::intersects(vi::common::rect const& rect, vi::common::vector2 *intersection)
        {
            for(int i=0; i<4; i++)
            {
                line tline;
                switch(i)
                {
                    case 0:
                        tline = vi::common::line(vi::common::vector2(rect.left(), rect.bottom()), vi::common::vector2(rect.left(), rect.top()));
                        break;
                        
                    case 1:
                        tline = vi::common::line(vi::common::vector2(rect.left(), rect.top()), vi::common::vector2(rect.right(), rect.top()));
                        break;
                        
                    case 2:
                        tline = vi::common::line(vi::common::vector2(rect.right(), rect.top()), vi::common::vector2(rect.right(), rect.bottom()));
                        break;
                    
                    case 3:
                        tline = vi::common::line(vi::common::vector2(rect.right(), rect.bottom()), vi::common::vector2(rect.left(), rect.bottom()));
                        break;
                }
                
                
                bool result = intersects(tline, intersection);
                if(result)
                    return true;
            }
            
            return false;
        }
        
        bool line::intersects(vi::common::line const& tline, vi::common::vector2 *intersection)
        {
            float x1, y1, x2, y2, s, t;
            x1 = end.x - start.x;     
            y1 = end.y - start.y;
            x2 = tline.end.x - tline.start.x;    
            y2 = tline.end.y - tline.start.y;
            
            
            s = (-y1 * (start.x - tline.start.x) + x1 * (start.y - tline.start.y)) / (-x2 * y1 + x1 * y2);
            t = ( x2 * (start.y - tline.start.y) - y2 * (start.x - tline.start.x)) / (-x2 * y1 + x1 * y2);
            
            
            if(s >= 0.0f && s <= 1.0f && t >= 0.0f && t <= 1.0f)
            {
                if(intersection)
                {
                    intersection->x = start.x + (t * x1);
                    intersection->y = start.y + (t * y1);
                }
                
                return true;
            }
            
            return false;
        }
    }
}
