Shader "chapter_6_specular_pixel_level"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "LightModel" = "ForwardBase"
            }

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
                float3 world_normal : TEXCOORD0;
                float3 world_pos : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.world_normal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

                fixed3 world_normal = normalize(i.world_normal);
                fixed3 world_light_dir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rbg * _Diffuse.rgb * saturate(dot(world_normal, world_light_dir));

                fixed3 reflect_dir = normalize(reflect(-world_light_dir, world_normal));
                fixed3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.world_pos.xyz);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(view_dir * reflect_dir), _Gloss);

                fixed3 color = ambient + diffuse + specular;

                return fixed4(color, 1);
            }

            ENDCG
        }
    }

    FallBack "Specular"
}