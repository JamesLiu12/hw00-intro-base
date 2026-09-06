#version 300 es

precision highp float;

uniform vec4 u_Color;
uniform vec3 u_CenterColor;
uniform float u_BumpStrength;
uniform float u_Frequency;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_FragPos;
in vec3 fs_WorldPos;

out vec4 out_Col;

vec3 hash(vec3 p) {
    p = fract(p * vec3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.xxy + p.yxx) * p.zyx);
}

vec3 gradient(vec3 p) {
    vec3 result = hash(p) * 2.0 - 1.0;
    float len = max(length(result), 0.00001);
    return result / len;
}

float perlinNoise(vec3 p) {
    vec3 grid = floor(p);
    vec3 pos = fract(p);

    vec3 fade = pos * pos * pos * (pos * (pos * 6.0 - 15.0) + 10.0);

    vec3 p000 = vec3(0.0, 0.0, 0.0);
    vec3 p100 = vec3(1.0, 0.0, 0.0);
    vec3 p010 = vec3(0.0, 1.0, 0.0);
    vec3 p110 = vec3(1.0, 1.0, 0.0);
    vec3 p001 = vec3(0.0, 0.0, 1.0);
    vec3 p101 = vec3(1.0, 0.0, 1.0);
    vec3 p011 = vec3(0.0, 1.0, 1.0);
    vec3 p111 = vec3(1.0, 1.0, 1.0);

    float v000 = dot(gradient(grid + p000), pos - p000);
    float v100 = dot(gradient(grid + p100), pos - p100);
    float v010 = dot(gradient(grid + p010), pos - p010);
    float v110 = dot(gradient(grid + p110), pos - p110);
    float v001 = dot(gradient(grid + p001), pos - p001);
    float v101 = dot(gradient(grid + p101), pos - p101);
    float v011 = dot(gradient(grid + p011), pos - p011);
    float v111 = dot(gradient(grid + p111), pos - p111);

    float x00 = mix(v000, v100, fade.x);
    float x10 = mix(v010, v110, fade.x);
    float x01 = mix(v001, v101, fade.x);
    float x11 = mix(v011, v111, fade.x);

    float y0 = mix(x00, x10, fade.y);
    float y1 = mix(x01, x11, fade.y);

    return mix(y0, y1, fade.z);
}

void main() {
    vec3 noisePos = fs_FragPos.xyz * u_Frequency;
    noisePos += vec3(0.37, 0.61, 0.83);

    float noise = perlinNoise(noisePos);
    noise = clamp(noise * 0.5 + 0.5, 0.0, 1.0);

    float colorMix = smoothstep(0.45, 0.55, noise);

    vec3 darkColor = vec3(0.17, 0.16, 0.15);
    float heat = smoothstep(0.55, 0.7, noise);
    vec3 brightColor = mix(u_Color.rgb, u_CenterColor, heat);
    vec3 finalColor = mix(darkColor, brightColor, colorMix);

    float height = (1.0 - colorMix) * u_BumpStrength;

    vec3 normal = normalize(fs_Nor.xyz);
    vec3 worldX = dFdx(fs_WorldPos);
    vec3 worldY = dFdy(fs_WorldPos);

    vec3 crossX = cross(worldY, normal);
    vec3 crossY = cross(normal, worldX);

    float determinant = dot(worldX, crossX);
    float heightX = dFdx(height);
    float heightY = dFdy(height);

    vec3 slope = heightX * crossX + heightY * crossY;
    slope *= sign(determinant) / max(abs(determinant), 0.0000000001);

    normal = normalize(normal - slope);

    vec3 lightDirection = normalize(fs_LightVec.xyz);
    float diffuse = max(dot(normal, lightDirection), 0.0);
    float brightness = 0.2 + diffuse;

    out_Col = vec4(finalColor * brightness, u_Color.a);
}
