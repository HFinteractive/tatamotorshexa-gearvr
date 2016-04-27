Shader "Compositing/CompShaderAdd" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		[HideInInspector] _Comp ("Comp", 2D) = "white"{}
	}
	
	SubShader 
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			
			uniform sampler2D _MainTex;
			uniform sampler2D _Comp;

			fixed4 frag(v2f_img i) : COLOR
			{
				fixed4 dst = tex2D(_MainTex, i.uv);
				fixed4 src = tex2D(_Comp, i.uv);
				fixed4 output;
				
				output.rgb = src.rgb + dst.rgb;
				
				return output;
			}
	
			ENDCG
		}
	} 
	FallBack off
}

