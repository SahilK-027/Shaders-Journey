uniform float uTime;
uniform float uTerrainElevation;

varying float vElevation;
varying vec2 vUv;

#include "./3DPerlinNoise.glsl";

void main() {
    // Model transformation: Transform the vertex position from local object space to `world space` using the modelMatrix.
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    
    float elevation = sin(uTerrainElevation);

    elevation -= abs(cnoise(vec3(modelPosition.xy * 3.0, uTime * 0.2)) * 0.15);

    // modelPosition.z += elevation;

    // View transformation: Transform the vertex position from world space to `view space` using the viewMatrix.
    vec4 viewPosition = viewMatrix * modelPosition;

    // Projection transformation: Transform the vertex position from view space to `clip space` using the projectionMatrix.
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    vUv = uv;

    vElevation = elevation;
}

