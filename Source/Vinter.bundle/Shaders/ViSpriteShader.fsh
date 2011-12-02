//
//  ViSpriteShader.fsh
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

#if defined (GL_ES)
precision mediump float;
#endif

uniform sampler2D mTexture0;
varying vec2 texcoord;
varying vec4 color;

void main()
{
    gl_FragColor = texture2D(mTexture0, texcoord) * color;
    gl_FragColor *= color.a;
}
