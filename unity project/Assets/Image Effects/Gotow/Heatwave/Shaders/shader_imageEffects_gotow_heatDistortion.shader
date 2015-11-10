
Shader "Hidden/ImageEffects/Gotow/HeatDistortion" {

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
					float3 distortion_normal = normalize( tex2D( _DistortionTex, IN.uv ).rgb - float3(0.5,0.5,0.5) );
					float2 uv_offset = refract( fixed3(0,0,1), distortion_normal, 1.0 ).xy * (0.01666) * _Strength;

					half4 c = tex2D (_MainTex, IN.uv + uv_offset);
					return c;
				}
			ENDCG
		}
	}
}
