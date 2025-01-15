varying vec2 vUv;

void main() {
    vec3 color = vec3(0.22, 0.3, 1.0);
    // InverseLerp(currentValue, minValue, maxValue)
    // return (currentValue - minValue) / (maxValue - minValue);
    // Some examples:
    // InverseLerp(0.0, 0.0, 100.0) → 0.0
    // InverseLerp(25.0, 0.0, 100.0) -> 0.25
    // InverseLerp (75.0, 0.0, 100.0) →> 0.75
    // InverseLerp (100.0, 0.0, 100.0) -> 1.0

    // Remap(currentValue, inMin, inMax, outMin, outMax)
    // float t = inverseLerp(currentValue, inMin, inMax);
    // return mix(outMin, outMax, t);
    // Some examples:
    // Remap (0.0, 0.0, 100.0, 5.0, 10.0) -> 5.0
    // Remap (50.0, 0.0, 100.0, 5.0, 10.0) -> 7.5
    // Remap (100.0, 0.0, 100.0, 5.0, 10.0) →> 10.0

    // dFdx dFdy
    // In GLSL (OpenGL Shading Language), the functions dFdx and dFdy compute derivatives of a value with respect to the screen-space coordinates of a fragment.
    // dFdx(value): measures how value changes as you move horizontally across the screen.
    // dFdy(value): measures how value changes as you move vertically across the screen.
    // How it works?
    // The derivatives are approximated using the differences between neighboring fragments in a 2×2 pixel block (quad). The GPU evaluates shaders in these blocks, which makes the computation of derivatives efficient.

    // dFdx(value) uses the difference in value between fragments in adjacent pixels horizontally.
    // dFdy(value) uses the difference in value between fragments in adjacent pixels vertically.
    gl_FragColor = vec4(color, 1.0);
}
