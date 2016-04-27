Shader "Custom/Stripes"
{
	Properties
	{
		_ColorS ("Stripes", Color) = (1,1,1,1)
		_ColorB ("Band", Color) = (1,1,1,1)
		_StripeWidth("Stripe Width", Float) = 20.0
		_BandCenter("Band Center", Float) = 0.5
		_BandWidth("Band Width", Float) = 0.15
		_StripeShift("Stripe Shift", Float) = 0
		_BottomLimit("Bottom Limit", Float) = 0
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

		Cull Back
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
			fixed4 _ColorB;
			float _StripeWidth;
			float _BandCenter;
			float _BandWidth;
			float _StripeShift;
			float _BottomLimit;
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
				float y = IN.texcoord[1];
				
				float s1 = step(_BandCenter - _BandWidth, x) * (1.0 - step(_BandCenter + _BandWidth,x)) * step(_BottomLimit, 1.0 - y);
				float s2 = 1.0 - step(0, fmod(_StripeWidth * (fmod(x + _StripeShift * _Time, 1.0) - y + 1.0 ), _Mod) - 1.0);
				//s2 += (1.0 - step(0, fmod(_StripeWidth * (fmod(x + _StripeShift * _Time, 1.0) + y + 1.0 ), _Mod) - 1.0));
				
				s2 = clamp(s2, 0, 1);
				
				return s1 * _ColorB + (1.0 - s1) * fixed4(_ColorS.rgb, s2 * _ColorS.a);

			}
		ENDCG
		}
		
		
		
		
	}
}
