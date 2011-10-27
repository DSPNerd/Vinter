//
//  ViLine.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViBase.h"
#import "ViVector2.h"
#import "ViRect.h"

namespace vi
{
    namespace common
    {
        class line
        {
        public:
            line(vi::common::line const& line);
            line(vi::common::vector2 const& start=vi::common::vector2(), vi::common::vector2 const& end=vi::common::vector2());
            
            bool intersects(vi::common::rect const& rect, vi::common::vector2 *intersection);
            bool intersects(vi::common::line const& line, vi::common::vector2 *intersection);
            
            
            vi::common::vector2 start;
            vi::common::vector2 end;
        };
    }
}
