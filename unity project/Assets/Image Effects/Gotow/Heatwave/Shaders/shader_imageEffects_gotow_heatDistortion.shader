
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

				sampler2D _MainTex;
				float4 _MainTex_ST;

				sampler2D _DistortionTex;
				float _Strength;

				float4 frag(v2f_img IN) : COLOR {
					// On non-GL when AA is used, the main texture and scene depth texture
					// will come out in different vertical orientations.
					// So flip sampling of the texture when that is the case (main texture
					// texel size will have negative Y).
					float2 distortionUv = IN.uv;
					#if UNITY_UV_STARTS_AT_TOP
					if (_MainTex_TexelSize.y < 0)
					        distortionUv.y = 1-distortionUv.y;
					#endif

					float3 distortion_normal = normalize( tex2D( _DistortionTex, distortionUv ).rgb - float3(0.5,0.5,0.5) );
					float2 uv_offset = refract( fixed3(0,0,1), distortion_normal, 1.0 ).xy * (0.01666) * _Strength;

					half4 c = tex2D (_MainTex, IN.uv + uv_offset);
					return c;
				}
			ENDCG
		}
	}
}
