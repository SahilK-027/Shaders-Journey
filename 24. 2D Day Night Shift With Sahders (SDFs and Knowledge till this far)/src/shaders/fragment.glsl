uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

#include "./helpers/utils.glsl";

// Color definitions
const vec3 MORNING_COLOR1 = vec3(1.0, 0.92, 0.85);
const vec3 MORNING_COLOR2 = vec3(1.0, 0.78, 0.60);
const vec3 MIDDAY_COLOR1 = vec3(0.64, 0.93, 1.0);
const vec3 MIDDAY_COLOR2 = vec3(0.3, 0.66, 1.0);
const vec3 EVENING_COLOR1 = vec3(1.0, 0.65, 0.55);
const vec3 EVENING_COLOR2 = vec3(1.0, 0.40, 0.20);
const vec3 NIGHT_COLOR1 = vec3(0.0, 0.2118, 0.3529);
const vec3 NIGHT_COLOR2 = vec3(0.0, 0.0471, 0.2118);

const vec3 CLOUD_COLOR = vec3(1.0);
const vec3 CLOUD_SHADOW_COLOR = vec3(0.0);
const float NUM_CLOUDS = 20.0;

vec3 drawBackground() {
    float mixStrength = smoothstep(0.0, 1.0, pow(vUv.y, 0.7));

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

float sdfCloud(vec2 pixelCords) {
    float puff1 = sdfEllipse(pixelCords, vec2(1.0, 0.75));
    float puff2 = sdfEllipse(pixelCords - vec2(0.65, -1.0), vec2(0.9, 0.7));
    float puff3 = sdfEllipse(pixelCords + vec2(0.9, 1.0), vec2(1.0, 0.75));
    float puff4 = sdfEllipse(pixelCords - vec2(1.5, -1.35), vec2(0.6, 0.4));
    return min(puff1, min(puff2, min(puff3, puff4)));
}

float hash(vec2 seed) {
    float t = dot(seed, vec2(10.0, 200.0));
    return sin(t);
}

void main() {
    vec2 centeredUVs = (vUv * uResolution / 100.0);
    vec3 color = drawBackground();

    for (float i = 0.0; i < NUM_CLOUDS; i += 1.0) {
        float cloudSize = mix(2.0, 1.0, (i / NUM_CLOUDS) + 0.1 * hash(vec2(i))) * 1.75;
        float cloudSpeed = cloudSize * hash(vec2(i)) * 0.25;

        float cloudRandomOffsetY = (7.0 * hash(vec2(i))) - 8.0;

        vec2 cloudOffset = vec2(i + uTime * cloudSpeed, cloudRandomOffsetY);
        vec2 cloudPosition = centeredUVs + cloudOffset;

        cloudPosition.x = mod(cloudPosition.x, vec2(uResolution / 100.0).x);
        cloudPosition = cloudPosition - vec2(uResolution / 100.0).y * 0.5;

        float cloudShadow = sdfCloud(cloudPosition * cloudSize + 0.4) + 0.6;
        float cloudSDF = sdfCloud(cloudPosition * cloudSize);
        float shadowIntensity = 0.2;

        color = mix(mix(color, CLOUD_SHADOW_COLOR, shadowIntensity), color, smoothstep(0.0, 0.9, cloudShadow));
        color = mix(CLOUD_COLOR, color, smoothstep(0.0, 0.0075, cloudSDF));
    }

    gl_FragColor = vec4(color, 1.0);
}
