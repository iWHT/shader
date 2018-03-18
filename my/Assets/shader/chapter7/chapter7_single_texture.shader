// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "chapter_7_single_texture"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white"{}
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Pass {
			Tags { "LightMode" = "ForwardBase"}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float4 _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;//模型的第一组纹理坐标
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 world_normal : TEXCOORD0;
				float3 world_pos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.world_normal = mul(v.normal, (float3x3)unity_WorldToObject);
				//o.world_normal = UnityObjectToWorldNormal(v.normal);
				o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;//乘上缩放再加上偏移
				//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 world_normal = normalize(i.world_normal);
				fixed3 world_light_dir = normalize(UnityWorldSpaceLightDir(i.world_pos));
				//材质的反射率，第一个rgb是采样的纹素值
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(world_normal, world_light_dir));

				fixed3 view_dir = normalize(UnityWorldSpaceViewDir(i.world_pos));
				fixed3 half_dir = normalize(world_light_dir + view_dir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(world_normal, half_dir)), _Gloss);

				return fixed4(ambient + diffuse + specular,1.0);
			}
			ENDCG
		}
	}

	FallBack "Specular"

}