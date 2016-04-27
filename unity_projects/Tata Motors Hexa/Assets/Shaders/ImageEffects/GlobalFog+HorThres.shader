Shader "Custom/GlobalFog+HorThres" {
Properties
{
	_MainTex ("Base (RGB)", 2D) = "black" {}
	//_HorScale ("Horizontal Scale", Float) = 1.0	
	_HorCutoff ("Horizontal Cutoff", Float) = 0.0
	_FogTex("Fog Texture", 2D) = "white" {}
}

CGINCLUDE

	#include "UnityCG.cginc"

	uniform sampler2D _MainTex;
	uniform sampler2D _FogTex;
	uniform fixed _HorCutoff;
	uniform sampler2D_float _CameraDepthTexture;
	
	uniform float _GlobalDensity;
	uniform float4 _FogColor;
	uniform float4 _StartDistance;
	uniform float4 _Y;
	uniform float4 _MainTex_TexelSize;
	
	// for fast world space reconstruction
	
	uniform float4x4 _FrustumCornersWS;
	uniform float4 _CameraWS;
	 
	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float2 uv_depth : TEXCOORD1;
		float4 interpolatedRay : TEXCOORD2;
	};
	
	v2f vert( appdata_img v )
	{
		v2f o;
		half index = v.vertex.z;
		v.vertex.z = 0.1;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = v.texcoord.xy;
		o.uv_depth = v.texcoord.xy;
		
		#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
			o.uv.y = 1-o.uv.y;
		#endif				
		
		o.interpolatedRay = _FrustumCornersWS[(int)index];
		o.interpolatedRay.w = index;
		
		return o;
	}
	
	float ComputeFogForYAndDistance (in float3 camDir, in float3 wsPos) 
	{
		float fogInt = saturate(length(camDir) * _StartDistance.x-1.0) * _StartDistance.y;	
		float fogVert = max(0.0, (wsPos.y-_Y.x) * _Y.y);
		fogVert *= fogVert; 
		return (1-exp(-_GlobalDensity*fogInt)) * exp (-fogVert);
	}
	
	float ComputeHorizontalLimit(in float4 camDir, in float4 wsPos, in float2 uv)
	{
		float horF = 1.0;
		
//		if(wsPos.x > _HorScale)
//		{
//			horF = 0;
//		}
//		else if(wsPos.x > 0 && wsPos.x < _HorScale)
//		{
//			//horF = -pow(1.0/scale * wsPos.x,1.0) + 1.0;
//			horF = -(1.0/_HorScale * wsPos.x) + 1.0;
//		}
		
		//if(uv[0] > _HorCutoff)
		if(wsPos.x > _HorCutoff)
	
		{
			horF = 0;
		}		
		
		return horF;
	}
	
	// No Horizontal limit
	
	half4 fragAbsoluteYAndDistance (v2f i) : SV_Target
	{
		float dpth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
		float4 wsDir = dpth * i.interpolatedRay;
		float4 wsPos = _CameraWS + wsDir;

		return lerp(tex2D(_MainTex, i.uv), _FogColor, ComputeFogForYAndDistance(wsDir.xyz,wsPos.xyz));
	}

	half4 fragRelativeYAndDistance (v2f i) : SV_Target
	{
		float dpth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
		float4 wsDir = dpth * i.interpolatedRay;
		return lerp(tex2D(_MainTex, i.uv), _FogColor, ComputeFogForYAndDistance(wsDir.xyz, wsDir.xyz));
	}

	half4 fragAbsoluteY (v2f i) : SV_Target
	{
		float dpth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
		float4 wsPos = (_CameraWS + dpth * i.interpolatedRay);
		float fogVert = max(0.0, (wsPos.y-_Y.x) * _Y.y);
		fogVert *= fogVert; 
		fogVert = (exp (-fogVert));
		return lerp(tex2D( _MainTex, i.uv ), _FogColor, fogVert);				
	}

	half4 fragDistance (v2f i) : SV_Target
	{
		float dpth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));		
		float4 camDir = ( /*_CameraWS  + */ dpth * i.interpolatedRay);
		float fogInt = saturate(length( camDir ) * _StartDistance.x - 1.0) * _StartDistance.y;	
		return lerp(_FogColor, tex2D(_MainTex, i.uv), exp(-_GlobalDensity*fogInt));				
	}

	// Horizontal Limit - TODO: the other three options
	
	half4 fragAbsoluteYAndDistanceHorLimit (v2f i) : SV_Target
	{
		float dpth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
		float4 wsDir = dpth * i.interpolatedRay;
		float4 wsPos = _CameraWS + wsDir;
		
		float horF = ComputeHorizontalLimit(wsDir,wsPos, i.uv);
		
		return lerp(tex2D(_MainTex, i.uv), _FogColor * tex2D(_FogTex, i.uv), horF * ComputeFogForYAndDistance(wsDir.xyz,wsPos.xyz));
	}

ENDCG

SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

		CGPROGRAM

		#pragma vertex vert
		#pragma fragment fragAbsoluteYAndDistance
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma exclude_renderers flash
		
		ENDCG
	}

	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

		CGPROGRAM

		#pragma vertex vert
		#pragma fragment fragAbsoluteY
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma exclude_renderers flash
		
		ENDCG
	}

	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

		CGPROGRAM

		#pragma vertex vert
		#pragma fragment fragDistance
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma exclude_renderers flash
		
		ENDCG
	}

	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

		CGPROGRAM

		#pragma vertex vert
		#pragma fragment fragRelativeYAndDistance
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma exclude_renderers flash
		
		ENDCG
	}
	
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

		CGPROGRAM

		#pragma vertex vert
		#pragma fragment fragAbsoluteYAndDistanceHorLimit
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma exclude_renderers flash
		
		ENDCG
	}
	
}

Fallback off

}