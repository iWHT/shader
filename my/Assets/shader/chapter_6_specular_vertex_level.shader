// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "chapter_6_specular_vertex_level"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Color) = (1,1,1,1)
	}

	SubShader {
		Pass {
			Tags {"LightModel"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float4 _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v v)
			{

				v2f o;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 world_normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				fixed3 wolrd_light = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(world_normal,wolrd_light));

				//fixed3 reflect_dir = normalize(2 * (dot(world_normal,wolrd_light)) * world_normal - wolrd_light);
				fixed3 reflect_dir = normalize(reflect(-wolrd_light, world_normal));

				fixed3 view_dir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(view_dir, reflect_dir)), _Gloss);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = ambient + diffuse + specular;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.color, 1);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}