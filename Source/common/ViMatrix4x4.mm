//
//  ViMatrix4x4.cpp
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <cmath>
#import "ViMatrix4x4.h"
#import "ViVector3.h"

namespace vi
{
    namespace common
    {
        matrix4x4::matrix4x4()
        {
            makeIdentity();
        }
        
        matrix4x4::matrix4x4(matrix4x4 const& other)
        {
            memcpy(matrix, other.matrix, 16 * sizeof(float));
        }
        
        
        bool matrix4x4::operator== (matrix4x4 const& other)
        {
            for(int i=0; i<16; i++)
            {
                if(fabsf(matrix[i] - other.matrix[i]) >= kViEpsilonFloat)
                {
                    return false;
                }
            }
            
            return true;
        }
        
        bool matrix4x4::operator!= (matrix4x4 const& other)
        {
            for(int i=0; i<16; i++)
            {
                if(fabsf(matrix[i] - other.matrix[i]) >= kViEpsilonFloat)
                {
                    return true;
                }
            }
            
            return false;
        }
        
        
        
        
        matrix4x4 matrix4x4::operator= (matrix4x4 const& other)
        {
            set((float *)other.matrix);
            return *this;
        }
        
        matrix4x4 matrix4x4::operator= (float *other)
        {
            this->set(other);
            return *this;
        }
        
        
        
        matrix4x4 matrix4x4::operator* (matrix4x4 const& other)
        {
            matrix4x4 res(*this);
            res *= other;
            return res;
        }
        
