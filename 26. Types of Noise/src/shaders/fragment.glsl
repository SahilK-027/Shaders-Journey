uniform sampler2D uTexture;

varying vec2 vUv;

float Math_Random(vec2 p) {
    p = 50.0 * fract(p * 0.3183099 + vec2(0.71, 0.113));
    return -1.0 + 2.0 * fract(p.x * p.y * (p.x + p.y));
}

// Theory
// Types of noise:
// Value noise: (How it works?)
// Take a grid of n x m size
// Random scalar values are assigned at the nodes (grid points).
// For any point in space, the noise value is computed by interpolating (blending) between the random values at the surrounding grid points .

// Gradient Noise
// Instead of random scalar values, each grid node is assigned a random gradient vector.
// For a given point, the algorithm calculates the offset vectors from each grid node to that point. Then, it computes the dot product between each gradient vector and its corresponding offset vector.
// These dot products are interpolated (blending) to yield the final noise value.
// Perlin noise

// Interpolation (blending) techniques
// These are methods for estimating values between known data points. They are essential in both value noise and gradient noise, though what gets interpolated differs.
// 1. Linear Interpolation
// Linear interpolation (lerp) computes a value between two known points. Given two values,
// a and b, and parameter t (where 0 ≤ t ≤ 1), the interpolated value is:
// lerp(a,b,t) = a + t x (b - a)...This lerp is nothing but `mix` function in glsl shaders
// Diagram
// ```
// | a | | | | | t | | b |
// ```
// --------
// Bilinear Interpolation
// Bilinear interpolation extends linear interpolation to two dimensions. For a point within a grid cell defined by four corner values (e.g. x00, x10, x01, x11)
// Interpolate along one axis (horizontal)
// v0 = lerp(x00, x10, tx)
// v1 = lerp(x01, x11, tx)
// (vertical)
// v = lerp(v0, v1, ty)
// Diagram
// ```
//  | x01 |   |   |  v0 |   | x11 |
//  |     |   |   |     |   |     |
//  |     |   |   |  v  |   |     |
//  |     |   |   |     |   |     |
//  |     |   |   |     |   |     |
//  | X00 |   |   |  v1 |   | x10 |
// ```
// 🔹 Linear Interpolation: A simple mix (first-order) between two values.
// 🔹 Bilinear Interpolation: Linear interpolation extended to two dimensions (blends four values).
// 🔹 Cubic Interpolation: Uses a third-degree polynomial for smoother curves, requiring four points, and provides continuous derivatives, which is often preferred for natural-looking noise.
// 🔹 Quadratic Interpolation: Uses a second-degree polynomial (with three points) and offers a middle ground in smoothness, but it isn’t as common in noise functions because it doesn’t provide as smooth a transition (in terms of derivative continuity) as cubic interpolation.

vec4 bilinearFilter(sampler2D tex, vec2 textureCords) {
    vec2 textureSize = vec2(2.0); // As we have 4px image it is 2 X 2 in size

    // First, convert the normalized texture coordinates into pixel space
    // and shift them so they align with pixel centers. Since texture samples
    // are taken at the center of pixels, subtracting 0.5 ensures that the
    // coordinates represent a proper position within the pixel grid.
    // The coordinates of point where we want to interpolate
    vec2 pointCoordinates = textureCords * textureSize - 0.5;

    // Determine the base coordinate of the pixel cell that contains the target point.
    // We use floor() to get the lower integer coordinate and then add 0.5 to shift to the center of that pixel.
    // This 'base' value now represents the center of the bottom-left pixel of the cell.
    vec2 base = floor(pointCoordinates) + 0.5;

    // Retrieve the color values from the four pixels that form the cell in which the point lies.
    // The offsets (0,0), (1,0), (0,1), and (1,1) are added to 'base' to locate each of the four surrounding pixels.
    // Dividing by textureSize converts the pixel positions back to normalized texture coordinates.
    //   x00: bottom-left pixel
    //   x10: bottom-right pixel
    //   x01: top-left pixel
    //   x11: top-right pixel
    vec4 x00 = texture2D(tex, (base + vec2(0.0, 0.0)) / textureSize);
    vec4 x10 = texture2D(tex, (base + vec2(1.0, 0.0)) / textureSize);
    vec4 x01 = texture2D(tex, (base + vec2(0.0, 1.0)) / textureSize);
    vec4 x11 = texture2D(tex, (base + vec2(1.0, 1.0)) / textureSize);

    // Calculate the fractional part of pointCoordinates.
    // This fraction (t.x and t.y) represents how far the point is from the base pixel's center
    // along the x (horizontal) and y (vertical) axes, respectively.
    // It will be used as the interpolation factor in the mix() function.
    vec2 t = smoothstep(0.0, 1.0, pointCoordinates);

    // Interpolate along x axis (horizontal)
    vec4 v0 = mix(x00, x10, t.x);
    vec4 v1 = mix(x01, x11, t.x);

    // Interpolate along y axis (vertical)
    vec4 v = mix(v0, v1, t.y);

    return v;
}

vec4 noiseWithBilinearFilter(vec2 textureCords) {
    vec2 textureSize = vec2(2.0);
    vec2 pointCoordinates = textureCords * textureSize;
    vec2 base = floor(pointCoordinates);

    float x00 = Math_Random((base + vec2(0.0, 0.0)) / textureSize);
    float x10 = Math_Random((base + vec2(1.0, 0.0)) / textureSize);
    float x01 = Math_Random((base + vec2(0.0, 1.0)) / textureSize);
    float x11 = Math_Random((base + vec2(1.0, 1.0)) / textureSize);

    vec2 t = smoothstep(0.0, 1.0, pointCoordinates);

    // Interpolate along x axis (horizontal)
    float v0 = mix(x00, x10, t.x);
    float v1 = mix(x01, x11, t.x);

    // Interpolate along y axis (vertical)
    float v = mix(v0, v1, t.y);

    return vec4(v);
}

void main() {
    vec2 pixelCords = (vUv - 0.5);
    vec4 color = noiseWithBilinearFilter(vUv * 100.0);

    gl_FragColor = color;
}
