// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_LightmapInd', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D
// Upgrade NOTE: replaced tex2D unity_LightmapInd with UNITY_SAMPLE_TEX2D_SAMPLER

//http://www.mathopenref.com/graphfunctions.html?fx=pow(x, a)&xh=1&xl=0&yh=1&yl=0&ah=10&al=0.1&a=1
Shader "Custom/AlphaUnlitRim"
{
Properties
{
	_Color ("Main Color", Color) = (1,1,1,1)
	_Gamma ("Gamma", Range(0.1, 10)) = 1.0
	//_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_MinAlpha ("Min Alpha", Float) = 0.0
	_MaxAlpha ("Max Alpha", Float) = 1.0
}

SubShader
{

	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

	// ------------------------------------------------------------
	// Surface shader code generated out of a CGPROGRAM block:
	Alphatest Greater 0 ZWrite Off ColorMask RGB
	

	// ---- forward rendering base pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
		Blend SrcAlpha OneMinusSrcAlpha

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma multi_compile_fwdbasealpha nodirlightmap
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

// Original surface shader snippet:
#line 21 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

//#pragma surface surf Unlit alpha noambient

//sampler2D _MainTex;
fixed4 _Color;
fixed _Gamma;
fixed _MinAlpha;
fixed _MaxAlpha;

struct Input
{
	fixed2 uv_MainTex;
	fixed3 viewDir;
};

half4 LightingUnlit (SurfaceOutput s, fixed3 lightDir, fixed atten)
{
	return half4(s.Albedo, s.Alpha);
}

void surf (Input IN, inout SurfaceOutput o)
{
	//fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	
	half viewFactor = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
	half rim = pow (viewFactor, _Gamma);
	fixed alpha = ((_MaxAlpha - _MinAlpha) * rim) + _MinAlpha;
	o.Alpha = alpha;
	o.Albedo = _Color.rgb;
}


// vertex-to-fragment interpolation data
#ifdef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float3 viewDir : TEXCOORD0;
  fixed3 normal : TEXCOORD1;
  fixed3 vlight : TEXCOORD2;
  LIGHTING_COORDS(3,4)
};
#endif
#ifndef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float3 viewDir : TEXCOORD0;
  fixed3 normal : TEXCOORD1;
  float2 lmap : TEXCOORD2;
  LIGHTING_COORDS(3,4)
};
#endif
#ifndef LIGHTMAP_OFF
// float4 unity_LightmapST;
#endif

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
  #ifndef LIGHTMAP_OFF
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif
  float3 worldN = mul((float3x3)_Object2World, SCALED_NORMAL);
  o.normal = worldN;
  float3 viewDirForLight = WorldSpaceViewDir( v.vertex );
  o.viewDir = viewDirForLight;

  // SH/ambient and vertex lights
  #ifdef LIGHTMAP_OFF
  o.vlight = 0.0;
  #ifdef VERTEXLIGHT_ON
  float3 worldPos = mul(_Object2World, v.vertex).xyz;
  o.vlight += Shade4PointLights (
    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
    unity_4LightAtten0, worldPos, worldN );
  #endif // VERTEXLIGHT_ON
  #endif // LIGHTMAP_OFF

  // pass lighting information to pixel shader
  TRANSFER_VERTEX_TO_FRAGMENT(o);
  return o;
}
#ifndef LIGHTMAP_OFF
// sampler2D unity_Lightmap;
#ifndef DIRLIGHTMAP_OFF
// sampler2D unity_LightmapInd;
#endif
#endif

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  // prepare and unpack data
  #ifdef UNITY_COMPILER_HLSL
  Input surfIN = (Input)0;
  #else
  Input surfIN;
  #endif
  surfIN.viewDir = IN.viewDir;
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutput o = (SurfaceOutput)0;
  #else
  SurfaceOutput o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  o.Gloss = 0.0;
  o.Normal = IN.normal;

  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  fixed atten = LIGHT_ATTENUATION(IN);
  fixed4 c = 0;

  // realtime lighting: call lighting function
  #ifdef LIGHTMAP_OFF
  c = LightingUnlit (o, _WorldSpaceLightPos0.xyz, atten);
  #endif // LIGHTMAP_OFF || DIRLIGHTMAP_OFF
  #ifdef LIGHTMAP_OFF
  c.rgb += o.Albedo * IN.vlight;
  #endif // LIGHTMAP_OFF

  // lightmaps:
  #ifndef LIGHTMAP_OFF
    #ifndef DIRLIGHTMAP_OFF
      // directional lightmaps
      fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy);
      fixed4 lmIndTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd,unity_Lightmap, IN.lmap.xy);
      half3 lm = LightingLambert_DirLightmap(o, lmtex, lmIndTex, 0).rgb;
    #else // !DIRLIGHTMAP_OFF
      // single lightmap
      fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy);
      fixed3 lm = DecodeLightmap (lmtex);
    #endif // !DIRLIGHTMAP_OFF

    // combine lightmaps with realtime shadows
    #ifdef SHADOWS_SCREEN
      #if (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)) && defined(SHADER_API_MOBILE)
      c.rgb += o.Albedo * min(lm, atten*2);
      #else
      c.rgb += o.Albedo * max(min(lm,(atten*2)*lmtex.rgb), lm*atten);
      #endif
    #else // SHADOWS_SCREEN
      c.rgb += o.Albedo * lm;
    #endif // SHADOWS_SCREEN
  c.a = o.Alpha;
  #endif // LIGHTMAP_OFF

  c.a = o.Alpha;
  return c;
}

