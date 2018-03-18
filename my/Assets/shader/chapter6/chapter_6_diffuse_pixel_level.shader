// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "chapter_6_diffuse_pixed_level"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
	}

	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 world_normal : TEXCOORD0; 
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.world_normal = mul((fixed3x3)unity_ObjectToWorld, v.normal);
				return o;
			}

			fixed4 frag(v2f v) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 world_normal = normalize(v.world_normal);
				fixed3 world_light_dir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _LightColor0.xyz * _Diffuse.rgb 
				* saturate(dot(world_normal, world_light_dir));

				fixed3 color = ambient + diffuse;
				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}