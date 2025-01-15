uniform float uTime;

varying vec2 vUv;

void main() {
    // Base color
    vec3 color = vec3(0.5);

    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
