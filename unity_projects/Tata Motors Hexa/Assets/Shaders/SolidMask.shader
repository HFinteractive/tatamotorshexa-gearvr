Shader "Custom/SolidMask"
{
	Properties
	{
		[HideInInspector] _MainTex ("Base (RGB)", 2D) = "white" {}
		_Gray("Gray", float) = 1.0
		_Intensity("Intensity", float) = 1.0
	}

	SubShader
	{
		Tags {"RenderType"="Transparent" "Queue"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha
	
		Pass	
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			half _Intensity;
			half _Gray;

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
				return fixed4(_Gray,_Gray,_Gray,_Intensity);
			}

			ENDCG
		}
	}
}
