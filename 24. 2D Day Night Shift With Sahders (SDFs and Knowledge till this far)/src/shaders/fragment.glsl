uniform float uTime;
uniform float uRandomFloat;
uniform vec2 uResolution;
varying vec2 vUv;

#include "./helpers/utils.glsl";

//--------------------------------------
// Constants
//--------------------------------------
const float DAY_LENGTH = 20.0;

// Background Colors
const vec3 MORNING_COLOR1 = vec3(1.0, 0.89, 0.79);
const vec3 MORNING_COLOR2 = vec3(1.0, 0.77, 0.59);
const vec3 MIDDAY_COLOR1 = vec3(0.64, 0.93, 1.0);
const vec3 MIDDAY_COLOR2 = vec3(0.3, 0.66, 1.0);
const vec3 EVENING_COLOR1 = vec3(1.0, 0.6, 0.48);
const vec3 EVENING_COLOR2 = vec3(1.0, 0.39, 0.18);
const vec3 NIGHT_COLOR1 = vec3(0.0, 0.2118, 0.3529);
const vec3 NIGHT_COLOR2 = vec3(0.0, 0.0471, 0.2118);

// Color Multipliers (for clouds and water)
const vec3 MORNING_COLOR_MULTIPLIER = vec3(1.0, 0.97, 0.91);
const vec3 MIDDAY_COLOR_MULTIPLIER_WATER = vec3(0.55, 0.79, 1.0);
const vec3 MIDDAY_COLOR_MULTIPLIER_CLOUD = vec3(0.72, 0.88, 1.0);
const vec3 EVENING_COLOR_MULTIPLIER_WATER = vec3(1.0, 0.52, 0.79);
const vec3 EVENING_COLOR_MULTIPLIER_CLOUD = vec3(1.0, 0.77, 0.76);
const vec3 NIGHT_COLOR_MULTIPLIER_WATER = vec3(0.4);
const vec3 NIGHT_COLOR_MULTIPLIER_CLOUD = vec3(0.68);

// Cloud parameters
const vec3 CLOUD_COLOR = vec3(1.0);
const vec3 CLOUD_SHADOW_COLOR = vec3(0.0);
const float NUM_CLOUDS = 15.0;

// Water Colors
const vec3 WATER_COLOR1 = vec3(0.48, 0.83, 1.0);
const vec3 WATER_COLOR2 = vec3(0.3, 0.71, 1.0);
const vec3 WATER_COLOR3 = vec3(0.17, 0.55, 0.85);
const vec3 WATER_COLOR4 = vec3(0.0, 0.45, 0.91);
const vec3 WATER_COLOR5 = vec3(0.0, 0.37, 0.75);
const vec3 WATER_SHADOW_COLOR = vec3(0.0, 0.13, 0.25);
const float waterShadowIntensity = 0.15;

// Sun colors
const vec3 MORNING_COLOR_MULTIPLIER_SUN = vec3(1.0, 0.68, 0.09);
const vec3 MIDDAY_COLOR_MULTIPLIER_SUN = vec3(1.0, 0.96, 0.85);
const vec3 EVENING_COLOR_MULTIPLIER_SUN = vec3(1.0, 0.36, 0.36);
const vec3 NIGHT_COLOR_MULTIPLIER_SUN = vec3(0.68);
const vec3 SUN_COLOR = vec3(1.0, 0.77, 0.0);

//--------------------------------------
// Helper Functions
//--------------------------------------

// Returns a color that cycles through the four provided colors
// over the full day (DAY_LENGTH). Use for both background and multipliers.
vec3 getDayCycleColor(vec3 cMorning, vec3 cMidday, vec3 cEvening, vec3 cNight, float dayTime) {
    if (dayTime < DAY_LENGTH * 0.25)
        return mix(cMorning, cMidday, smoothstep(0.0, DAY_LENGTH * 0.25, dayTime));
    else if (dayTime < DAY_LENGTH * 0.5)
        return mix(cMidday, cEvening, smoothstep(DAY_LENGTH * 0.25, DAY_LENGTH * 0.5, dayTime));
    else if (dayTime < DAY_LENGTH * 0.75)
        return mix(cEvening, cNight, smoothstep(DAY_LENGTH * 0.5, DAY_LENGTH * 0.75, dayTime));
    else
        return mix(cNight, cMorning, smoothstep(DAY_LENGTH * 0.75, DAY_LENGTH, dayTime));
}

//--------------------------------------
// SDF Functions
//--------------------------------------
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

// Draws the background by blending four day-cycle colors.
vec3 drawBackground(float dayTime) {
    float mixStrength = smoothstep(0.0, 1.0, pow(vUv.x * vUv.y, 0.7));
    vec3 morning = mix(MORNING_COLOR1, MORNING_COLOR2, mixStrength);
    vec3 midday = mix(MIDDAY_COLOR1, MIDDAY_COLOR2, mixStrength);
    vec3 evening = mix(EVENING_COLOR1, EVENING_COLOR2, mixStrength);
    vec3 night = mix(NIGHT_COLOR1, NIGHT_COLOR2, mixStrength);
    return getDayCycleColor(morning, midday, evening, night, dayTime);
}

