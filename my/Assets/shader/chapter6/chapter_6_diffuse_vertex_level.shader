// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "chapter_6_diffuse_vertex_level"
{
	Properties
	{
		//声明漫反射的颜色和光照强度
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
	}

	SubShader {
		Pass {
			// 描述光照模式，以便获得相应的内置光照变量
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			// 声明漫反射变量以便于从上述的属性中获取
			fixed4 _Diffuse;

			struct a2v
			{
				// 获取顶点
				float4 vertex : POSITION;
				// 获取法线
				float3 normal : NORMAL;
			};

			struct v2f
			{
				// 之所以是SV，是因为此数值包含了可用于光栅化的变换后的顶点坐标（齐次空间的坐标）
				// 引擎将会把它经过光栅化，然后显示在屏幕上
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;

				// 获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// 获取世界法线
				fixed3 world_normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				//float3 world_normal = normalize(mul((float3x3)_Object2World, v.normal));

				// 获取光照方向
				fixed3 world_light = normalize(_WorldSpaceLightPos0.xyz);

				// 计算漫反射光照
				fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(world_normal, world_light));

				// 通过矩阵变化，将模型的顶点转到齐次坐标下，投影坐标
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.color, 1.0);
			}

			ENDCG
		}
	}


	FallBack "Diffuse"
}
