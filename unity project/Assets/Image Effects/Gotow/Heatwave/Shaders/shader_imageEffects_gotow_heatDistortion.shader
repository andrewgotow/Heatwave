
Shader "Hidden/ImageEffects/Gotow/HeatDistortion" {

	// Copyright (c) 2015, Andrew Gotow.

	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:

	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.

	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.

	// This is the heat distortion post effect shader, and is very simple.
	// It samples the provided distortion texture, and offsets the uvs of they
	// input texture, creating a cheap, and simple "distortion" effect. Note
	// that this is not a correct refraction, and will not perform complex optical
	// feats, such as seeing around corners, and other lensing effects, it is built
	// for speed and "looking decent", rather than for accuracy.

	Properties {
		_MainTex ("Render Input", 2D) = "white" {}
		_DistortionTex ("Normal Map", 2D) = "white" {}
		_Strength ("Strength", Range(0,1) ) = 0.1
	}
	SubShader {
		ZTest Always Cull Off ZWrite Off Fog { Mode Off }
		
		Pass {
			CGPROGRAM
				#pragma vertex vert_img
				#pragma fragment frag
				#include "UnityCG.cginc"

				UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex)
				UNITY_DECLARE_SCREENSPACE_TEXTURE(_DistortionTex)
				float _Strength;

				float4 frag(v2f_img IN) : COLOR {
					float3 wNorm = UNITY_SAMPLE_SCREENSPACE_TEXTURE( _DistortionTex, IN.uv ).rgb * 2 - 1;
					float3 vNorm = mul((float3x3)unity_WorldToCamera, wNorm);
					
					// The 100 is just to adjust the range to something more reasonable.
					// This takes place in UV space, so a value of 1 will offset by the entire
					// width of the display.
					float scale = _Strength / 100;
					float2 uv_offset = refract( float3(0,0,1), vNorm, 1.0 ).xy * scale;

					return UNITY_SAMPLE_SCREENSPACE_TEXTURE(_MainTex, IN.uv + uv_offset);
				}
			ENDCG
		}
	}
}