// Draws clouds using SDFs and applies a day-cycle multiplier.
vec3 drawClouds(vec2 centeredUVs, vec3 col, float dayTime) {
    vec3 color = col;
    vec3 cloudMultiplier = getDayCycleColor(MORNING_COLOR_MULTIPLIER, MIDDAY_COLOR_MULTIPLIER_CLOUD, EVENING_COLOR_MULTIPLIER_CLOUD, NIGHT_COLOR_MULTIPLIER_CLOUD, dayTime);

    for (float i = 0.0; i < NUM_CLOUDS; i += 1.0) {
        float cloudSize = mix(2.0, 1.0, (i / NUM_CLOUDS) + 0.1 * hash(vec2(i))) * 1.6;
        float cloudSpeedHash = remap(hash(vec2(i * cloudSize + uRandomFloat)), -1.0, 1.0, 0.8, 1.0);
        float cloudSpeed = cloudSize * cloudSpeedHash * 0.12;
        float cloudRandomOffsetY = (7.0 * hash(vec2(i))) - 8.0;

        vec2 cloudOffset = vec2(i * (uRandomFloat + 2.0) + uTime * cloudSpeed, cloudRandomOffsetY);
        vec2 cloudPosition = centeredUVs + cloudOffset;
        cloudPosition.x = mod(cloudPosition.x, uResolution.x / 100.0);
        cloudPosition -= vec2(uResolution / 100.0) * 0.5;

        float cloudShadow = sdfCloud(cloudPosition * cloudSize + 0.4) + 0.6;
        float cloudSDF = sdfCloud(cloudPosition * cloudSize);
        float shadowIntensity = 0.2;

        color = mix(mix(color, CLOUD_SHADOW_COLOR, shadowIntensity), color, smoothstep(0.0, 0.9, cloudShadow));
        float randomColorHash = remap(hash(vec2(i)), -1.0, 1.0, 0.5, 1.0);
        vec3 randomFactor = mix(vec3(0.75), vec3(1.1), vec3(randomColorHash));
        color = mix(CLOUD_COLOR * cloudMultiplier * randomFactor, color, smoothstep(0.0, 0.0075, cloudSDF));
    }
    return color;
}

// Draws animated water waves and blends water colors with a day-cycle multiplier.
vec3 drawWater(vec2 centeredUVs, vec3 col, float dayTime) {
    vec3 color = col;
    vec2 waveBase = centeredUVs;

    // Perspective factor for depth: waves near the bottom use full amplitude.
    float perspectiveFactor = mix(1.0, 0.5, vUv.y);

    // Random factors per layer
    float r1 = 0.7 + 0.7 * hash(vec2(1.0, 2.0));
    float r2 = 0.8 + 0.6 * hash(vec2(3.0, 4.0));
    float r3 = 0.9 + 0.4 * hash(vec2(5.0, 6.0));
    float r4 = 1.3 + 0.3 * hash(vec2(7.0, 8.0));
    float r5 = 0.9 + 0.8 * hash(vec2(9.0, 10.0));

    vec2 offset1 = vec2(sin(uTime * 0.5) * 0.7, cos(uTime * 0.3) * 0.19) * r1 * perspectiveFactor;
    vec2 offset2 = vec2(sin(uTime * 0.7 + 0.5) * 0.2, cos(uTime * 0.6) * 0.12) * r2 * perspectiveFactor;
    vec2 offset3 = vec2(sin(uTime * 0.8 + 1.0) * 0.5, cos(uTime * 0.4 + 1.0) * 0.15) * r3 * perspectiveFactor;
    vec2 offset4 = vec2(sin(uTime * 0.7 + 2.0) * 0.3, cos(uTime * 0.5 + 2.0) * 0.175) * r4 * perspectiveFactor;
    vec2 offset5 = vec2(sin(uTime * 1.2 + 3.0) * 0.3, cos(uTime * 0.6 + 3.0) * 0.20) * r5 * perspectiveFactor;

    // Adjusted radii for perspective
    float r0 = 0.19 * perspectiveFactor;
    float r1_adj = 0.12 * perspectiveFactor;
    float r2_adj = 0.178 * perspectiveFactor;

    float waveSDF = sdfCircleWave(waveBase + vec2(0.0, 0.5) + offset1, r0, 3.0, 0.9);
    float waveShadowSDF = sdfCircleWave(waveBase + vec2(0.0, 0.6) + offset1, r0, 3.0, 0.9);
    float waveSDF2 = sdfCircleWave(waveBase + vec2(0.0, 1.2) + offset2, r1_adj, 3.0, 0.9);
    float waveShadowSDF2 = sdfCircleWave(waveBase + vec2(0.0, 1.3) + offset2, r1_adj, 3.0, 0.9);
    float waveSDF3 = sdfCircleWave(waveBase + vec2(0.9, 1.7) + offset3, 0.1, 3.0, 0.9);
    float waveShadowSDF3 = sdfCircleWave(waveBase + vec2(0.9, 1.8) + offset3, 0.1, 3.0, 0.9);
    float waveSDF4 = sdfCircleWave(waveBase + vec2(-0.9, 2.41) + offset4, r2_adj, 3.0, 0.9);
    float waveShadowSDF4 = sdfCircleWave(waveBase + vec2(-0.9, 2.51) + offset4, r2_adj, 3.0, 0.9);
    float waveSDF5 = sdfCircleWave(waveBase + vec2(0.0, 3.0) + offset5, 0.156, 3.0, 0.9);
    float waveShadowSDF5 = sdfCircleWave(waveBase + vec2(0.0, 3.1) + offset5, 0.156, 3.0, 0.9);

    vec3 waterMultiplier = getDayCycleColor(MORNING_COLOR_MULTIPLIER, MIDDAY_COLOR_MULTIPLIER_WATER, EVENING_COLOR_MULTIPLIER_WATER, NIGHT_COLOR_MULTIPLIER_WATER, dayTime);

    color = mix(mix(color, WATER_SHADOW_COLOR, waterShadowIntensity), color, smoothstep(0.0, 0.2, waveShadowSDF));
    color = mix(WATER_COLOR1 * waterMultiplier, color, smoothstep(0.0, 0.0075, waveSDF));

    color = mix(mix(color, WATER_SHADOW_COLOR, waterShadowIntensity), color, smoothstep(0.0, 0.2, waveShadowSDF2));
    color = mix(WATER_COLOR2 * waterMultiplier, color, smoothstep(0.0, 0.0075, waveSDF2));

    color = mix(mix(color, WATER_SHADOW_COLOR, waterShadowIntensity), color, smoothstep(0.0, 0.2, waveShadowSDF3));
    color = mix(WATER_COLOR3 * waterMultiplier, color, smoothstep(0.0, 0.0075, waveSDF3));

    color = mix(mix(color, WATER_SHADOW_COLOR, waterShadowIntensity), color, smoothstep(0.0, 0.2, waveShadowSDF4));
    color = mix(WATER_COLOR4 * waterMultiplier, color, smoothstep(0.0, 0.0075, waveSDF4));

    color = mix(mix(color, WATER_SHADOW_COLOR, waterShadowIntensity), color, smoothstep(0.0, 0.2, waveShadowSDF5));
    color = mix(WATER_COLOR5 * waterMultiplier, color, smoothstep(0.0, 0.0075, waveSDF5));

    return color;
}

