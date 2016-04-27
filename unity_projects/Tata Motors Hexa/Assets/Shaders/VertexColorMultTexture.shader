Shader "Custom/VertexColorMultTexture" {
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Lighting ("Lighting", Range(0, 1.0)) = 0.0
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
		
		sampler2D _MainTex;
		half4 _MainTex_ST;
		half _Lighting;

 		struct appdata_t
		{
			float4 vertex   : POSITION;
			fixed4 color    : COLOR;
			half2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 vertex   : SV_POSITION;
			fixed4 color    : COLOR;
			half2 texcoord : TEXCOORD0;
		};
 
         v2f vert(appdata_t IN)
         {
             v2f OUT;
             OUT.vertex = mul(UNITY_MATRIX_MVP,IN.vertex);
             OUT.color = IN.color;
             OUT.texcoord = TRANSFORM_TEX(IN.texcoord, _MainTex);
             return OUT;
         }
 
         fixed4 frag(v2f IN) : SV_Target
         {
             fixed4 OUT;
             OUT = IN.color + _Lighting * tex2D(_MainTex, IN.texcoord);
             return OUT;
         }
         ENDCG
 
     }
 }
 FallBack "Diffuse"
}
