uniform float uTime;

varying vec2 vUv;
varying vec3 vNormal;

float inverseLerp(float v, float minVal, float maxVal) {
    return (v - minVal) / (maxVal - minVal);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
    float t = inverseLerp(v, inMin, inMax);
    return mix(outMin, outMax, t);
}

void main() {
    vec3 normal = normalize(vNormal);
    // Base color
    vec3 baseColor = vec3(0.5);
    vec3 lighting = vec3(0.0);

    // Ambient light
    vec3 ambientLight = vec3(0.5);

    // Hemisphere light
    vec3 topColor = vec3(0.0, 0.72, 1.0);
    vec3 bottomColor = vec3(1.0, 0.42, 0.0);
    float hemiMix = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
    vec3 hemiSphereLight = mix(bottomColor, topColor, hemiMix);

    lighting += ambientLight;
    lighting += hemiSphereLight;

    vec3 color = baseColor * lighting;

    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
