Shader "Unlit/TransparentScreenWithIntensity"
{
	Properties
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Intensity("Intensity", Range(0.0, 1.0)) = 1.0
	}

	SubShader
	{
		Tags {"Queue"="Transparent-1" "IgnoreProjector"="True" "RenderType"="Transparent"}

		ZWrite Off
		Fog { Mode off }
		Blend SrcAlpha OneMinusSrcAlpha 
		
		CGPROGRAM
		#pragma surface surf Unlit alpha

		sampler2D _MainTex;
		half _Intensity;

		struct Input
		{
			fixed2 uv_MainTex;
		};
		
		fixed4 LightingUnlit (SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
			return fixed4(s.Albedo * 0.5, s.Alpha);
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			o.Alpha = _Intensity;
		}
		
		ENDCG
	}

	Fallback "Unlit/Transparent"
}
