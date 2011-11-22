//
//  ViAnimation.h
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#include <math.h>
#include <tr1/functional>

namespace vi
{
    namespace animation
    {
        typedef enum
        {
            animationCurveLinearTweening,
            animationCurveQuadraticEaseIn,
            animationCurveQuadraticEaseOut,
            animationCurveQuadraticEaseInOut,
            animationCurveSinusoidalEaseIn,
            animationCurveSinusoidalEaseOut,
            animationCurveSinusoidalEaseInOut,
            animationCurveExponentialEaseIn,
            animationCurveExponentialEaseOut,
            animationCurveExponentialEaseInOut,
            animationCurveCircularEaseIn,
            animationCurveCircularEaseOut,
            animationCurveCircularEaseInOut,
            animationCurveCubicEaseIn,
            animationCurveCubicEaseOut,
            animationCurveCubicEaseInOut,
            animationCurveQuarticEaseIn,
            animationCurveQuarticEaseOut,
            animationCurveQuarticEaseInOut,
            animationCurveQuinticEaseIn,
            animationCurveQuinticEaseOut,
            animationCurveQuinticEaseInOut
        } animationCurve;
        
        
        class animation
        {
        public:
            virtual void setAnimationCurve(animationCurve tcurve) {curve = tcurve;}
            virtual void setDuration(double tduration) {duration = tduration;}
            
            virtual void reverse() {};
            virtual void updateValues() {}
            virtual void apply(double time) {}
            
        protected:
            double duration;
            animationCurve curve;
        };
        
        
        template <typename T>
        class basicAnimation : public animation
        {
        public:            
            basicAnimation()
            {
                duration = 0.0;
                applyPtr = NULL;
            }
            
            
            
            void setApplyProperty(T *tapplyPtr)
            {
                applyPtr = tapplyPtr;
            }
            
            void setApplyCallback(std::tr1::function<void (T)> callback)
            {
                applyCallback = callback;
            }
            
            void setValues(T tstartValue, T tendValue)
            {
                startValue = tstartValue;
                endValue = tendValue;
            }
            
            
            
            
            virtual void setDuration(double tduration)
            {
                duration = tduration;
                change = (endValue - startValue);
            }
            
            virtual void updateValues()
            {
                if(applyPtr)
                {
                    T currentValue = *applyPtr;
                    
                    startValue = currentValue;
                    endValue = startValue + change;
                }
            }
            
