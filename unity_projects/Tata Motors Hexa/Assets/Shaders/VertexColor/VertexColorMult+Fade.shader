Shader "Custom/VertexColorMult+Fade"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
	}
		
    SubShader
    {
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		Lighting Off
		Blend One One
			
		CGPROGRAM
		
		#pragma surface surf UNLIT alpha noambient
		
		half4 _Color;
		
		struct Input
			{
		    	float2 uv_MainTex;
		    	float4 color: Color; // Vertex color
			};
		
		half4 LightingUNLIT(SurfaceOutput o, half3 lightdir, half3 halfdir, fixed atten)
			{
			    return half4(o.Albedo, _Color.a);
			}

			void surf (Input IN, inout SurfaceOutput o)
			{
			    o.Albedo = IN.color.rgb * _Color.rgb; // vertex RGB
			    o.Alpha = _Color.a;
			}
			
		ENDCG
			
//		CGPROGRAM
//		
//		#pragma surface surf UNLIT  noambient
//		
//		half4 _Color;
//		
//		struct Input
//			{
//		    	float2 uv_MainTex;
//		    	float4 color: Color; // Vertex color
//			};
//		
//		half4 LightingUNLIT(SurfaceOutput o, half3 lightdir, half3 halfdir, fixed atten)
//			{
//			    return half4(o.Albedo, o.Alpha);
//			}
//
//			void surf (Input IN, inout SurfaceOutput o)
//			{
//			    o.Albedo = IN.color.rgb * _Color.rgb; // vertex RGB
//			    o.Alpha = 1.0; // vertex Alpha
//			}
//			
//		ENDCG

        
        
        
    }
    FallBack Off
}
