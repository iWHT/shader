// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "chapter_8/alpha_blend_zwrite" {
	Properties {
		_Color ("Main Tint", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_AlphaScale ("Appha Scale", Range(0, 1)) = 1
	}
	SubShader {
		Tags 
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		Pass{
			ZWrite on
			ColorMask 0
		}

		Pass{
			Tags {"LightMode" = "ForwardBase"}
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0; 
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 world_normal : TEXCOORD0;
				float3 world_pos : TEXCOORD1;
				float2 uv : TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.world_normal = UnityObjectToWorldNormal(v.normal);
				o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex); 
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 world_normal = normalize(i.world_normal);
				fixed3 world_light_dir = normalize(UnityWorldSpaceLightDir(i.world_pos));
				fixed4 tex_color = tex2D(_MainTex, i.uv);

				fixed3 albedo = tex_color.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(world_normal, world_light_dir));
				return fixed4(ambient + diffuse, tex_color.a * _AlphaScale);
			}

			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
