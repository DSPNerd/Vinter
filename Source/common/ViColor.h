//
//  ViColor.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViBase.h"

namespace vi
{
    namespace common
    {
        /**
         * @brief RGBA color class
         * @details This class wraps a color with four floating point channels. A valid color channel goes from 0.0 to 1.0, however, you can set channels to
         * other values like -0.1 if you need to do color caluclations.
         **/
        class color
        {
        public:
            /**
             * @brief Constructor
             * @param r The red component
             * @param g The green component
             * @param b The blue component
             * @param a The alpha component
             **/
            color(GLfloat r=0.0, GLfloat g=0.0, GLfloat b=0.0, GLfloat a=1.0);
            /**
             * @brief Copy constructor
             **/
            color(color const& other);
            
            
            bool operator== (color const& other);
            bool operator!= (color const& other);
            
            color operator= (color const& other);
            color operator- ();
            
            color operator+= (color const& other);
            color operator-= (color const& other);
            color operator*= (color const& other);
            color operator/= (color const& other);
            
            color operator+ (color const& other);
            color operator- (color const& other);
            color operator* (color const& other);
            color operator/ (color const& other);
            
            
            color operator+= (GLfloat other);
            color operator-= (GLfloat other);
            color operator*= (GLfloat other);
            color operator/= (GLfloat other);
            
            color operator+ (GLfloat other);
            color operator- (GLfloat other);
            color operator* (GLfloat other);
            color operator/ (GLfloat other);
            
            
            
            /**
             * @brief Interpolates between the two colors by the given factor.
             * @details The components of the color will be set to the result of the linear interpolation between color1 and color2.
             * @param color1 The first color, eg. the start color
             * @param color2 The second color, eg. the end color
             * @param factor The factor of the interpolation, starting by 0.0 for the first color and ending at 1.0 for the second color.
             **/
            void lerp(color const& color1, color const& color2, GLfloat factor);
            
            /**
             * @brief Converts the color to an grayscale representation of itself.
             **/
            void grayscale();

            
            struct
            {
                /**
                 * @brief The red component
                 **/
                GLfloat r;
                /**
                 * @brief The green component
                 **/
                GLfloat g;
                /**
                 * @brief The blue component
                 **/
                GLfloat b;
                /**
                 * @brief The alpha component
                 **/
                GLfloat a;
            };
        };
    }
}
