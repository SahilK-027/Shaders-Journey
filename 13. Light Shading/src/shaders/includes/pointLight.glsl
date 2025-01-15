vec3 pointLight(vec3 color, float intensity, vec3 normal, vec3 position, vec3 viewDirection, float specularPower, vec3 surfaceVertexPosition, float lightDecay) {
    vec3 lightDelta = position - surfaceVertexPosition;
    float lightDistance = length(lightDelta);
    vec3 lightDirection = normalize(lightDelta);
    vec3 lightReflection = reflect(-lightDirection, normal);

    // Shading
    float shading = dot(normal, lightDirection);
    // Eliminate -ve values after fot product
    shading = clamp(shading, 0.0, 1.0);

    float specular = -dot(lightReflection, viewDirection);
    // Eliminate -ve values after fot product
    specular = clamp(specular, 0.0, 1.0);
    // Adjust specular tint based on power
    specular = pow(specular, specularPower);

    // Decay
    float decay = 1.0 - lightDistance * lightDecay;
    decay = clamp(decay, 0.0, 1.0);

    return color * intensity * decay * (shading + specular);
}
