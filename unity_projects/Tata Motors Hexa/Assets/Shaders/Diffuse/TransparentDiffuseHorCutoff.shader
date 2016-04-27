Shader "Transparent/TransparentDiffuseHorCutoff"
{
	Properties
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		[HideInInspector] _CutoffA("Cutoff A", float) = 1
		[HideInInspector] _CutoffB("Cutoff B", float) = 0
		_FogIntensity("Fog Intensity", Range(0.0, 1.0)) = 1.0
		[HideInInspector] _BadWeatherIntensity("Bad Weather Intensity", Range(0.0, 1.0)) = 1.0
	}

	SubShader
	{
		Tags {"Queue"="Transparent-1" "IgnoreProjector"="True" "RenderType"="Transparent" "MaskTag" = "MaskValue"}

		CGPROGRAM
		#pragma surface surf Unlit alpha

		sampler2D _MainTex;
		half _CutoffA;
		half _CutoffB;
		fixed _FogIntensity;

		struct Input
		{
			float2 uv_MainTex;
		};
		
		fixed4 LightingUnlit (SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
			return fixed4(s.Albedo * 0.5, s.Alpha);
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			o.Alpha = _FogIntensity;
	
			half y = _CutoffA * (1.0 - IN.uv_MainTex[1]) + _CutoffB;
	
			if((1.0 - IN.uv_MainTex[0]) > y)
				o.Alpha = 0;
		}
		
		ENDCG
	}

	Fallback "Transparent/VertexLit"
}
