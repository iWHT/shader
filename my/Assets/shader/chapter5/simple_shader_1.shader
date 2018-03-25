// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "chapter_5/simple_shader_1"
{
	SubShader 
	{
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct a2v
			{
				float4 vertex : POSITION;//模型空间顶点坐标
				float3 normal : NORMAL;//模型空间法线向量
				float4 texcoord : TEXCOORD0;//第一套纹理坐标
				
			};

			float4 vert(a2v v) : SV_POSITION
			{
				return UnityObjectToClipPos(v.vertex);
			}

			fixed4 frag() : SV_Target
			{
				return fixed4(1.0,1.0,1.0,1.0);
			}

			ENDCG
		}
	}
}