varying vec2 vUv;

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
    gl_FragColor = vec4(gammaCorrection(vec3(vUv, 1.0)), 1.0);
}
