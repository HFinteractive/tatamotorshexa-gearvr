// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_LightmapInd', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D
// Upgrade NOTE: replaced tex2D unity_LightmapInd with UNITY_SAMPLE_TEX2D_SAMPLER

Shader "Custom/GoochWrapDiffuse + Fog2"
{
  Properties {
    _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    _Ramp("Ramp", 2D) = "white" {}
    
    _SpecularColor ("Specular Color", Color) = (1,1,1,1)
    _SpecPower ("Specular Power", Range(0.1, 60)) = 3
    
    _RimColor("Rim Color", Color) = (0.26,0.19,0.16,0.0)
    _RimPower("Rim Power", Range(0.5, 10.0)) = 0.0
    
    _FogColor ("Fog Color", Color) = (1.0, 1.0, 1.0, 1.0)
    _FogStart("Fog Start", float) = 0.0
    _FogEnd("Fog End", float) = 1.0
    
    _Alpha("Alpha", Range(0,1.0)) = 1.0
    
  }
  SubShader {
    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
    LOD 200
    
    
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
#line 23 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

    //#pragma surface surf NPR alpha noambient
    //finalcolor:mycolor vertex:myvert

	uniform sampler2D _Ramp;
    uniform half4 _Color;
    uniform half4 _SpecularColor;
    uniform half _SpecPower;
    uniform fixed4 _RimColor;
    uniform fixed _RimPower;
    uniform half4 _FogColor;
    uniform half _FogStart;
    uniform half _FogEnd;
    uniform fixed _Alpha;

    struct Input {
      float2 uv_MainTex;
      half fog;
    };
    
    half4 LightingNPR(SurfaceOutput o, half3 lightdir, half3 viewDir, fixed atten)
	{
	    half lambert = (dot(o.Normal, lightdir));
	    lambert = lambert * 0.5 + 0.5;
	    fixed4 diff; 
	    //diff = fixed4(_LightColor0.rgb * 2 * lambert * atten * o.Albedo.rgb, 1.0);
	    //diff = fixed4(_LightColor0.rgb * 2 * atten * o.Albedo.rgb, 1.0);
	    diff = tex2D(_Ramp, fixed2(lambert, 0.0));
	    
	    float3 halfVector = normalize(lightdir + viewDir);
	    
	    float nh = max(0, dot(o.Normal, halfVector));
	    float spec = pow(nh, _SpecPower) * _SpecularColor;
	    
	    fixed rim_term = 1.0 - saturate(dot(viewDir, o.Normal));
	    rim_term = pow(rim_term, _RimPower);
	    fixed4 rim = fixed4(_RimColor.rgb * rim_term, 1.0); 
	    
	    fixed4 c;
	    c.rgb = (o.Albedo * _LightColor0.rgb * diff) * (atten * 2) + (_LightColor0.rgb * _SpecularColor.rgb * spec) + rim;
	    
	    c.a = o.Alpha;
	    
	    return c;
	}
	
	
//    void myvert (inout appdata_full v, out Input data) {
//      UNITY_INITIALIZE_OUTPUT(Input,data);
//      float pos = length(mul (UNITY_MATRIX_MV, v.vertex).xyz);
//      float diff = _FogEnd - _FogStart;
//      float invDiff = 1.0f / diff;
//      data.fog = clamp ((_FogEnd - pos) * invDiff, 0.0, 1.0);
//    }
//    void mycolor (Input IN, SurfaceOutput o, inout fixed4 color) {
//      fixed3 fogColor = _FogColor.rgb;
//      #ifdef UNITY_PASS_FORWARDADD
//      fogColor = 0;
//      #endif
//      color.rgb = lerp (fogColor, color.rgb, IN.fog);
//    }

    void surf (Input IN, inout SurfaceOutput o) {
      half4 c = _Color;
      o.Albedo = c.rgb;
      o.Alpha = _Alpha;
      
    }
    

// vertex-to-fragment interpolation data
#ifdef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  fixed3 normal : TEXCOORD0;
  fixed3 vlight : TEXCOORD1;
  float3 viewDir : TEXCOORD2;
  LIGHTING_COORDS(3,4)
};
#endif
#ifndef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float2 lmap : TEXCOORD0;
  LIGHTING_COORDS(1,2)
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
  #ifdef LIGHTMAP_OFF
  o.normal = worldN;
  #endif
  #ifdef LIGHTMAP_OFF
  float3 viewDirForLight = WorldSpaceViewDir( v.vertex );
  o.viewDir = viewDirForLight;
  #endif

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
  #ifdef LIGHTMAP_OFF
  o.Normal = IN.normal;
  #endif

  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  fixed atten = LIGHT_ATTENUATION(IN);
  fixed4 c = 0;

  // realtime lighting: call lighting function
  #ifdef LIGHTMAP_OFF
  c = LightingNPR (o, _WorldSpaceLightPos0.xyz, normalize(half3(IN.viewDir)), atten);
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
#line 23 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

    //#pragma surface surf NPR alpha noambient
    //finalcolor:mycolor vertex:myvert

	uniform sampler2D _Ramp;
    uniform half4 _Color;
    uniform half4 _SpecularColor;
    uniform half _SpecPower;
    uniform fixed4 _RimColor;
    uniform fixed _RimPower;
    uniform half4 _FogColor;
    uniform half _FogStart;
    uniform half _FogEnd;
    uniform fixed _Alpha;

    struct Input {
      float2 uv_MainTex;
      half fog;
    };
    
    half4 LightingNPR(SurfaceOutput o, half3 lightdir, half3 viewDir, fixed atten)
	{
	    half lambert = (dot(o.Normal, lightdir));
	    lambert = lambert * 0.5 + 0.5;
	    fixed4 diff; 
	    //diff = fixed4(_LightColor0.rgb * 2 * lambert * atten * o.Albedo.rgb, 1.0);
	    //diff = fixed4(_LightColor0.rgb * 2 * atten * o.Albedo.rgb, 1.0);
	    diff = tex2D(_Ramp, fixed2(lambert, 0.0));
	    
	    float3 halfVector = normalize(lightdir + viewDir);
	    
	    float nh = max(0, dot(o.Normal, halfVector));
	    float spec = pow(nh, _SpecPower) * _SpecularColor;
	    
	    fixed rim_term = 1.0 - saturate(dot(viewDir, o.Normal));
	    rim_term = pow(rim_term, _RimPower);
	    fixed4 rim = fixed4(_RimColor.rgb * rim_term, 1.0); 
	    
	    fixed4 c;
	    c.rgb = (o.Albedo * _LightColor0.rgb * diff) * (atten * 2) + (_LightColor0.rgb * _SpecularColor.rgb * spec) + rim;
	    
	    c.a = o.Alpha;
	    
	    return c;
	}
	
	
//    void myvert (inout appdata_full v, out Input data) {
//      UNITY_INITIALIZE_OUTPUT(Input,data);
//      float pos = length(mul (UNITY_MATRIX_MV, v.vertex).xyz);
//      float diff = _FogEnd - _FogStart;
//      float invDiff = 1.0f / diff;
//      data.fog = clamp ((_FogEnd - pos) * invDiff, 0.0, 1.0);
//    }
//    void mycolor (Input IN, SurfaceOutput o, inout fixed4 color) {
//      fixed3 fogColor = _FogColor.rgb;
//      #ifdef UNITY_PASS_FORWARDADD
//      fogColor = 0;
//      #endif
//      color.rgb = lerp (fogColor, color.rgb, IN.fog);
//    }

    void surf (Input IN, inout SurfaceOutput o) {
      half4 c = _Color;
      o.Albedo = c.rgb;
      o.Alpha = _Alpha;
      
    }
    

// vertex-to-fragment interpolation data
struct v2f_surf {
  float4 pos : SV_POSITION;
  fixed3 normal : TEXCOORD0;
  half3 lightDir : TEXCOORD1;
  half3 viewDir : TEXCOORD2;
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
  fixed4 c = LightingNPR (o, lightDir, normalize(half3(IN.viewDir)), LIGHT_ATTENUATION(IN));
  c.a = o.Alpha;
  return c;
}

ENDCG

}

	// ---- end of surface shader generated code

