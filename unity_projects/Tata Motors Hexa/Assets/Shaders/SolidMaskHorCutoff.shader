Shader "Custom/SolidMaskHorCutoff"
{
	Properties
	{
		[HideInInspector] _MainTex ("Base (RGB)", 2D) = "white" {}
		[HideInInspector] _CutoffA("Cutoff A", float) = 1
		[HideInInspector] _CutoffB("Cutoff B", float) = 0
		_Intensity("Intensity", Range(0.0, 1.0)) = 1.0
	}

	SubShader
	{
		Tags {"RenderType"="Opaque"}
	
		Pass	
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			half _CutoffA;
			half _CutoffB;
			half _Intensity;

			struct appdata_t
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};
			
			sampler2D _MainTex;
			half4 _MainTex_ST;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c;
				
				//half y = _CutoffA * (1.0 - i.texcoord[1]) + _CutoffB;
				//if((1.0 - i.texcoord[0]) < y)
				//	col = _Intensity;

				c = _Intensity * step(1.0 - _CutoffA - _CutoffB, i.texcoord[0] - _CutoffA * i.texcoord[1]);
				return c;
			}

			ENDCG
		}
	}
}
