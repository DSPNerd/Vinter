//
//  ViParticleShader.fsh
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#if defined (GL_ES)
precision mediump float;
#else
#define lowp
#define mediump
#define highp
#endif

uniform lowp sampler2D mTexture0;
varying lowp vec4 color;
varying highp vec2 texcoord;

void main()
{
    gl_FragColor = texture2D(mTexture0, texcoord) * color;
    gl_FragColor *= color.a;
}
