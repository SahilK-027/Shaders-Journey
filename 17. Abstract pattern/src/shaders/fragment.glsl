uniform float uTime;
uniform vec3 uC1;
uniform vec3 uC2;

varying float vElevation;
varying vec2 vUv;

#include "./3DPerlinNoise.glsl";

void main() {
    float mixStrength = (vElevation * 2.0) + 0.25;
    vec3 mixColor = mix(uC2, uC1, mixStrength);

    if (mixStrength > 0.24) {
        mixColor += 1.0;
    }

    gl_FragColor = vec4(pow(mixColor, vec3(1.0 / 2.2)), uTime);
}
