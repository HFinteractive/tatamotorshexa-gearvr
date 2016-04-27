Shader "Custom/CustomGlow"
{
	SubShader
	{
		Tags { "RenderEffect"="Glow" }
		Pass
		{
			Fog {Mode Off}
			Color [_Glow_Color]
		}
	} 
}
