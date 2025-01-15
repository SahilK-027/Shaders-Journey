uniform float uTime;
uniform sampler2D uTexture;
varying vec2 vUv;

float inverseLerp(float v, float minVal, float maxVal) {
    return (v - minVal) / (maxVal - minVal);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
    float t = inverseLerp(v, inMin, inMax);
    return mix(outMin, outMax, t);
}

void main() {
    // vec3 lavender = vec3(0.7, 0.5, 1.0);
    // vec3 mint = vec3(0.5, 1.0, 0.8);

    // float time = sin(uTime);
    // time = remap(time, -1.0, 1.0, 0.0, 1.0);

    // vec3 color = mix(lavender, mint, time);

    // OLD TV EFFECT
    float t1 = remap(sin(vUv.y * 300.0 + uTime * 10.0), -1.0, 1.0, 0.75, 1.0);
    vec4 color = texture2D(uTexture, vUv) * t1;

    gl_FragColor = vec4(color);
}
