//
//  ViTextureShader.vsh
//  Vinter
//
//  Copyright 2011 by Nils Daumann and Sidney Just. All rights reserved.
//  Unauthorized use is punishable by torture, mutilation, and vivisection.
//

attribute vec2 vertPos;
attribute vec2 vertTexcoord0;
attribute vec4 vertColor;

uniform vec4 atlasTranslation;
uniform mat4 matProjViewModel;

varying vec2 texcoord;
varying vec4 color;

void main()
{
    color = vertColor;
    texcoord = (vertTexcoord0.xy * atlasTranslation.zw) + atlasTranslation.xy;
    gl_Position = matProjViewModel * vec4(vertPos, 1.0, 1.0);
}
