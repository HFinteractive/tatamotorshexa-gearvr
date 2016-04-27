Shader "Unlit/UnlitAlphaDepth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	
	SubShader
	{
		Cull Back
		
//		Pass
//		{
//			Tags { "Queue" = "Geometry"}
//			ZWrite On
//			ColorMask 0
//		}
		Tags { "Queue" = "Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Pass
		{	
			
			//ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Fog {Mode Off}
			SetTexture [_MainTex]
		}
		
		

	}
	
	
	
	
}