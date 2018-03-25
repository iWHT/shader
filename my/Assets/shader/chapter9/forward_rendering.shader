// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "chapter_9/forward_rendering" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Pass {
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma multi_compile_fwdbase //保证光照变量可以被正确的赋值
			#pragma vertex vert
			#pragma fragment frag 
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 world_normal : TEXCOORD0;
				float3 world_pos : TEXCOORD1; 
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.world_normal = UnityObjectToWorldNormal(v.normal);
				o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 world_normal = normalize(i.world_normal);
				fixed3 world_light_dir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb 
					* max(0, dot(world_normal, world_light_dir));

				fixed3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.world_pos.xyz);
				fixed3 half_dir = normalize(world_light_dir + view_dir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb 
					* pow(max(0, dot(world_normal, half_dir)), _Gloss);

				fixed atten = 1.0;
				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}

		Pass{
			Tags { "LightMode" = "ForwardAdd"}
			Blend one one
			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 world_normal : TEXCOORD0;
				float3 world_pos : TEXCOORD1;
			};


			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.world_normal = UnityObjectToWorldNormal(v.normal);
				o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 world_normal = normalize(i.world_normal);
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 world_light_dir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 world_light_dir = normalize(_WorldSpaceLightPos0.xyz - i.world_pos);
				#endif

				fixed3 diffuse = _LightColor0.rgb * _Diffuse * max(0, dot(world_normal, world_light_dir));
				fixed3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.world_pos.xyz);
				fixed3 half_dir = normalize(world_light_dir + view_dir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(world_normal, world_light_dir)), _Gloss);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
						float3 light_coord = mul(unity_WorldToLight, float4(i.world_pos, 1)).xyz;
						fixed atten = tex2D(_LightTexture0, dot(light_coord, light_coord).rr).UNITY_ATTEN_CHANNEL;
					#elif defined (SPOT)
						float4 light_coord = mul(unity_WorldToLight, float4(i.world_pos, 1));
						fixed atten = (light_coord.z > 0) * tex2D(_LightTexture0, light_coord.xy / light_coord.w + 0.5).w 
							* tex2d(_LightTextureB0, dot(light_coord, light_coord).rr).UNITY_ATTEN_CHANNEL;
					#else
						fixed atten = 1.0;
					#endif
				#endif
				return fixed4((diffuse + specular) * atten, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}