#LINE 93

  } 
  FallBack "Diffuse"
}
///*
//{
//    Properties
//    {
//        
//        _FogPower("FogPower", float) = 1.0
//        _FogColor("FogColor", Color) = (1.0, 1.0, 1.0, 1.0)
//    }
//    SubShader
//    {
//        Tags { "RenderType" = "Opaque" }
//
//        CGPROGRAM
//        #include "UnityCG.cginc"
//        #pragma surface surf NPR noambient
// 
//        uniform sampler2D _Ramp;
//        uniform fixed4 _Color;
//        uniform fixed4 _FogColor;
//        uniform fixed _FogPower;
// 		
//        half4 LightingNPR(SurfaceOutput o, half3 lightdir, half3 halfdir, fixed atten)
//        {
//            half lambert = saturate(dot(o.Normal, lightdir));
//            lambert = lambert * 0.5 + 0.5;
//            fixed4 diff; 
//            diff = fixed4(_LightColor0.rgb * 2 * lambert * atten * o.Albedo.rgb, 1.0);
//            //diff = fixed4(_LightColor0.rgb * 2 * atten * o.Albedo.rgb, 1.0);
//            //diff *= tex2D(_Ramp, fixed2(lambert, 0.0));
//            
//            //fixed4 sp = o.screenPos;
//            fixed fogFactor = pow(o.Specular, _FogPower);
//            return (1.0 - fogFactor) * diff + fogFactor * _FogColor;
//        }
// 
//        struct Input
//        {
//            half2 uv_MainTex;
//            fixed4 screenPos;
//        };
// 
//        void surf(Input IN, inout SurfaceOutput o)
//        {
//            o.Albedo = _Color.rgb;
//            o.Alpha = 1.0;
//            
//            float dist = IN.screenPos.z / IN.screenPos.w;
//            o.Specular = dist;
//
//        }
//        ENDCG
//    }
//    FallBack "Diffuse"
// 
//}