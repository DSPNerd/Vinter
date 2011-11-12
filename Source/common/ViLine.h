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
        /**
         * @brief A simple line class
         *
         * The line class is mainly for intersection checking and there is currently no other usage in Vinter.
         **/
        class line
        {
        public:
            /**
             * Constructor
             **/
            line(vi::common::line const& line);
            /**
             * Constructor
             **/
            line(vi::common::vector2 const& start=vi::common::vector2(), vi::common::vector2 const& end=vi::common::vector2());
            
            /**
             * Returns true if the line intersects with the rectangle
             * @param intersection If set, contains the point of the intersection upon return.
             **/
            bool intersects(vi::common::rect const& rect, vi::common::vector2 *intersection);
            /**
             * Returns true if the line intersects with the line
             * @param intersection If set, contains the point of the intersection upon return.
             **/
            bool intersects(vi::common::line const& line, vi::common::vector2 *intersection);
            
            /**
             * Start point of the line
             **/
            vi::common::vector2 start;
            /**
             * End point of the line
             **/
            vi::common::vector2 end;
        };
    }
}
