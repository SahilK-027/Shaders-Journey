uniform sampler2D uTexture;
uniform float uTime;
uniform float uWaveHeight;
uniform float uWaveSpeed;
uniform float uGroundHeight;
uniform float uGrassHeight;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;

void main() {
    vUv = uv;
    vNormal = normal;

    // Sample the image texture
    vec3 data = texture2D(uTexture, uv).rgb;

    vec3 newPosition = position;

    // Water displacement - check if blue is dominant
    if(data.b > data.r && data.b > data.g && data.b > 0.3) {
        float waveX = sin(position.x * 3.0 + uTime * uWaveSpeed) * 0.5;
        float waveY = cos(position.z * 2.5 + uTime * uWaveSpeed * 0.8) * 0.5;
        float waveZ = sin(position.x * 2.0 + position.z * 2.0 + uTime * uWaveSpeed * 1.2) * 0.3;
        newPosition.y += (waveX + waveY + waveZ) * uWaveHeight;
    }
    // Grass displacement - check if green is dominant
    else if(data.g > data.r && data.g > data.b && data.g > 0.3) {
        float cliffNoise = sin(position.x * 8.0) * cos(position.z * 6.0) * 0.1;
        newPosition.y += uGrassHeight + cliffNoise;
    }
    // Ground displacement - everything else
    else {
        float groundNoise1 = sin(position.x * 4.0) * cos(position.z * 3.0) * 0.2;
        float groundNoise2 = sin(position.x * 7.0) * cos(position.z * 5.0) * 0.1;
        newPosition.y += (groundNoise1 - groundNoise2) + uGroundHeight;
    }

    vPosition = newPosition;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}