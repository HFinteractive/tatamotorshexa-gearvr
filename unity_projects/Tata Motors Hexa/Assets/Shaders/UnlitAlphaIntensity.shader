Shader "Unlit/UnlitAlphaIntensity"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Intensity ("Intensity", Range(0.0, 1.0)) = 1.0
	}
	
	SubShader
	{
				
		Tags { "Queue" = "Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass 
		{
CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				half2 texcoord  : TEXCOORD0;
			};
			
			sampler2D _MainTex;
			fixed _Intensity;			

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.texcoord = IN.texcoord;
				return OUT;
			}
			

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, IN.texcoord);
				c.a *= _Intensity;
				return c;
			}
			
ENDCG
		}
	}
}
