varying vec3 vNormal;

vec3 gammaCorrection(vec3 color) {
    return pow(color, vec3(1.0 / 2.2));
}

float inverseLerp(float v, float minVal, float maxVal) {
    return (v - minVal) / (maxVal - minVal);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
    float t = inverseLerp(v, inMin, inMax);
    return mix(outMin, outMax, t);
}

void main() {
    vec3 normal = normalize(vNormal);
    normal.x = remap(normal.x, -1.0, 1.0, 0.0, 1.0);
    normal.y = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
    normal.z = remap(normal.z, -1.0, 1.0, 0.0, 1.0);

    gl_FragColor = vec4(gammaCorrection(normal), 1.0);
}
