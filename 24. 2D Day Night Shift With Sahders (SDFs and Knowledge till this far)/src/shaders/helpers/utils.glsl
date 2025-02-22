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

float sdfEllipse(vec2 p, vec2 r) {
    // Normalize point by ellipse radii
    vec2 k = p / r;
    // Compute the distance in normalized space and then scale it
    return (length(k) - 1.0) * min(r.x, r.y);
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