        matrix4x4 matrix4x4::operator*= (matrix4x4 const& other)
        {            
#ifdef __ARM_NEON__
            // Inspired by http://blogs.arm.com/software-enablement/241-coding-for-neon-part-3-matrix-multiplication/
            // Tried to write this not in assembler for nearly three hours and gave up... srsly, WTF?!

            __asm__ volatile 
            (
             // Load both source matrices into NEON registers...
             "vldmia %1, {q4-q7}              \n\t"
             "vldmia %2, {q8-q11}             \n\t"
             
             // Multiply the first column with the first row and store the value into another NEON register
             "vmul.f32 q0, q8, d8[0]          \n\t"
             "vmul.f32 q1, q8, d10[0]         \n\t"
             "vmul.f32 q2, q8, d12[0]         \n\t"
             "vmul.f32 q3, q8, d14[0]         \n\t"
             
             // Now multiply the second column with the second row, add the previous result to it and profit from the fast path optimization
             "vmla.f32 q0, q9, d8[1]          \n\t"
             "vmla.f32 q1, q9, d10[1]         \n\t"
             "vmla.f32 q2, q9, d12[1]         \n\t"
             "vmla.f32 q3, q9, d14[1]         \n\t"
             
             // Cloumn 3 * Row 3
             "vmla.f32 q0, q10, d9[0]         \n\t"
             "vmla.f32 q1, q10, d11[0]        \n\t"
             "vmla.f32 q2, q10, d13[0]        \n\t"
             "vmla.f32 q3, q10, d15[0]        \n\t"
             
             // Cloumn 4 * Row 4
             "vmla.f32 q0, q11, d9[1]         \n\t"
             "vmla.f32 q1, q11, d11[1]        \n\t"
             "vmla.f32 q2, q11, d13[1]        \n\t"
             "vmla.f32 q3, q11, d15[1]        \n\t"
             
             // Writeout the result from the NEON register
             "vstmia %0, {q0-q3}"
             : : "r" (&matrix), "r" (&other.matrix), "r" (&matrix)
             : "memory", "q0", "q1", "q2", "q3", "q4", "q5", "q6", "q7", "q8", "q9", "q11");
#else
            matrix4x4 temp(*this);
            
            matrix[0] = temp.matrix[0]*other.matrix[0]+temp.matrix[4]*other.matrix[1]+temp.matrix[8]*other.matrix[2]+temp.matrix[12]*other.matrix[3];
            matrix[1] = temp.matrix[1]*other.matrix[0]+temp.matrix[5]*other.matrix[1]+temp.matrix[9]*other.matrix[2]+temp.matrix[13]*other.matrix[3];
            matrix[2] = temp.matrix[2]*other.matrix[0]+temp.matrix[6]*other.matrix[1]+temp.matrix[10]*other.matrix[2]+temp.matrix[14]*other.matrix[3];
            matrix[3] = temp.matrix[3]*other.matrix[0]+temp.matrix[7]*other.matrix[1]+temp.matrix[11]*other.matrix[2]+temp.matrix[15]*other.matrix[3];
            
            matrix[4] = temp.matrix[0]*other.matrix[4]+temp.matrix[4]*other.matrix[5]+temp.matrix[8]*other.matrix[6]+temp.matrix[12]*other.matrix[7];
            matrix[5] = temp.matrix[1]*other.matrix[4]+temp.matrix[5]*other.matrix[5]+temp.matrix[9]*other.matrix[6]+temp.matrix[13]*other.matrix[7];
            matrix[6] = temp.matrix[2]*other.matrix[4]+temp.matrix[6]*other.matrix[5]+temp.matrix[10]*other.matrix[6]+temp.matrix[14]*other.matrix[7];
            matrix[7] = temp.matrix[3]*other.matrix[4]+temp.matrix[7]*other.matrix[5]+temp.matrix[11]*other.matrix[6]+temp.matrix[15]*other.matrix[7];
            
            matrix[8] = temp.matrix[0]*other.matrix[8]+temp.matrix[4]*other.matrix[9]+temp.matrix[8]*other.matrix[10]+temp.matrix[12]*other.matrix[11];
            matrix[9] = temp.matrix[1]*other.matrix[8]+temp.matrix[5]*other.matrix[9]+temp.matrix[9]*other.matrix[10]+temp.matrix[13]*other.matrix[11];
            matrix[10] = temp.matrix[2]*other.matrix[8]+temp.matrix[6]*other.matrix[9]+temp.matrix[10]*other.matrix[10]+temp.matrix[14]*other.matrix[11];
            matrix[11] = temp.matrix[3]*other.matrix[8]+temp.matrix[7]*other.matrix[9]+temp.matrix[11]*other.matrix[10]+temp.matrix[15]*other.matrix[11];
            
            matrix[12] = temp.matrix[0]*other.matrix[12]+temp.matrix[4]*other.matrix[13]+temp.matrix[8]*other.matrix[14]+temp.matrix[12]*other.matrix[15];
            matrix[13] = temp.matrix[1]*other.matrix[12]+temp.matrix[5]*other.matrix[13]+temp.matrix[9]*other.matrix[14]+temp.matrix[13]*other.matrix[15];
            matrix[14] = temp.matrix[2]*other.matrix[12]+temp.matrix[6]*other.matrix[13]+temp.matrix[10]*other.matrix[14]+temp.matrix[14]*other.matrix[15];
            matrix[15] = temp.matrix[3]*other.matrix[12]+temp.matrix[7]*other.matrix[13]+temp.matrix[11]*other.matrix[14]+temp.matrix[15]*other.matrix[15];
#endif
            
            return *this;
        }

        
        
        void matrix4x4::translate(vector3 const& trans)
        {
            matrix4x4 transMatrix;
            transMatrix.makeTranslate(trans);
            
            *this *= transMatrix;
        }
        
        void matrix4x4::scale(vector3 const& scal)
        {
            matrix4x4 temp = matrix4x4();
            
            temp.matrix[0] = scal.x;
            temp.matrix[5] = scal.y;
            temp.matrix[10] = scal.z;
            
            *this *= temp;
        }
        
