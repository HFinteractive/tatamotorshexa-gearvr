Shader "Custom/AlphaWrapLambertRim" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_RimPower ("Rim Power", Float) = 3.0
	//_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
}

SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 200

CGPROGRAM
#pragma surface surf WrapLambert alpha noambient

//sampler2D _MainTex;
fixed4 _Color;
float _RimPower;

struct Input {
	float2 uv_MainTex;
	float3 viewDir;
};

half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten)
{
	half NdotL = dot (s.Normal, lightDir);
	half diffuse = max(0, NdotL* 0.9 + 0.1);
	half4 c;
	c.rgb = (atten * 2) * _LightColor0.rgb * diffuse;
	c.a = s.Alpha;
	return c;
}

void surf (Input IN, inout SurfaceOutput o)
{
	//fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	fixed4 c = _Color;
	o.Albedo = c.rgb;
	
	half viewFactor = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
	half rim = pow (viewFactor, _RimPower);
	o.Alpha = c.a + rim;
}
ENDCG
}

Fallback "Transparent/VertexLit"
}
