Shader "Custom/GoochWrapDiffuse + Fog"
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
    
    
  }
  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 200
    
    CGPROGRAM
    #pragma surface surf NPR
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
      o.Alpha = c.a;
    }
    ENDCG
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