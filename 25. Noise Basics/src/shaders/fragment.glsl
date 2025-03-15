varying vec2 vUv;

float Math_Random(vec2 p) {
    p = 50.0 * fract(p * 0.3183099 + vec2(0.71, 0.113));
    return -1.0 + 2.0 * fract(p.x * p.y * (p.x + p.y));
}

void main() {
    vec2 pixelCords = (vUv - 0.5);
    vec3 color = vec3(Math_Random(pixelCords));
    gl_FragColor = vec4(color, 1.0);
}
