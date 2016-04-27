Shader "VertexColor/VertexColorFog" {
	Properties
	{
		_FogColor("Fog Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Distance("Distance", Range(-24000,24000)) = 0.0
		_Smooth("Smooth", Float) = 10.0
		_Skyramp("Skyramp", 2D) = "white" {}
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
		
		uniform fixed4 _FogColor;
		uniform half _Distance;
		uniform half _Smooth;
		uniform sampler2D _Skyramp;

 		struct appdata_t
		{
			float4 vertex   : POSITION;
			fixed4 color    : COLOR;
		};

		struct v2f
		{
			float4 vertex   : SV_POSITION;
			fixed4 color    : COLOR;
			half2 d : TEXCOORD2;
		};
 
         v2f vert(appdata_t IN)
         {
             v2f OUT;
             OUT.vertex = mul(UNITY_MATRIX_MVP,IN.vertex);
             OUT.color = IN.color;
             half4 wpos = mul(_Object2World, IN.vertex);
             OUT.d[0] = (wpos.z - _Distance ) / 48000;
             OUT.d[1] = (wpos.y  + 3180) / 33034;
             return OUT;
         }
 
         fixed4 frag(v2f IN) : SV_Target
         {
            fixed4 OUT;
            OUT = IN.color;
			 
			fixed4 fogColor = tex2D(_Skyramp, half2(0.5, IN.d[1]));
			 
			return lerp(fogColor, OUT, exp(-_Smooth * clamp(IN.d[0],0.0,1.0)) );
			
         }
         ENDCG
 
     }
 }
 FallBack "Diffuse"
}
