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

    // For Toon light effect add stepiness
    shading = smoothstep(0.5, 0.505, shading);

    // Specular highlights
    float specular = dot(lightReflection, viewDirection);
    specular = clamp(specular, 0.0, 1.0);
    specular = pow(specular, specularPower);

    // For Toon light effect add stepiness
    specular = smoothstep(0.5, 0.505, specular) * specular;

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
