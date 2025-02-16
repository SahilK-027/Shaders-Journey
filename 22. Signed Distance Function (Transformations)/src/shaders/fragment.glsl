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

float sdfEquilateralTriangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

mat2 rotate2d(float angle){
    float s = sin(angle);
    float c = cos(angle);

    return mat2(c, -s, s, c);
}

void main() {
    vec2 centeredPixels = vUv - vec2(0.5);
    vec3 color = vec3(0.1, 0.11, 0.15);

    // Circle
    // Translate circles
    vec2 c1Position = vec2(0.2, -0.1);
    vec2 c2Position = vec2(0, 0.22);
    vec2 c3Position = vec2(-0.2, -0.1);

    float circle1dist = sdfCircle(centeredPixels - c1Position, 0.02);
    float circle2dist = sdfCircle(centeredPixels - c2Position, 0.02);
    float circle3dist = sdfCircle(centeredPixels - c3Position, 0.02);

    color = mix(vec3(1.0, 0.31, 0.13), color, step(0.1, circle1dist));
    color = mix(vec3(1.0, 0.31, 0.13), color, step(0.1, circle2dist));
    color = mix(vec3(1.0, 0.31, 0.13), color, step(0.1, circle3dist));

    // Equi-triangle
    // Rotate triangle
    vec2 rotatedPixels = rotate2d(sin(uTime) * 3.14) * centeredPixels;
    float triangleDist = sdfEquilateralTriangle(rotatedPixels, 0.125);
    color = mix(vec3(0.1, 0.2, 0.83), color, step(0.02, triangleDist));

    gl_FragColor = vec4(color, 1.0);
}
