varying vec2 vUv;

void main() {
    float cloud = smoothstep(0.3, 0.7, fract(sin(dot(vUv, vec2(12.9898, 78.233))) * 43758.5453));
    vec3 color = mix(vec3(0.5, 0.7, 1.0), vec3(1.0), cloud);

    gl_FragColor = vec4(color, 1.0);
}
