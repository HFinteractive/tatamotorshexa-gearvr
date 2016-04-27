Shader "Custom/SelfIllumWrappedDiffuseBumpedMobile"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalTex("Normal Map", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        
        Lighting Off
		Fog { Mode Off }
 
        CGPROGRAM
        #include "UnityCG.cginc"
        #pragma surface surf NPR
 		
        uniform sampler2D _MainTex;
        uniform sampler2D _NormalTex;
         
        fixed4 LightingNPR(SurfaceOutput o, half3 lightdir, fixed atten)
        {
        	half3 fakeLight = half3(0.7071,0.7071,0.0);
            half lambert = dot(o.Normal, fakeLight);
            lambert = lambert * 0.5 + 0.5;
            return fixed4(o.Albedo * lambert, 1.0);   
        }
 
        struct Input
        {
            half2 uv_MainTex;
            half2 uv_NormalTex;
        };
 
        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
            o.Normal = UnpackNormal (tex2D (_NormalTex, IN.uv_NormalTex));
        }
        ENDCG
    }
    FallBack "Diffuse"
}