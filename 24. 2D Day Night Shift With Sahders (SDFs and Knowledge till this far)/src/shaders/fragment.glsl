uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

#include "./helpers/utils.glsl"

//--------------------------------------
// Constants & Color Definitions
//--------------------------------------

// Background colors for different times of day
const vec3 MORNING_COLOR1 = vec3(1.0, 0.89, 0.79);
const vec3 MORNING_COLOR2 = vec3(1.0, 0.77, 0.59);
const vec3 MIDDAY_COLOR1 = vec3(0.64, 0.93, 1.0);
const vec3 MIDDAY_COLOR2 = vec3(0.3, 0.66, 1.0);
const vec3 EVENING_COLOR1 = vec3(1.0, 0.6, 0.48);
const vec3 EVENING_COLOR2 = vec3(1.0, 0.39, 0.18);
const vec3 NIGHT_COLOR1 = vec3(0.0, 0.2118, 0.3529);
const vec3 NIGHT_COLOR2 = vec3(0.0, 0.0471, 0.2118);

const vec3 MORNING_COLOR_MULTIPLIER = vec3(1.0, 0.97, 0.95);
const vec3 MIDDAY_COLOR_MULTIPLIER = vec3(0.65, 0.83, 1.0);
const vec3 EVENING_COLOR_MULTIPLIER = vec3(1.0, 0.52, 0.79);
const vec3 NIGHT_COLOR_MULTIPLIER = vec3(0.5);

// Cloud colors & parameters
const vec3 CLOUD_COLOR = vec3(1.0);
const vec3 CLOUD_SHADOW_COLOR = vec3(0.0);
const float NUM_CLOUDS = 21.0;

// Water colors & shadow
const vec3 WATER_COLOR1 = vec3(0.48, 0.83, 1.0);
const vec3 WATER_COLOR2 = vec3(0.3, 0.71, 1.0);
const vec3 WATER_COLOR3 = vec3(0.17, 0.55, 0.85);
const vec3 WATER_COLOR4 = vec3(0.0, 0.45, 0.91);
const vec3 WATER_COLOR5 = vec3(0.0, 0.37, 0.75);

float waterShadowIntensity = 0.1;

//--------------------------------------
// SDF Functions
//--------------------------------------

// SDF for cloud shape (combines several ellipses)
float sdfCloud(vec2 pixelCords) {
    float puff1 = sdfEllipse(pixelCords, vec2(1.0, 0.75));
    float puff2 = sdfEllipse(pixelCords - vec2(0.65, -1.0), vec2(0.9, 0.7));
    float puff3 = sdfEllipse(pixelCords + vec2(0.9, 1.0), vec2(1.0, 0.75));
    float puff4 = sdfEllipse(pixelCords - vec2(1.5, -1.35), vec2(0.6, 0.4));
    return min(puff1, min(puff2, min(puff3, puff4)));
}

//--------------------------------------
// Scene Drawing Functions
//--------------------------------------

// Draws the background by blending colors based on vUv and time-of-day
vec3 drawBackground() {
    float mixStrength = smoothstep(0.0, 1.0, pow(vUv.x * vUv.y, 0.7));
    vec3 morning = mix(MORNING_COLOR1, MORNING_COLOR2, mixStrength);
    vec3 midday = mix(MIDDAY_COLOR1, MIDDAY_COLOR2, mixStrength);
    vec3 evening = mix(EVENING_COLOR1, EVENING_COLOR2, mixStrength);
    vec3 night = mix(NIGHT_COLOR1, NIGHT_COLOR2, mixStrength);

    float dayLength = 40.0;
    float dayTime = mod(uTime, dayLength);
    vec3 finalColor;

    if (dayTime < dayLength * 0.25) {
        finalColor = mix(morning, midday, smoothstep(0.0, dayLength * 0.25, dayTime));
    } else if (dayTime < dayLength * 0.5) {
        finalColor = mix(midday, evening, smoothstep(dayLength * 0.25, dayLength * 0.5, dayTime));
    } else if (dayTime < dayLength * 0.75) {
        finalColor = mix(evening, night, smoothstep(dayLength * 0.5, dayLength * 0.75, dayTime));
    } else {
        finalColor = mix(night, morning, smoothstep(dayLength * 0.75, dayLength, dayTime));
    }
    return finalColor;
}

// Draws clouds using SDFs and blends them into the scene color
vec3 drawClouds(vec2 centeredUVs, vec3 col) {
    vec3 color = col;
    for (float i = 0.0; i < NUM_CLOUDS; i += 1.0) {
        float cloudSize = mix(2.0, 1.0, (i / NUM_CLOUDS) + 0.1 * hash(vec2(i))) * 1.5;
        float cloudSpeed = cloudSize * hash(vec2(i)) * 0.25;
        float cloudRandomOffsetY = (7.0 * hash(vec2(i))) - 8.0;
        vec2 cloudOffset = vec2(i + uTime * cloudSpeed, cloudRandomOffsetY);
        vec2 cloudPosition = centeredUVs + cloudOffset;
        cloudPosition.x = mod(cloudPosition.x, vec2(uResolution / 100.0).x);
        cloudPosition -= vec2(uResolution / 100.0).y * 0.5;

        float cloudShadow = sdfCloud(cloudPosition * cloudSize + 0.4) + 0.6;
        float cloudSDF = sdfCloud(cloudPosition * cloudSize);
        float shadowIntensity = 0.2;
        color = mix(mix(color, CLOUD_SHADOW_COLOR, shadowIntensity), color, smoothstep(0.0, 0.9, cloudShadow));
        color = mix(CLOUD_COLOR, color, smoothstep(0.0, 0.0075, cloudSDF));
    }
    return color;
}

