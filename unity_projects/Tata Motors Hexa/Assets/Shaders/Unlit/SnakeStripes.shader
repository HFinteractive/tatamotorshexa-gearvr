Shader "Custom/SnakeStripes"
{
	Properties
	{
		_ColorS ("Stripes", Color) = (1,1,1,1)
		_StripeWidth("Stripe Width", Float) = 20.0
		_StripeShift("Stripe Shift", Float) = 0
		_Mod("Mod", Float) = 2.0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
		}

		Cull Off
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
				float2 texcoord  : TEXCOORD0;
			};
			
			fixed4 _ColorS;

			float _StripeWidth;
			float _StripeShift;
			float _Mod;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.texcoord = IN.texcoord;
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				float x = IN.texcoord[0];
				//float y = IN.texcoord[1];
				
				float s2 = 1.0 - step(0, fmod(_StripeWidth * (fmod(x + _StripeShift * _Time, 1.0)), _Mod) - 1.0);
				//s2 += (1.0 - step(0, fmod(_StripeWidth * (fmod(x + _StripeShift * _Time, 1.0) + y + 1.0 ), _Mod) - 1.0));
				
				s2 = clamp(s2, 0, 1);
				
				return fixed4(_ColorS.rgb, s2 * _ColorS.a);

			}
		ENDCG
		}
		
		
		
		
	}
}
