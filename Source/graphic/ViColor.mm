//
//  ViColor.mm
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#import "ViColor.h"

namespace vi
{
    namespace graphic
    {
        color::color(GLfloat _r, GLfloat _g, GLfloat _b, GLfloat _a)
        {
            r = _r;
            g = _g;
            b = _b;
            a = _a;
        }
        
        color::color(color const& other)
        {
            r = other.r;
            g = other.g;
            b = other.b;
            a = other.a;
        }
        
        
        
        bool color::operator== (color const& other)
        {
            float absR = fabsf(r - other.r);
            float absG = fabsf(g - other.g);
            float absB = fabsf(b - other.b);
            float absA = fabsf(a - other.a);
            
            return (absR <= kViEpsilonFloat && absG <= kViEpsilonFloat && absB <= kViEpsilonFloat && absA <= kViEpsilonFloat);
        }
        
        bool color::operator!= (color const& other)
        {
            float absR = fabsf(r - other.r);
            float absG = fabsf(g - other.g);
            float absB = fabsf(b - other.b);
            float absA = fabsf(a - other.a);
            
            return (absR > kViEpsilonFloat || absG > kViEpsilonFloat || absB > kViEpsilonFloat || absA > kViEpsilonFloat); 
        }
        
        
        
        color color::operator= (color const& other)
        {
            r = other.r;
            g = other.g;
            b = other.b;
            a = other.a;
            
            return *this;
        }
        
        
        color color::operator+= (color const& other)
        {
            r += other.r;
            g += other.g;
            b += other.b;
            a += other.a;

            return *this;
        }
        
        color color::operator-= (color const& other)
        {
            r -= other.r;
            g -= other.g;
            b -= other.b;
            a -= other.a;
            
            return *this;
        }
        
        color color::operator*= (color const& other)
        {
            r *= other.r;
            g *= other.g;
            b *= other.b;
            a *= other.a;
            
            return *this;
        }
        
        color color::operator/= (color const& other)
        {
            r /= other.r;
            g /= other.g;
            b /= other.b;
            a /= other.a;
            
            return *this;
        }
        
        
        
        color color::operator+ (color const& other)
        {
            color result(*this);
            
            result.r += other.r;
            result.g += other.g;
            result.b += other.b;
            result.a += other.a;
            
            return result;
        }
        
        color color::operator- (color const& other)
        {
            color result(*this);
            
            result.r -= other.r;
            result.g -= other.g;
            result.b -= other.b;
            result.a -= other.a;
            
            return result;
        }
        
        color color::operator* (color const& other)
        {
            color result(*this);
            
            result.r *= other.r;
            result.g *= other.g;
            result.b *= other.b;
            result.a *= other.a;
            
            return result;
        }
        
        color color::operator/ (color const& other)
        {
            color result(*this);
            
            result.r /= other.r;
            result.g /= other.g;
            result.b /= other.b;
            result.a /= other.a;
            
            return result;
        }
        
        
        
        color color::operator+= (GLfloat other)
        {
            r += other;
            g += other;
            b += other;
            a += other;
            
            return *this;
        }
        
        color color::operator-= (GLfloat other)
        {
            r -= other;
            g -= other;
            b -= other;
            a -= other;
            
            return *this;
        }
        
        color color::operator*= (GLfloat other)
        {
            r *= other;
            g *= other;
            b *= other;
            a *= other;
            
            return *this;
        }
        
        color color::operator/= (GLfloat other)
        {
            r /= other;
            g /= other;
            b /= other;
            a /= other;
            
            return *this;
        }
        
        
        color color::operator+ (GLfloat other)
        {
            color result(*this);
            
            result.r += other;
            result.g += other;
            result.b += other;
            result.a += other;
            
            return result;
        }
        
        color color::operator- (GLfloat other)
        {
            color result(*this);
            
            result.r -= other;
            result.g -= other;
            result.b -= other;
            result.a -= other;
            
            return result;
        }
        
        color color::operator* (GLfloat other)
        {
            color result(*this);
            
            result.r *= other;
            result.g *= other;
            result.b *= other;
            result.a *= other;
            
            return result;
        }
        
        color color::operator/ (GLfloat other)
        {
            color result(*this);
            
            result.r /= other;
            result.g /= other;
            result.b /= other;
            result.a /= other;
            
            return result;
        }      
        
        
        
        void color::lerp(color const& col1, color const& col2, float fac)
        {
            float invfac = 1.0f - fac;
            
            r = col1.r * invfac + col2.r * fac;
            g = col1.g * invfac + col2.g * fac;
            b = col1.b * invfac + col2.b * fac;
            a = col1.a * invfac + col2.a * fac;
        }
        
        void color::grayscale()
        {
            float grayscale = (0.2125f * r) + (0.7154f * g) + (0.0721f * b);
            r = g = b = grayscale;
        }
    }
}
