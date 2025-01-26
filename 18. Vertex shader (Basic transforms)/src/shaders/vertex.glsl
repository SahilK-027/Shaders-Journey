uniform float uTime;

varying vec3 vNormal;

float inverseLerp(float v, float minVal, float maxVal) {
    return (v - minVal) / (maxVal - minVal);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
    float t = inverseLerp(v, inMin, inMax);
    return mix(outMin, outMax, t);
}

mat3 rotateY(float angle) {
    float sinTheta = sin(angle);
    float cosTheta = cos(angle);

    return mat3(
        cosTheta, 0, sinTheta,
        0, 1, 0,
        -sinTheta, 0, cosTheta
    );
}

void main() {
    // Transform the normals & position upon rotation, scale, translation
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);

    // All transforms
    // 1. Scale on z-axis
    // But sin value goes from -1 to 1 so scale won't work correctly
    // Let's remap
    modelPosition.z *= remap(sin(uTime), -1.0, 1.0, 1.0, 1.5);

    // 2. Rotate along y-axix
    modelPosition.xyz = rotateY(uTime) * modelPosition.xyz;

    // 3. Translate the position
    modelPosition.x += sin(uTime);

    vec4 modelNormal = modelMatrix * vec4(normal, 0.0);
    gl_Position = projectionMatrix * viewMatrix * modelPosition;

    // Varyings
    vNormal = modelNormal.xyz;
}
