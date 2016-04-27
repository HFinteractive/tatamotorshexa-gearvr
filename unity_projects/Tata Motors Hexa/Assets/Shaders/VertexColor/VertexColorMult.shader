Shader "Custom/VertexColorMult" {
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_Saturation ("Saturation", Range(0.0 , 1.0)) = 1.0
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque"}
		
		Lighting Off
		Fog { Mode Off }		
		
		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		
		half4 _Color;
		fixed _Saturation;
		
 		struct appdata_t
		{
			float4 vertex   : POSITION;
			float4 color    : COLOR;
		};

		struct v2f
		{
			float4 vertex   : SV_POSITION;
			fixed4 color    : COLOR;
		};
 
         v2f vert(appdata_t IN)
         {
             v2f OUT;
             OUT.vertex = mul(UNITY_MATRIX_MVP,IN.vertex);
             OUT.color = IN.color;
             return OUT;
         }
 
         fixed4 frag(v2f IN) : SV_Target
         {
             fixed4 OUT;
             OUT = IN.color;
             
             fixed3 g = (OUT.rgb[0] + OUT.rgb[1] + OUT.rgb[2]) / 3.0;
             OUT = (1.0 - _Saturation) * fixed4(g, 1.0) + _Saturation * OUT;
             return OUT * _Color;
         }
         ENDCG
 
     }
 }
 FallBack "Diffuse"
}
