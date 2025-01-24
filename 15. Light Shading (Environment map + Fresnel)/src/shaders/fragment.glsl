uniform float uTime;
uniform samplerCube uEnvironmentMap;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vViewDirection;

float inverseLerp(float v, float minVal, float maxVal) {
    return (v - minVal) / (maxVal - minVal);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
    float t = inverseLerp(v, inMin, inMax);
    return mix(outMin, outMax, t);
}

vec3 gammaCorrection(vec3 color) {
    return pow(color, vec3(1.0 / 2.2));
}

void main() {
    vec3 normal = normalize(vNormal);
    // Base color
    // vec3 baseColor = vec3(0.52, 0.09, 0.09);
    vec3 baseColor = vec3(0.43);

    vec3 lighting = vec3(0.0);

    // Ambient light
    vec3 ambientLightColor = vec3(0.11);

    // Environment Map
    vec3 environmentSampleCoordinates = normalize(reflect(-vViewDirection, vNormal));
    vec3 envSampling = textureCube(uEnvironmentMap, environmentSampleCoordinates).xyz;

    // Fresnel Effect
    float fresnel = 1.0 - dot(vViewDirection, vNormal);
    fresnel = pow(fresnel, 2.0);

    envSampling *= fresnel * 10.0;

    lighting += ambientLightColor;
    lighting += envSampling;

    vec3 color = baseColor * lighting;
    color = gammaCorrection(color);
    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
