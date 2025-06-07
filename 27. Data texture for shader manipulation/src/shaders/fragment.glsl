uniform sampler2D uTexture;  // Data texture
uniform sampler2D uWaterTexture;  // Water texture
uniform sampler2D uGrassTexture;  // Grass texture
uniform sampler2D uLandTexture;   // Land texture
uniform float uTime;
uniform float uScaleFactor;
uniform float uRandom;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;

// Improved random function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 2D Noise function
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth interpolation
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion for more complex noise
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 0.0;

    for(int i = 0; i < 4; i++) {
        value += amplitude * noise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    vec3 data = texture2D(uTexture, vUv).rgb;
    float scaleFactor = uScaleFactor * uRandom;

    vec3 color;

    if(data.b > data.r && data.b > data.g && data.b > 0.3) {
        // Water - use water texture with animated UVs for movement
        vec2 waterUV = vUv * scaleFactor;
        waterUV.x += sin(uTime * 0.5) * 0.01;
        waterUV.y += cos(uTime * 0.3) * 0.01;
        color = texture2D(uWaterTexture, waterUV).rgb;

        // Add foam effect
        float foam = sin(vPosition.x * 10.0 + uTime * 2.0) * cos(vPosition.z * 8.0 + uTime * 1.5);
        foam = smoothstep(0.7, 1.0, foam);
        color = mix(color, vec3(0.8, 0.9, 1.0), foam * 0.3);

    } else if(data.g > data.r && data.g > data.b && data.g > 0.3) {
        // Grass - Multiple techniques for organic randomness

        // Base UV coordinates
        vec2 baseUV = vUv * scaleFactor;

        // Method 1: Multiple noise layers for UV distortion
        vec2 noiseUV1 = vUv * 8.0;  // High frequency noise
        vec2 noiseUV2 = vUv * 3.0;  // Lower frequency noise

        float noiseX = fbm(noiseUV1) * 0.02 + fbm(noiseUV2) * 0.05;
        float noiseY = fbm(noiseUV1 + vec2(100.0)) * 0.02 + fbm(noiseUV2 + vec2(100.0)) * 0.05;

        vec2 distortedUV = baseUV + vec2(noiseX, noiseY);

        // Method 2: Random scale variation per "patch"
        vec2 patchCoord = floor(vUv * 4.0); // Divide into patches
        float patchRandom = random(patchCoord);
        float scaleVariation = 0.7 + patchRandom * 0.6; // Scale between 0.7 and 1.3

        vec2 grassUV = distortedUV * scaleVariation;

        // Method 3: Random rotation per patch
        float rotationAngle = patchRandom * 6.28318; // Random rotation 0-2π
        mat2 rotationMatrix = mat2(cos(rotationAngle), -sin(rotationAngle), sin(rotationAngle), cos(rotationAngle));

        // Apply rotation around patch center
        vec2 patchCenter = (floor(vUv * 4.0) + 0.5) / 4.0;
        vec2 localUV = grassUV - patchCenter * scaleFactor * scaleVariation;
        localUV = rotationMatrix * localUV;
        grassUV = localUV + patchCenter * scaleFactor * scaleVariation;

        color = texture2D(uGrassTexture, grassUV).rgb;

        // Method 4: Color variation based on multiple noise sources
        float colorNoise1 = noise(vUv * 15.0);
        float colorNoise2 = noise(vUv * 6.0 + vec2(50.0));
        float colorNoise3 = fbm(vUv * 12.0);

        // Create multiple grass color variations
        vec3 grassColor1 = color * vec3(0.8, 1.0, 0.7);   // Lighter green
        vec3 grassColor2 = color * vec3(0.6, 0.9, 0.5);   // Darker green
        vec3 grassColor3 = color * vec3(0.7, 0.8, 0.4);   // Yellowish green

        // Mix colors based on noise
        color = mix(color, grassColor1, colorNoise1 * 0.3);
        color = mix(color, grassColor2, colorNoise2 * 0.2);
        color = mix(color, grassColor3, colorNoise3 * 0.15);

        // Method 5: Add subtle wind effect
        float windEffect = sin(vPosition.x * 0.5 + uTime * 2.0) * cos(vPosition.z * 0.3 + uTime * 1.5);
        windEffect *= noise(vUv * 10.0) * 0.1; // Modulate wind by noise
        color = mix(color, color * 0.9, windEffect);

    } else {
        // Land - use land texture with noise variation
        vec2 landUV = vUv * scaleFactor;

        // Add noise-based distortion to land as well
        float landNoiseX = fbm(vUv * 6.0) * 0.03;
        float landNoiseY = fbm(vUv * 6.0 + vec2(200.0)) * 0.03;
        landUV += vec2(landNoiseX, landNoiseY);

        color = texture2D(uLandTexture, landUV).rgb;

        // Add terrain variation with multiple noise layers
        float landVariation1 = fbm(vUv * 8.0);
        float landVariation2 = noise(vUv * 20.0);
        color = mix(color, color * 0.7, landVariation1 * 0.3);
        color = mix(color, color * 1.2, landVariation2 * 0.1);
    }

    // Simple lighting based on height and normal
    float lightIntensity = (vPosition.y + 1.0) * 0.5 + 0.5;
    float normalLight = dot(vNormal, normalize(vec3(1.0, 1.0, 1.0))) * 0.5 + 0.5;
    color *= lightIntensity * normalLight;

    gl_FragColor = vec4(color, 1.0);
}