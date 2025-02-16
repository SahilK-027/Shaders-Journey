uniform float uTime;
varying vec2 vUv;

float inverseLerp(float v, float minVal, float maxVal) {
    return (v - minVal) / (maxVal - minVal);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
    float t = inverseLerp(v, inMin, inMax);
    return mix(outMin, outMax, t);
}

vec3 getVignetteBgColor() {
    float distanceFromCenter = length(vUv - vec2(0.5));
    float vignette = 1.0 - distanceFromCenter;
    float smoothVignette = smoothstep(0.0, 0.9, vignette);
    float finalVignette = remap(vignette, 0.0, 1.0, 0.2, 1.0);
    return vec3(finalVignette);
}

vec3 drawLines(vec3 color, vec3 lineColor, float cellSpacing, float lineWidth) {
    vec2 centeredUvs = vUv - 0.5;

    vec3 cell = fract(vec3(centeredUvs, 0.0) * cellSpacing);
    cell = abs(cell - 0.5);

    float distToCell = 0.5 - max(cell.x, cell.y);
    float gridLine = smoothstep(0.0, lineWidth, distToCell);

    return mix(lineColor, color, gridLine);
}

float sdfCircle(vec2 pixelPoint, float radius) {
    return length(pixelPoint) - radius;
}

// p pixelPoint
// b bounds
// r radius
float sdfRoundedBox(in vec2 p, in vec2 b, in vec4 r)
{
    r.xy = (p.x > 0.0) ? r.xy : r.zw;
    r.x = (p.y > 0.0) ? r.x : r.y;
    vec2 q = abs(p) - b + r.x;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r.x;
}

float sdfSegment(in vec2 p, in vec2 a, in vec2 b)
{
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 10.0);
    return length(pa - ba * h);
}

float dot2( in vec2 v ) { return dot(v,v); }
float sdfHeart(in vec2 p)
{
    p.x = abs(p.x);

    if (p.y + p.x > 1.0)
        return sqrt(dot2(p - vec2(0.25, 0.75))) - sqrt(2.0) / 4.0;
    return sqrt(min(dot2(p - vec2(0.00, 1.00)),
            dot2(p - 0.5 * max(p.x + p.y, 0.0)))) * sign(p.x - p.y);
}

void main() {
    // Signed Distance Functions
    // an SDF function describes a shape by defining the distance from any point in space to the nearest surface of the shape
    // An SDF function takes a position  (x,y) and returns:
    // - A positive value if the point is outside the shape.
    // - Zero if the point is on the surface.
    // - A negative value if the point is inside the shape.

    vec2 centeredPixels = vUv - vec2(0.5);

    vec3 color = getVignetteBgColor();
    color = drawLines(color, vec3(0.0), 50.0, 0.04);
    color = drawLines(color, vec3(0.0), 10.0, 0.025);

    // Visualizing SDFs

    // Circle
    // float circleDistance = sdfCircle(centeredPixels, 0.02);
    // color = mix(vec3(1.0, 0.31, 0.13), color, step(0.1, circleDistance));

    // Rounded Box
    // float roundedBoxDist = sdfRoundedBox(centeredPixels, vec2(0.35,0.35), vec4(1.0));
    // color = mix(vec3(1.0, 0.31, 0.13), color, step(0.1, roundedBoxDist));

    // Line segment
    // float lineDist = sdfSegment(centeredPixels * 10.0, vec2(-0.05, -0.05), vec2(0.05, 0.05));
    // color = mix(vec3(1.0, 0.31, 0.13), color, step(0.1, lineDist));

    // Heart
    float heartDist = sdfHeart(centeredPixels * 5.0);
    color = mix(vec3(1.0, 0.31, 0.13), color, step(0.1, heartDist));

    gl_FragColor = vec4(color, 1.0);
}
