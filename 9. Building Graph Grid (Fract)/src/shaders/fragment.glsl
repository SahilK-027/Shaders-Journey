varying vec2 vUv;

void main() {
    vec3 red = vec3(1.0, 0.0, 0.0);
    vec3 blue = vec3(0.0, 0.0, 1.0);
    vec2 centeredUvs = vUv - 0.5;
    vec3 bgColor = vec3(0.91, 1.0, 0.92);
    vec3 color = vec3(1.0);
    vec3 cell = fract(vec3(centeredUvs, 0.0) * 10.0);
    cell = abs(cell - 0.5);

    float distToCell = 1.0 - 2.0 * max(cell.x, cell.y);
    float gridLine = smoothstep(0.0, 0.05, distToCell);
    // Make gridline color green
    vec3 greenGridLines = vec3(0.0, gridLine, 0.0);

    float xAxis = smoothstep(0.0, 0.0035, abs(vUv.y - 0.5));
    float yAxis = smoothstep(0.0, 0.0035, abs(vUv.x - 0.5));

    color = mix(greenGridLines, bgColor, gridLine);
    color = mix(blue, color, xAxis);
    color = mix(red, color, yAxis);
    gl_FragColor = vec4(color, 1.0);
}