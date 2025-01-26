uniform sampler2D uModelTexture;
uniform samplerCube uEnvironmentMap;
uniform vec3 uLightColor;
uniform float uLightIntensity;
uniform vec3 uLightPosition;
uniform float uSpecularPower;
uniform vec3 uRimLightColor;
uniform float uRimLightPower;
uniform float uEnvironmentReflectionIntensity;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vViewDirection;

vec3 directionalLight(vec3 color, float intensity, vec3 normal, vec3 lightPosition, vec3 viewDirection, float specularPower) {
    vec3 lightDirection = normalize(lightPosition);
    vec3 lightReflection = reflect(-lightDirection, normal);

    // Diffuse shading
    float shading = dot(normal, lightDirection);
    shading = clamp(shading, 0.0, 1.0);

    // Single tone
    // For Toon light effect add stepiness
    // shading = smoothstep(0.5, 0.505, shading);

    // Three-tone shading (using step functions to create discrete intensity levels)
    float tone1 = step(0.5, shading);
    float tone2 = step(0.25, shading) * (1.0 - tone1);
    shading = tone1 * 2.0 + tone2 * 1.0;

    // Five-tone shading (using step functions to create discrete intensity levels)
    // float tone1 = step(0.8, shading);
    // float tone2 = step(0.6, shading) * (1.0 - tone1);
    // float tone3 = step(0.4, shading) * (1.0 - tone1 - tone2);
    // float tone4 = step(0.2, shading) * (1.0 - tone1 - tone2 - tone3);
    // shading = tone1 * 4.0 + tone2 * 3.0 + tone3 * 2.0 + tone4 * 1.0;

    // Specular highlights
    float specular = dot(lightReflection, viewDirection);
    specular = clamp(specular, 0.0, 1.0);
    specular = pow(specular, specularPower);

    // Single tone
    // For Toon light effect add stepiness
    // specular = smoothstep(0.5, 0.505, specular) * specular;

    // Three-tone specular (discrete steps)
    float specularTone1 = step(0.5, specular);
    float specularTone2 = step(0.25, specular) * (1.0 - specularTone1);
    specular = specularTone1 * 2.0 + specularTone2 * 1.0;

    // Five-tone specular (discrete steps)
    // float specularTone1 = step(0.8, specular);
    // float specularTone2 = step(0.6, specular) * (1.0 - specularTone1);
    // float specularTone3 = step(0.4, specular) * (1.0 - specularTone1 - specularTone2);
    // float specularTone4 = step(0.2, specular) * (1.0 - specularTone1 - specularTone2 - specularTone3);
    // specular = specularTone1 * 4.0 + specularTone2 * 3.0 + specularTone3 * 2.0 + specularTone4 * 1.0;

    return color * intensity * (shading + specular);
}

vec3 gammaCorrection(vec3 color) {
    return pow(color, vec3(1.0 / 2.2));
}

void main() {
    vec3 normal = normalize(vNormal);

    // Sample the model's base texture
    vec3 baseColor = texture2D(uModelTexture, vUv).rgb;

    vec3 lighting = vec3(0.0);

    // Directional light setup using uniforms
    vec3 directionalLighting = directionalLight(
            uLightColor,
            uLightIntensity,
            normal,
            uLightPosition,
            vViewDirection,
            uSpecularPower
        );
    lighting += directionalLighting;

    // Environment map reflection for subtle highlights using uniform for intensity
    vec3 environmentSampleCoordinates = normalize(reflect(-vViewDirection, vNormal));
    vec3 envSampling = textureCube(uEnvironmentMap, environmentSampleCoordinates).xyz * uEnvironmentReflectionIntensity;
    lighting += envSampling;

    // Fresnel effect for rim lighting using uniforms
    float fresnel = 1.0 - max(dot(vViewDirection, vNormal), 0.0);
    fresnel = pow(fresnel, uRimLightPower);
    vec3 rimLight = uRimLightColor * fresnel;

    vec3 color = baseColor * (lighting + rimLight);
    color = gammaCorrection(color);

    gl_FragColor = vec4(color, 1.0);
}