vec3 drawSun(vec2 centeredUVs, vec3 col, float dayTime) {
    vec3 color = col;
    vec3 sunColorMultiplier = getDayCycleColor(
            MORNING_COLOR_MULTIPLIER,
            MIDDAY_COLOR_MULTIPLIER_SUN,
            EVENING_COLOR_MULTIPLIER_SUN,
            NIGHT_COLOR_MULTIPLIER_SUN,
            dayTime
        );

    // Only draw the sun if dayTime is less than 75% of the day.
    if (dayTime < DAY_LENGTH * 0.7) {
        vec2 sunOffset;
        // Sunrise: 0.0 -> 0.25 of the day: interpolate from -4.0 to 2.5 (y axis)
        if (dayTime < DAY_LENGTH * 0.25) {
            float t = saturate(inverseLerp(dayTime, 0.0, DAY_LENGTH * 0.25));
            sunOffset = vec2(0.0, mix(-4.0, 0.2, t));
        }
        // Midday: 0.25 -> 0.5 of the day: sun stays at peak.
        else if (dayTime < DAY_LENGTH * 0.5) {
            sunOffset = vec2(0.0, 0.2);
        }
        // Sunset: 0.5 -> 0.75 of the day: interpolate from 0.2 down to -4.0.
        else {
            float t = saturate(inverseLerp(dayTime, DAY_LENGTH * 0.5, DAY_LENGTH * 0.7));
            sunOffset = vec2(0.0, mix(0.2, -4.0, t));
        }

        // Optionally, add a horizontal baseline offset.
        vec2 baseOffset = vec2(-5.0, 2.5);
        sunOffset += baseOffset;

        vec2 sunPos = centeredUVs - (0.5 * uResolution / 100.0) - sunOffset;
        float sunSDF = sdfCircle(sunPos, 0.8);
        color = mix(SUN_COLOR * sunColorMultiplier, color, smoothstep(0.0, 0.0075, sunSDF));

        float pulse = remap(sin(uTime * 2.0), -1.0, 1.0, 0.3, 1.0);
        float glowFactor = 1.0 - smoothstep(0.1, 0.8, sunSDF);
        color += SUN_COLOR * sunColorMultiplier * glowFactor * 0.125 * pulse;
    }
    return color;
}

//--------------------------------------
// Main
//--------------------------------------
void main() {
    float dayTime = mod(uTime, DAY_LENGTH);
    vec2 centeredUVs = (vUv * uResolution / 100.0);

    vec3 color = drawBackground(dayTime);

    color = drawSun(centeredUVs, color, dayTime);
    color = drawClouds(centeredUVs, color, dayTime);
    color = drawWater(centeredUVs, color, dayTime);

    gl_FragColor = vec4(color, 1.0);
}
