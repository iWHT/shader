// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "chapter_7/normal_map_tangent_space"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white"{}
		_BumpMap ("Normal Map", 2D) = "bump"{}
		_BumpScale ("Bump Scale", Float) = 1.0
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
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			float4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0; 
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 light_dir : TEXCOORD1;
				float3 view_dir : TEXCOORD2; 
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				TANGENT_SPACE_ROTATION;

				o.light_dir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.view_dir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 tangent_light_dir = normalize(i.light_dir);
				fixed3 tangent_view_dir = normalize(i.view_dir);

				fixed4 packed_normal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangent_normal;
				tangent_normal = UnpackNormal(packed_normal);
				tangent_normal.xy *= _BumpScale;
				tangent_normal.z = sqrt(1.0 - saturate(dot(tangent_normal.xy, tangent_normal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangent_normal, tangent_light_dir));
				fixed3 half_dir = normalize(tangent_light_dir + tangent_view_dir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangent_normal, half_dir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}


			ENDCG
		}
	}

	FallBack "Specular"
}