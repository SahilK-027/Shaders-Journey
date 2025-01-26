vec3 directionalLight(vec3 color, float intensity, vec3 normal, vec3 position, vec3 viewDirection, float specularPower) {
    vec3 lightDirection = normalize(position);
    vec3 lightReflection = reflect(-lightDirection, normal);

    // Shading
    float shading = dot(normal, lightDirection);

    shading *= step(0.5, shading);

    // Eliminate -ve values after fot product
    shading = clamp(shading, 0.0, 1.0);

    float specular = -dot(lightReflection, viewDirection);

    // Eliminate -ve values after fot product
    specular = clamp(specular, 0.0, 1.0);
    // Adjust specular tint based on power
    specular = pow(specular, specularPower);

    specular *= step(0.5, specular);

    return color * intensity * (shading + specular);
}
