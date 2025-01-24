uniform vec3 uCameraPosition; // Camera position passed as a uniform
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec3 vViewDirection; // Varying for the view direction

void main() {
    // Transform the normals & position upon rotation, scale, translation
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    vec4 modelNormal = modelMatrix * vec4(normal, 0.0);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

    vUv = uv;
    vNormal = modelNormal.xyz;
    vPosition = modelPosition.xyz;

    // Compute the view direction in world space
    vViewDirection = normalize(cameraPosition - vPosition); // Pass view direction
}
