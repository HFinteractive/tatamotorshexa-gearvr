Shader "Reflective/UnlitCubemap"
{

	Properties
	{
		_Cube ("Reflection Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
		_Alpha ("Alpha", Range(0, 1)) = 0
	}

	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		
		Blend SrcAlpha OneMinusSrcAlpha
	
		CGPROGRAM
		#pragma surface surf UnlitCubemap

		samplerCUBE _Cube;
		fixed _Alpha;

		struct Input
		{
			float3 worldRefl;
		};

		fixed4 LightingUnlitCubemap (SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
			return fixed4(s.Albedo, _Alpha);
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			float3 s = IN.worldRefl;
			s.y *= -1;
			s.z *= -1;
			fixed4 reflcol = texCUBE (_Cube, s);
			o.Albedo = reflcol.rgb;
		}
		ENDCG
	}
	
	FallBack Off
} 
