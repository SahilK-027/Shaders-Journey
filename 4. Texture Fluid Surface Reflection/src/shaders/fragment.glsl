precision mediump float;

uniform float uTime;
uniform sampler2D uTexture1;

varying vec2 vUv;

// Simplex noise or fbm helpers
#define NUM_OCTAVES 4

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u * u * (3.0 - 2.0 * u);

    float res = mix(mix(random(ip), random(ip + vec2(1.0, 0.0)), u.x), mix(random(ip + vec2(0.0, 1.0)), random(ip + vec2(1.0, 1.0)), u.x), u.y);
    return res;
}

float fbm(vec2 x) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));

    for(int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 uv = vUv;

    // Define distortion based on the vertical coordinate
    float distortionStrength = smoothstep(0.49, 0.2, uv.y) * 1.3; // Restrict to the lower part

    // Create dynamic ripples using sine waves and fbm
    vec2 rippleOffset = vec2(sin(uv.y * 30.0 + uTime * 2.0) * 0.02, // Horizontal ripples
    cos(uv.x * 40.0 + uTime * 1.0) * 0.02  // Vertical ripples
    );

    // Add small-scale and large-scale fbm distortions
    vec2 fbmDistortion = vec2(fbm(uv * 40.0 + uTime * 0.5), fbm(uv * 40.0 - uTime * 0.5)) * 0.07; // Small-scale noise

    vec2 largeFbmDistortion = vec2(fbm(uv * 3.0 + uTime * 0.2), fbm(uv * 3.0 - uTime * 0.2)) * 0.05; // Large-scale noise

    // Combine distortions
    vec2 finalDistortion = distortionStrength * (rippleOffset + fbmDistortion + largeFbmDistortion);

    // Modify UVs for refraction effect
    uv += finalDistortion;

    // Sample from the sixth texture (text layer)
    vec4 textureColor = texture2D(uTexture1, uv);

    // Output the final color
    gl_FragColor = textureColor;
}
