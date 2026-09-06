#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;
uniform float u_Amplitude;

in vec4 vs_Pos;
in vec4 vs_Nor;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_FragPos;
out vec3 fs_WorldPos;

const vec4 lightPos = vec4(5, 5, 3, 1);

void main() {
    vec3 stretch = vec3(1.0) + u_Amplitude * sin(vec3(u_Time) + vec3(0.0, 1.0, 4.0));
    vec4 position = vec4(vs_Pos.xyz * stretch, 1.0);
    vec4 worldPosition = u_Model * position;

    fs_Nor = vec4(mat3(u_ModelInvTr) * (vs_Nor.xyz / stretch), 0.0);
    fs_LightVec = lightPos - worldPosition;
    
    fs_FragPos = vs_Pos;
    fs_WorldPos = worldPosition.xyz;
    gl_Position = u_ViewProj * worldPosition;
}
