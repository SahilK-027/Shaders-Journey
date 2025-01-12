varying vec2 vUv;

void main() {
    // mix(a,b, t) 
    // Internally returns a + (b - a) * t
    // What it does is that it allows you to take two values
    // and a third parameter t thats the percentage, between 0 & 1 and returns a
    // linear blend between a to b
    // Ex mix(5, 10, 0.5) => 7.5, because 50% of 5 -> 10 is 7.5

    gl_FragColor = mix(vec4(1.0, 0.0, 0.0, 1.0), vec4(0.0, 1.0, 0.0, 1.0), vUv.x);

    // Here vUv.x value will go from 0 to 1
    // In our example mix(red, green)
    // So in the middle it is 0.5
    // At this point, i.e.50% we expect yellow color
    // But the color in the center is not bright rather it is dark yellow
    // The reason the color you see is darker is likely due to how GLSL's mix function works 
    // in combination with the linear color space used in shaders.
    // The mix Function
    // The mix function performs a linear interpolation between two values. 
    // In our case:
    // This blends the colors equally:
    // Red: (1.0 * 0.5) + (0.0 * 0.5) = 0.5
    // Green: (0.0 * 0.5) + (1.0 * 0.5) = 0.5
    // Blue: 0.0
    // The resulting color is:
    // vec4(0.5, 0.5, 0.0, 1.0)
    // This is a dull yellow, not bright yellow.
    // Solution?
    // To make the colors appear as expected (bright yellow), you need to apply gamma correction before displaying the output.
    // What is Gamma Correction?
    // Gamma correction is a process that adjusts the brightness of colors to account for the non-linear way humans perceive light. It's essential in computer graphics to ensure that colors appear as intended on a display.
    // Graphics calculations (like shading, blending, and mix) are done in a linear color space.
    // Linear space assumes brightness scales linearly, which doesn't match how we see brightness.
    // We see brightness exponentially

    vec4 mixColor = mix(vec4(1.0, 0.0, 0.0, 1.0), vec4(0.0, 1.0, 0.0, 1.0), vUv.x);
    gl_FragColor = pow(mixColor, vec4(1.0 / 2.2));
}