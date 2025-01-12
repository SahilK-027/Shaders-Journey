varying vec2 vUv;

void main() {
    // Step function
    // step(edge, x) -> generates a step function 
    // if(x < edge) return 0.0; else return 1.0;
    // vec3 color = vec3(vUv.x);
    // color = vec3(step(0.5, vUv.x));
    // Note to get step behave like inverse step call step(x, edge) 😅

    // mix function
    // mix(a,b, t) 
    // Internally returns a + (b - a) * t
    // What it does is that it allows you to take two values
    // and a third parameter t thats the percentage, between 0 & 1 and returns a
    // linear blend between a to b
    // Ex mix(5, 10, 0.5) => 7.5, because 50% of 5 -> 10 is 7.5
    // vec3 yellow = vec3(1.0, 0.7, 0.0);
    // vec3 green = vec3(0.0, 1.0, 0.0);
    // color = mix(yellow, green, vUv.x);

    // Smoothstep function
    // smoothstep(edge1, edge2, x) - returns smooth hermit interpolation between 0 and 1 if x is in range of [edge1, edge2]
    // internally returns t * t * (3.0 - 2.0 * t)
    // where t = clamp((x - edge1) / (edge2 - edge1), 0.0, 1.0);
    // Ex. smoothstep(10.0, 20.0, 10.0) -> 0.0
    // smoothstep(10.0, 20.0, 12.5) -> 0.15
    // smoothstep(10.0, 20.0, 15.0) -> 0.5
    // smoothstep(10.0, 20.0, 20.0) -> 1.0
    // color = vec3(smoothstep(0.0, 1.0, vUv.x));

    vec3 color = vec3(1.0);
    // Draw line in the middle of screen
    // vUv.y goes from 1 -> 0
    // so vUv.y - 0.5 => [0.5, -0.5]
    // For this line -ves [0.0, -0.5] will be black & [0.5, 0.1] will be grayish
    // float line = vUv.y - 0.5;
    // Lets take abs of values we will get [0.5, 0.0] & [0.0, 0.5]
    // Resulting in center black patch
    // line = abs(line);
    // Use step to directly step up from black and white
    // line = step(0.0025, line);

    // By combining all above knowledge lets draw line in one liner
    float line = step(0.0025, abs(vUv.y - 0.5));
    float linearLine = step(0.0025, abs(vUv.y - mix(0.5, 1.0, vUv.x)));
    float smoothInterpolationLine = step(0.0025, abs(vUv.y - mix(0.0, 0.5, smoothstep(0.0, 1.0, vUv.x))));

    color = vec3(line);

    // Now Lets draw red and blue gradient only on top half using mix
    vec3 red = vec3(1.0, 0.0, 0.0);
    vec3 blue = vec3(0.0, 0.0, 1.0);
    if(vUv.y > 0.5) {
        color = mix(red, blue, vUv.x);
    } else {
        // Use smoothstep here
        color = mix(red, blue, smoothstep(0.0, 1.0, vUv.x));
    }

    // Lets get our line back
    vec3 white = vec3(1.0);

    // To understand below code, think about what mix does
    // Where things are black, the first parameter gets returned
    // Where things are white the second parameter gets returned
    // And things are gray we mix
    color = mix(white, color, line);
    color = mix(white, color, linearLine);
    color = mix(white, color, smoothInterpolationLine);

    gl_FragColor = vec4(color, 1.0);
}
