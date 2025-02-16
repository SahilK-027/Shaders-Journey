uniform float uTime;
varying vec2 vUv;

float inverseLerp(float v, float minVal, float maxVal) {
    return (v - minVal) / (maxVal - minVal);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
    float t = inverseLerp(v, inMin, inMax);
    return mix(outMin, outMax, t);
}

float sdfCircle(vec2 pixelPoint, float radius) {
    return length(pixelPoint) - radius;
}

float sdfEquilateralTriangle(in vec2 p, in float r) {
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r / k;
    if (p.x + k * p.y > 0.0) p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
    p.x -= clamp(p.x, -2.0 * r, 0.0);
    return -length(p) * sign(p.y);
}

mat2 rotate2d(float angle) {
    float s = sin(angle);
    float c = cos(angle);

    return mat2(c, -s, s, c);
}

float opUnion(float d1, float d2) {
    return min(d1, d2);
}

float opIntersection(float d1, float d2) {
    return max(d1, d2);
}

float opSubtraction(float d1, float d2) {
    return max(-d1, d2);
}

float softmax(float a, float b, float k) {
    return log(exp(k * a) + exp(k * b)) / k;
}

float softmin(float a, float b, float k) {
    return -softmax(-a, -b, k);
}

float softOpUnion(float d1, float d2, float k) {
    return softmin(d1, d2, k);
}

float softOpIntersection(float d1, float d2, float k) {
    return softmax(d1, d2, k);
}

float softOpSubtraction(float d1, float d2, float k) {
    return softmax(-d1, d2, k);
}

float softMinValue(float a, float b, float k) {
    return remap(a - b, -1.0 / k, 1.0 / k, 0.0, 1.0);
}

void main() {
    vec2 centeredPixels = vUv - vec2(0.5);
    vec3 color = vec3(0.08);

    // Circle
    vec2 c1Position = vec2(0.2, -0.1);
    vec2 c2Position = vec2(0, 0.222);
    vec2 c3Position = vec2(-0.2, -0.1);

    float circle1dist = sdfCircle(centeredPixels - c1Position, 0.1);
    float circle2dist = sdfCircle(centeredPixels - c2Position, 0.1);
    float circle3dist = sdfCircle(centeredPixels - c3Position, 0.1);
    float finalCircles = opUnion(opUnion(circle1dist, circle2dist), circle3dist);

    // Equi-triangle
    vec2 rotatedPixels = rotate2d(sin(uTime * 0.25) * 3.14) * centeredPixels;
    float triangleDist = sdfEquilateralTriangle(rotatedPixels, 0.12);

    float finalUnion = softOpUnion(finalCircles, triangleDist, 100.0);

    float t = remap(sin(uTime), -1.0, 1.0, 0.0, 1.0);
    vec3 red = vec3(1.0, 0.0, 0.0);
    vec3 green = vec3(0.0, 1.0, 0.0);
    vec3 blue = vec3(0.0, 0.0, 1.0);
    vec3 color1;

    if (t < 0.5) {
        float t0 = t / 0.5;
        color1 = mix(red, green, t0);
    } else {

        float t1 = (t - 0.5) / 0.5;
        color1 = mix(green, blue, t1);
    }

    vec3 color2 = vec3(0.0);

    vec3 sdfColor = mix(color1, color2, smoothstep(0.0, 0.7, softMinValue(triangleDist, finalUnion, 5.0)));

    color = mix(sdfColor * 10.0, color, step(0.008, finalUnion));

    gl_FragColor = vec4(color, 1.0);
}