        void matrix4x4::rotate(GLfloat angle, vector3 const& rot)
        {
            float x=rot.x, y=rot.y, z=rot.z;
            float sinAngle, cosAngle;
            float mag = sqrtf(x * x + y * y + z * z);
            
            sinAngle = sinf(angle);
            cosAngle = cosf(angle);
            
            if(mag > kViEpsilonFloat)
            {
                float xx, yy, zz, xy, yz, zx, xs, ys, zs;
                float oneMinusCos;
                
                x /= mag;
                y /= mag;
                z /= mag;
                
                xx = x * x;
                yy = y * y;
                zz = z * z;
                xy = x * y;
                yz = y * z;
                zx = z * x;
                xs = x * sinAngle;
                ys = y * sinAngle;
                zs = z * sinAngle;
                oneMinusCos = 1.0f - cosAngle;		
                
                
                matrix4x4 rotMat;
                rotMat.matrix[0] = (oneMinusCos * xx) + cosAngle;
                rotMat.matrix[1] = (oneMinusCos * xy) - zs;
                rotMat.matrix[2] = (oneMinusCos * zx) + ys;
                
                rotMat.matrix[4] = (oneMinusCos * xy) + zs;
                rotMat.matrix[5] = (oneMinusCos * yy) + cosAngle;
                rotMat.matrix[6] = (oneMinusCos * yz) - xs;
                
                rotMat.matrix[8] = (oneMinusCos * zx) - ys;
                rotMat.matrix[9] = (oneMinusCos * yz) + xs;
                rotMat.matrix[10] = (oneMinusCos * zz) + cosAngle;
                
                *this *= rotMat;
            }
        }
        
        
        
    
        
        void matrix4x4::makeTranslate(vector3 const& trans)
        {
            makeIdentity();
            
            matrix[12] = trans.x;
            matrix[13] = trans.y;
            matrix[14] = trans.z;
            matrix[15] = 1.0f;
        }
        
        void matrix4x4::makeScale(vector3 const& scal)
        {
            makeIdentity();
            
            matrix[0] = scal.x;
            matrix[5] = scal.y;
            matrix[10] = scal.z;
            matrix[15] = 1.0f;
        }

        void matrix4x4::makeRotation(GLfloat angle, vector3 const& rot)
        {
            float x=rot.x, y=rot.y, z=rot.z;
            float sinAngle, cosAngle;
            float mag = sqrtf(x * x + y * y + z * z);
            
            sinAngle = sinf(angle);
            cosAngle = cosf(angle);
            
            if(mag > kViEpsilonFloat)
            {
                float xx, yy, zz, xy, yz, zx, xs, ys, zs;
                float oneMinusCos;
                
                x /= mag;
                y /= mag;
                z /= mag;
                
                xx = x * x;
                yy = y * y;
                zz = z * z;
                xy = x * y;
                yz = y * z;
                zx = z * x;
                xs = x * sinAngle;
                ys = y * sinAngle;
                zs = z * sinAngle;
                oneMinusCos = 1.0f - cosAngle;		
                
                
                matrix4x4 rotMat;
                rotMat.matrix[0] = (oneMinusCos * xx) + cosAngle;
                rotMat.matrix[1] = (oneMinusCos * xy) - zs;
                rotMat.matrix[2] = (oneMinusCos * zx) + ys;
                
                rotMat.matrix[4] = (oneMinusCos * xy) + zs;
                rotMat.matrix[5] = (oneMinusCos * yy) + cosAngle;
                rotMat.matrix[6] = (oneMinusCos * yz) - xs;
                
                rotMat.matrix[8] = (oneMinusCos * zx) - ys;
                rotMat.matrix[9] = (oneMinusCos * yz) + xs;
                rotMat.matrix[10] = (oneMinusCos * zz) + cosAngle;
                
                *this *= rotMat;
            }
        }
        
        
        void matrix4x4::makeIdentity()
        {
            memset(matrix, 0, 16 * sizeof(float));
            
            matrix[0] = 1.0f;
            matrix[5] = 1.0f;
            matrix[10] = 1.0f;
            matrix[15] = 1.0f;
        }
		
		void matrix4x4::makeProjectionOrtho(float left, float right, float bottom, float top, float clipnear, float clipfar)
		{
			makeIdentity();
			
			float r_l = right - left;
			float t_b = top - bottom;
			float f_n = clipfar - clipnear;
			float tx = - (right + left) / (right - left);
			float ty = - (top + bottom) / (top - bottom);
			float tz = - (clipfar + clipnear) / (clipfar - clipnear);
			
			matrix[0] = 2.0f / r_l;
			matrix[5] = 2.0 / t_b;
			matrix[10] = -2.0f / f_n;
			
			matrix[12] = tx;
			matrix[13] = ty;
			matrix[14] = tz;
			matrix[15] = 1.0f;
		}
    }
}