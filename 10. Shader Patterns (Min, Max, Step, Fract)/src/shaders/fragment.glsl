uniform float uTime;
varying vec2 vUv;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) *
        43758.5453123);
}

vec2 rotate(vec2 uv, float rotation, vec2 mid) {
    return vec2(cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x, cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y);
}

void main() {
    // Pattern 1
    vec3 color = vec3(vUv.x, vUv.y, 1.0);

    // Pattern 2
    // color = vec3(vUv.x, vUv.y, 0.0);

    // Pattern 3
    // color = vec3(vUv.x);

    // Pattern 4
    // color = vec3(vUv.y);

    // Pattern 5
    // color = 1.0 - vec3(vUv.y);

    // Pattern 6
    // color = vec3(vUv.y) * 10.0;

    // Pattern 7
    // color = fract(vec3(vUv.y) * 10.0);

    // Pattern 8
    // color = step(0.5, fract(vec3(vUv.y) * 10.0));

    // Pattern 9
    // color = step(0.8, fract(vec3(vUv.y) * 10.0));

    // Pattern 10
    // color = step(0.8, fract(vec3(vUv.x) * 10.0));

    // Pattern 11
    // vec3 patternX = step(0.8, fract(vec3(vUv.x) * 10.0));
    // vec3 patternY = step(0.8, fract(vec3(vUv.y) * 10.0));
    // color = patternX + patternY;

    // Pattern 12
    // vec3 patternX = step(0.8, fract(vec3(vUv.x) * 10.0));
    // vec3 patternY = step(0.8, fract(vec3(vUv.y) * 10.0));
    // color = patternX * patternY;

    // Pattern 13
    // vec3 patternX = step(0.8, fract(vec3(vUv.x) * 10.0));
    // vec3 patternY = step(0.8, fract(vec3(vUv.y) * 10.0));
    // color = patternX - patternY;

    // Pattern 14
    // vec3 patternX = step(0.8, fract(vec3(vUv.x) * 10.0));
    // vec3 patternY = step(0.8, fract(vec3(vUv.y) * 10.0));
    // color = patternY - patternX;

    // Pattern 15
    // vec3 patternX = step(0.4, fract(vec3(vUv.x) * 10.0));
    // vec3 patternY = step(0.8, fract(vec3(vUv.y) * 10.0));

    // vec3 patternX1 = step(0.8, fract(vec3(vUv.x) * 10.0));
    // vec3 patternY1 = step(0.4, fract(vec3(vUv.y) * 10.0));
    // color = patternX * patternY + patternX1 * patternY1;

    // Pattern 16
    // vec3 patternX = step(0.4, fract(vec3(vUv.x) * 10.0));
    // vec3 patternY = step(0.8, fract(vec3(vUv.y) * 10.0 + 0.2));

    // vec3 patternX1 = step(0.8, fract(vec3(vUv.x) * 10.0 + 0.2 ));
    // vec3 patternY1 = step(0.4, fract(vec3(vUv.y) * 10.0));
    // color = patternX * patternY + patternX1 * patternY1;

    // Pattern 17
    // color = vec3(abs(vUv.x - 0.5));

    // Pattern 18
    // float verticalBlackLine = abs(vUv.x - 0.5);
    // float horizontalBlackLine = abs(vUv.y - 0.5);
    // color = min(vec3(verticalBlackLine), vec3(horizontalBlackLine));

    // Pattern 19
    // float verticalBlackLine = abs(vUv.x - 0.5);
    // float horizontalBlackLine = abs(vUv.y - 0.5);
    // color = max(vec3(verticalBlackLine), vec3(horizontalBlackLine));

    // Pattern 20
    // float verticalBlackLine = abs(vUv.x - 0.5);
    // float horizontalBlackLine = abs(vUv.y - 0.5);
    // color = step(0.2, max(vec3(verticalBlackLine), vec3(horizontalBlackLine)));

    // Pattern 21
    // float verticalBlackLine = abs(vUv.x - 0.5);
    // float horizontalBlackLine = abs(vUv.y - 0.5);
    // vec3 sq1 = step(0.2, max(vec3(verticalBlackLine), vec3(horizontalBlackLine)));
    // vec3 sq2 = 1.0 - step(0.25, max(vec3(verticalBlackLine), vec3(horizontalBlackLine)));
    // color = sq1 * sq2;

    // Pattern 22
    // color = vec3(ceil(vUv.x * 10.0) / 10.0);

    // Pattern 23
    // float horizontalStep = floor(vUv.x * 10.0) / 10.0;
    // float verticalStep = floor(vUv.y * 10.0) / 10.0;
    // color = (vec3(verticalStep) * vec3(horizontalStep));

    // Pattern 24
    // float horizontalStep = floor(vUv.x * 10.0) / 10.0;
    // float verticalStep = floor(vUv.y * 10.0) / 10.0;
    // vec2 gridUv = vec2(horizontalStep, verticalStep);
    // color = vec3(random(gridUv));

    // Pattern 25
    // float horizontalStep = floor(vUv.x * 10.0) / 10.0;
    // float verticalStep = floor(vUv.y * 10.0 + vUv.x * 5.0) / 10.0;
    // vec2 gridUv = vec2(horizontalStep, verticalStep);
    // color = vec3(random(gridUv));

    // Pattern 26
    // color = vec3(length(vUv));

    // Pattern 27
    // color = vec3(length(vUv - 0.5));

    // Pattern 28
    // color = 1.0 - vec3(length(vUv - 0.5));

    // Pattern 29
    // color = 0.015 / vec3(length(vUv - 0.5));

    // Pattern 30
    // vec2 lightUvX = vec2(vUv.x * 0.1 + 0.45, vUv.y * 0.5 + 0.25);
    // vec3 lightX = 0.015 / vec3(length(lightUvX - 0.5));
    // vec2 lightUvY = vec2(vUv.x * 0.5 + 0.25, vUv.y * 0.1 + 0.45);
    // vec3 lightY = 0.015 / vec3(length(lightUvY - 0.5));
    // color = lightX * lightY;

    // Pattern 31
    // vec2 lightUvX = vec2(vUv.x * 0.1 + 0.45, vUv.y * 0.5 + 0.25);
    // vec3 lightX = 0.015 / vec3(length(lightUvX - 0.5));
    // vec2 lightUvY = vec2(vUv.x * 0.5 + 0.25, vUv.y * 0.1 + 0.45);
    // vec3 lightY = 0.015 / vec3(length(lightUvY - 0.5));
    // color = lightX * lightY;

    // Pattern 32
    // color = vec3(step(0.25, length(vUv - 0.5)));

    // Pattern 33
    // color = abs(vec3(length(vUv - 0.5)) - 0.25);

    // Pattern 34
    // color = step(0.01, abs(vec3(length(vUv - 0.5)) - 0.25));

    // Pattern 35
    // color = 1.0 - step(0.01, abs(vec3(length(vUv - 0.5)) - 0.25));

    // Pattern 35
    vec2 waveUv = vec2(vUv.x + sin(vUv.y * 100.0) * 0.3, vUv.y + sin(vUv.x * 100.0) * 0.3);
    color = 1.0 - step(0.025, abs(vec3(length(waveUv - 0.5)) - 0.25));

    vec3 gradientColor = vec3(waveUv.x, waveUv.y, abs(sin(uTime)));

    // Combine the gradient with the mask
    color = mix(vec3(0.0), gradientColor, color);
    gl_FragColor = vec4(color, 1.0);
}