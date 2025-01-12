varying vec2 vUv;

void main() {
    // left side black and right side white
    gl_FragColor = vec4(vec3(vUv.x), 1.0);  

    // Revert to left side white and right side black
    gl_FragColor = vec4(vec3(abs(vUv.x - 1.0)), 1.0);

    // Gradient             r, g, b, a
    // Can think of as      x, y, z, w
    // Top left:            (0.0, 1.0, 0.0, 1.0)
    // Bottom left:         (0.0, 0.0, 0.0, 1.0)
    // Bottom right:        (1.0, 0.0, 0.0, 1.0)
    // Top right:           (1.0, 1.0, 0.0, 1.0)
    gl_FragColor = vec4(vUv, 0.0, 1.0);

    // Gradient 
    // Can you make the top left red and bottom right blue?
    // For Top left: blue we will need (0.0, 0.0, 1.0, 1.0)
    // For bottom right: red we will need (1.0, 0.0, 0.0, 1.0)
    // So,
    gl_FragColor = vec4(vUv.x, 0.0, vUv.y, 1.0);
}