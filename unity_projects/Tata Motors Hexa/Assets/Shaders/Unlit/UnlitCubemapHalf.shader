#warning Upgrade NOTE: unity_Scale shader variable was removed; replaced 'unity_Scale.w' with '1.0'

Shader "Reflective/UnlitCubemapHalf"
{
	Properties
	{
	[HideInInspector] _MainTex ("Base (RGB)", 2D) = "white" {}
		_Cube ("Reflection Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
		_CubeMask ("Mask Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
		_CutoffA("Cutoff A", float) = 1
		_CutoffB("Cutoff B", float) = 0
		_Intensity("Intensity", float) = 1.0
	}

	SubShader {
	
	Tags { "Queue"="Transparent" "RenderType"="Transparent"  }
	
	Blend SrcAlpha OneMinusSrcAlpha
	
		Pass { 
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			half _CutoffA;
			half _CutoffB;
			half _Intensity;
			
			sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			uniform samplerCUBE _Cube;
			uniform samplerCUBE _CubeMask;
			
			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half3 I : TEXCOORD1;
			};

			v2f vert(appdata_tan v)
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				// calculate world space reflection vector	
				float3 viewDir = WorldSpaceViewDir( v.vertex );
				float3 worldN = mul((float3x3)_Object2World, v.normal * 1.0);
				float3 refl = reflect( -viewDir, worldN );
				
				o.I = float3(refl.x, -refl.y, -refl.z);
				
				return o; 
			}

			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 reflcol = texCUBE( _Cube, i.I );
				fixed4 mask = texCUBE( _CubeMask, i.I );
								
				fixed c = step(_CutoffA, i.uv[0]);
				
				return fixed4(reflcol.rgb, c * mask.r * _Intensity);
				

			} 
			ENDCG
		}
	}
		
	FallBack Off
}

