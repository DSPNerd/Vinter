//
//  ViParticleShader.vsh
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

attribute vec2 vertPos;
attribute vec2 vertTexcoord0;
attribute vec4 vertColor;

uniform mat4 matProjViewModel;
varying vec2 texcoord;
varying vec4 color;

void main()
{
    texcoord = vertTexcoord0;
    color = vertColor;
    
    gl_Position = matProjViewModel * vec4(vertPos, 1.0, 1.0);
}