            virtual void reverse()
            {
                T temp = startValue;
                
                startValue = endValue;
                endValue   = temp;
                
                change = (endValue - startValue);
            }
            
            
            virtual T getByValue(double time)
            {                
                switch(curve) 
                {
                    case animationCurveLinearTweening:
                        return startValue + (change * time / duration);
                        break;
                        
                    // Quadratic easing
                    case animationCurveQuadraticEaseIn:
                    {
                        double t = time / duration;
                        return startValue + (change * t * t);
                        break;
                    }
                    
                    case animationCurveQuadraticEaseOut:
                    {
                        double t = time / duration;
                        return startValue + (-change * t * (t - 2.0));
                        break;
                    }
                    
                    case animationCurveQuadraticEaseInOut:
                    {
                        double t = time / (duration / 2.0);
                        if(t < 1.0)
                            return startValue + (change / 2.0 * t * t);
                        
                        t -= 1.0;                        
                        return startValue + (-change / 2.0 * (t * (t - 2.0) - 1.0));
                        break;
                    }
                        
                        
                    // Sinusoidal easing
                    case animationCurveSinusoidalEaseIn:
                    {
                        return startValue + (-change * cos(time / duration * M_PI_2) + change);
                        break;
                    }
                        
                    case animationCurveSinusoidalEaseOut:
                    {
                        return startValue + (change * sin(time / duration * M_PI_2));
                        break;
                    }
                        
                    case animationCurveSinusoidalEaseInOut:
                    {
                        return startValue + (-change / 2.0 * (cos(M_PI * time / duration) - 1.0));
                        break;
                    }
                        
                        
                    // Exponential easing
                    case animationCurveExponentialEaseIn:
                    {
                        return startValue + (change * pow(2.0, 10 * (time / duration - 1.0)));
                        break;
                    }
                        
                    case animationCurveExponentialEaseOut:
                    {
                        return startValue + (change * (-pow(2.0, - 10.0 * time / duration) + 1.0));
                        break;
                    }
                        
                    case animationCurveExponentialEaseInOut:
                    {
                        double t = time / (duration / 2.0);
                        if(t < 1.0)
                            return startValue + (change / 2.0 * pow(2.0, 10.0 * (time - 1.0)));
                        
                        time -= 1.0;
                        return startValue + (change / 2.0 * (-pow(2.0, -10 * time) + 2.0));
                        break;
                    }
                        
                    // Circular easing
                    case animationCurveCircularEaseIn:
                    {
                        double t = time / duration;
                        return startValue + (-change * (sqrt(1.0 - t * t) - 1.0));
                        break;
                    }
                        
                    case animationCurveCircularEaseOut:
                    {
                        double t = time / duration;
                        t -= 1.0;
                        
                        return startValue + (change * sqrt(1.0 - t * t));
                        break;
                    }
                        
                    case animationCurveCircularEaseInOut:
                    {
                        double t = time / (duration / 2.0);
                        if(t < 1.0)
                            return startValue + (-change / 2.0 * (sqrt(1.0 - t * t) - 1.0));
                        
                        t -= 2.0;
                        return startValue + (change / 2.0 * (sqrt(1.0 - t * t) + 1.0));
                        break;
                    }
                        
                    // Cubic easing
                    case animationCurveCubicEaseIn:
                    {
                        double t = time / duration;
                        return startValue + (change * t * t * t);
                        break;
                    }
                        
                    case animationCurveCubicEaseOut:
                    {
                        double t = time / duration;
                        t -= 1.0;
                        
                        return startValue + (change * (t * t * t + 1.0));
                        break;
                    }
                        
                    case animationCurveCubicEaseInOut:
                    {
                        double t = time / (duration / 2.0);
                        if(t < 1.0)
                            return startValue + (change / 2.0 * t * t * t);
                        
                        t -= 2.0;
                        return startValue + (change / 2.0 * (t * t * t + 2.0));
                        break;
                    }
                        
                        
                    // Quartic easing
                    case animationCurveQuarticEaseIn:
                    {
                        double t = time / duration;
                        return startValue + (change * t * t * t * t);
                        break;
                    }
                        
                    case animationCurveQuarticEaseOut:
                    {
                        double t = time / duration;
                        t -= 1.0;
                        
                        return startValue + (-change * (t * t * t * t - 1.0));
                        break;
                    }
                        
                    case animationCurveQuarticEaseInOut:
                    {
                        double t = time / (duration / 2.0);
                        if(t < 1.0)
                            return startValue + (change / 2.0 * t * t * t * t);
                        
                        t -= 2.0;
                        return startValue + (-change / 2.0 * (t * t * t * t - 2.0));
                        break;
                    }
                        
                    // Quintic easing
                    case animationCurveQuinticEaseIn:
                    {
                        double t = time / duration;
                        return startValue + (change * t * t * t * t * t);
                        break;
                    }
                        
                    case animationCurveQuinticEaseOut:
                    {
                        double t = time / duration;
                        t -= 1.0;
                        
                        return startValue + (change * (t * t * t * t * t + 1.0));
                        break;
                    }
                        
                    case animationCurveQuinticEaseInOut:
                    {
                        double t = time / (duration / 2.0);
                        if(t < 1.0)
                            return startValue + (change / 2.0 * t * t * t * t * t);
                        
                        t -= 2.0;
                        return startValue + (change / 2.0 * (t * t * t * t * t + 2.0));
                        break;
                    }
                        
                    default:
                        break;
                }
                
                
                return startValue + (change * time / duration);
            }
            
            virtual void apply(double time)
            {
                T value = getByValue(time);
                
                if(applyPtr)
                    *applyPtr = value;
                
                if(applyCallback)
                    applyCallback(value);
            }
            
        protected:
            double duration;
            std::tr1::function<void (T)> applyCallback;
            
            T startValue;
            T endValue;
            T change;
            T *applyPtr;
        };
    }
}
