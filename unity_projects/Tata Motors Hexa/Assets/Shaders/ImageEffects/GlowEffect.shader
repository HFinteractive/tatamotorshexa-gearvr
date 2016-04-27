Shader "Custom/ReplacementTest/HalfImage" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Half ("Base (RGB)", 2D) = "white" {}
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
			uniform sampler2D _Half;

			fixed4 frag(v2f_img i) : COLOR
			{
				fixed4 renderTex;
				

				if(i.uv[0] > 0.5)
				{								
					renderTex.rgb = tex2D(_MainTex, i.uv);
				}
				else
				{
					renderTex.rgb = tex2D(_Half, i.uv);
				}
				
				return renderTex;
			}
	
			ENDCG
		}
	} 
	FallBack off
}