// Draws and animates water waves by applying time-varying offsets with added randomness and distancing
vec3 drawWater(vec2 centeredUVs, vec3 col) {
    vec3 color = col;
    vec2 waveBase = centeredUVs;

    // Compute a perspective factor so waves appear smaller (less animated) as they recede vertically.
    // vUv is assumed to be in [0,1]; waves near the bottom (vUv.y=0) use full amplitude, while near the top they are reduced.
    float perspectiveFactor = mix(1.0, 0.5, vUv.y);

    // Generate per-layer random factors for variation (these remain constant over time)
    float r1 = 0.7 + 0.7 * hash(vec2(1.0, 2.0));
    float r2 = 0.8 + 0.6 * hash(vec2(3.0, 4.0));
    float r3 = 0.9 + 0.4 * hash(vec2(5.0, 6.0));
    float r4 = 1.3 + 0.3 * hash(vec2(7.0, 8.0));
    float r5 = 0.9 + 0.8 * hash(vec2(9.0, 10.0));

    // Animated offsets for each water wave layer, modulated by random factors and perspective
    vec2 offset1 = vec2(sin(uTime * 0.5) * 0.7, cos(uTime * 0.3) * 0.19) * r1 * perspectiveFactor;
    vec2 offset2 = vec2(sin(uTime * 0.7 + 0.5) * 0.2, cos(uTime * 0.6) * 0.12) * r2 * perspectiveFactor;
    vec2 offset3 = vec2(sin(uTime * 0.8 + 1.0) * 0.5, cos(uTime * 0.4 + 1.0) * 0.15) * r3 * perspectiveFactor;
    vec2 offset4 = vec2(sin(uTime * 0.7 + 2.0) * 0.3, cos(uTime * 0.5 + 2.0) * 0.175) * r4 * perspectiveFactor;
    vec2 offset5 = vec2(sin(uTime * 1.2 + 3.0) * 0.3, cos(uTime * 0.6 + 3.0) * 0.20) * r5 * perspectiveFactor;

    // Adjust wave radii by perspective factor to simulate distant waves being slightly smaller
    float r0 = 0.19 * perspectiveFactor;
    float r1_adj = 0.12 * perspectiveFactor;
    float r2_adj = 0.178 * perspectiveFactor;

    // Compute SDFs for each water wave layer using distinct offsets
    float waveSDF = sdfCircleWave(waveBase + vec2(0.0, 0.5) + offset1, r0, 3.0, 0.9);
    float waveSDF2 = sdfCircleWave(waveBase + vec2(0.0, 1.2) + offset2, r1_adj, 3.0, 0.9);
    float waveSDF3 = sdfCircleWave(waveBase + vec2(0.9, 1.7) + offset3, 0.1, 3.0, 0.9);
    float waveSDF4 = sdfCircleWave(waveBase + vec2(-0.9, 2.41) + offset4, r2_adj, 3.0, 0.9);
    float waveSDF5 = sdfCircleWave(waveBase + vec2(0.0, 3.0) + offset5, 0.156, 3.0, 0.9);

    // Compute environment-based water color multiplier (changes with time-of-day)
    vec3 WATER_COLOR_MULTIPLIER = vec3(1.0);
    float dayLength = 40.0;
    float dayTime = mod(uTime, dayLength);
    if (dayTime < dayLength * 0.25) {
        WATER_COLOR_MULTIPLIER = mix(MORNING_COLOR_MULTIPLIER, MIDDAY_COLOR_MULTIPLIER, smoothstep(0.0, dayLength * 0.25, dayTime));
    } else if (dayTime < dayLength * 0.5) {
        WATER_COLOR_MULTIPLIER = mix(MIDDAY_COLOR_MULTIPLIER, EVENING_COLOR_MULTIPLIER, smoothstep(dayLength * 0.25, dayLength * 0.5, dayTime));
    } else if (dayTime < dayLength * 0.75) {
        WATER_COLOR_MULTIPLIER = mix(EVENING_COLOR_MULTIPLIER, NIGHT_COLOR_MULTIPLIER, smoothstep(dayLength * 0.5, dayLength * 0.75, dayTime));
    } else {
        WATER_COLOR_MULTIPLIER = mix(NIGHT_COLOR_MULTIPLIER, MORNING_COLOR_MULTIPLIER, smoothstep(dayLength * 0.75, dayLength, dayTime));
    }

    // Blend water colors (with the time-based multiplier) over the scene using soft transitions
    color = mix(WATER_COLOR1 * WATER_COLOR_MULTIPLIER, color, smoothstep(0.0, 0.0075, waveSDF));
    color = mix(WATER_COLOR2 * WATER_COLOR_MULTIPLIER, color, smoothstep(0.0, 0.0075, waveSDF2));
    color = mix(WATER_COLOR3 * WATER_COLOR_MULTIPLIER, color, smoothstep(0.0, 0.0075, waveSDF3));
    color = mix(WATER_COLOR4 * WATER_COLOR_MULTIPLIER, color, smoothstep(0.0, 0.0075, waveSDF4));
    color = mix(WATER_COLOR5 * WATER_COLOR_MULTIPLIER, color, smoothstep(0.0, 0.0075, waveSDF5));

    return color;
}

//--------------------------------------
// Main
//--------------------------------------
void main() {
    // Scale vUv to a centered coordinate system
    vec2 centeredUVs = (vUv * uResolution / 100.0);

    // Draw the background and clouds first
    vec3 color = drawBackground();
    color = drawClouds(centeredUVs, color);

    // Draw animated water waves (with improved color, distancing, and randomness)
    color = drawWater(centeredUVs, color);

    gl_FragColor = vec4(color, 1.0);
}