ENDCG

}

	// ---- forward rendering additive lights pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardAdd" }
		ZWrite Off Blend One One Fog { Color (0,0,0,0) }
		//Blend SrcAlpha One
		Blend SrcAlpha OneMinusSrcAlpha

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma multi_compile_fwdadd nodirlightmap
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_FORWARDADD
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

// Original surface shader snippet:
#line 21 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

//#pragma surface surf Unlit alpha noambient

//sampler2D _MainTex;
fixed4 _Color;
fixed _Gamma;
fixed _MinAlpha;
fixed _MaxAlpha;

struct Input
{
	fixed2 uv_MainTex;
	fixed3 viewDir;
};

half4 LightingUnlit (SurfaceOutput s, fixed3 lightDir, fixed atten)
{
	return half4(s.Albedo, s.Alpha);
}

void surf (Input IN, inout SurfaceOutput o)
{
	//fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	
	half viewFactor = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
	half rim = pow (viewFactor, _Gamma);
	fixed alpha = ((_MaxAlpha - _MinAlpha) * rim) + _MinAlpha;
	o.Alpha = alpha * _Color.a;
	o.Albedo = _Color.rgb;
}


// vertex-to-fragment interpolation data
struct v2f_surf {
  float4 pos : SV_POSITION;
  float3 viewDir : TEXCOORD0;
  fixed3 normal : TEXCOORD1;
  half3 lightDir : TEXCOORD2;
  LIGHTING_COORDS(3,4)
};

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
  o.normal = mul((float3x3)_Object2World, SCALED_NORMAL);
  float3 lightDir = WorldSpaceLightDir( v.vertex );
  o.lightDir = lightDir;
  float3 viewDirForLight = WorldSpaceViewDir( v.vertex );
  o.viewDir = viewDirForLight;

  // pass lighting information to pixel shader
  TRANSFER_VERTEX_TO_FRAGMENT(o);
  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  // prepare and unpack data
  #ifdef UNITY_COMPILER_HLSL
  Input surfIN = (Input)0;
  #else
  Input surfIN;
  #endif
  surfIN.viewDir = IN.viewDir;
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutput o = (SurfaceOutput)0;
  #else
  SurfaceOutput o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  o.Gloss = 0.0;
  o.Normal = IN.normal;

  // call surface function
  surf (surfIN, o);
  #ifndef USING_DIRECTIONAL_LIGHT
  fixed3 lightDir = normalize(IN.lightDir);
  #else
  fixed3 lightDir = IN.lightDir;
  #endif
  fixed4 c = LightingUnlit (o, lightDir, LIGHT_ATTENUATION(IN));
  c.a = o.Alpha;
  return c;
}

ENDCG

}

	// ---- end of surface shader generated code

#LINE 53


}

Fallback "Transparent/VertexLit"
}
