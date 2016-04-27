Shader "Custom/VertexColor2" {
	Properties
	{
	
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

 		struct appdata_t
		{
			float4 vertex   : POSITION;
			fixed4 color    : COLOR;
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
             return OUT;
         }
         ENDCG
 
     }
 }
 FallBack "Diffuse"
}
