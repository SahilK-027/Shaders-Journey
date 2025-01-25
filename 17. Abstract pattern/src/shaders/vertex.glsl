uniform float uTime;
uniform float uTerrainElevation;

varying float vElevation;
varying vec2 vUv;

#include "./3DPerlinNoise.glsl";

void main() {
    // Model transformation: Transform the vertex position from local object space to `world space` using the modelMatrix.
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    
    float elevation = sin(uTerrainElevation);

    elevation -= abs(cnoise(vec3(modelPosition.xy * 3.0, uTime * 0.2)) * 0.15);

    // modelPosition.z += elevation;

    // View transformation: Transform the vertex position from world space to `view space` using the viewMatrix.
    vec4 viewPosition = viewMatrix * modelPosition;

    // Projection transformation: Transform the vertex position from view space to `clip space` using the projectionMatrix.
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    vUv = uv;

    vElevation = elevation;
}

// Theory
// 1. Local Space (Object Space)
// - This is the space where the object exists relative to itself. irrespective of anything else on screen. As if this object only sees itself.
// - Think of it as the object's "personal" coordinate system.
// - For example, the center of a cube is by default at (0, 0, 0) in local space, no matter where the cube is in the world.
// - Model Matrix is used to move from local space to world space.

// Model transformation: Transform the vertex position from local object space to `world space` using the modelMatrix.
// 2. World Space
// - This is the space where everything in the 3D scene is positioned.
// - Here, the object has been placed in the "world" along with other objects, based on the scene setup.
// - For instance, that cube at (0, 0, 0) in local space might now be at (5, 2, -3) in world space, depending on its position in the scene.
// - View Matrix is used to move from world space to view space.

// View transformation: Transform the vertex position from world space to `view space` using the viewMatrix.
// 3. View Space (Camera Space)
// - This is the space as seen from the camera's perspective.
// - It's like you're looking through the camera lens, so the object's position is now relative to the camera.
// - For example, if the camera is at (0, 0, 0) and the cube is in front of it, the cube's position is transformed to reflect how the camera "sees" it.
// Projection Matrix is used to move from view space to clip space.

// Projection transformation: Transform the vertex position from view space to `clip space` using the projectionMatrix.
// 4. Clip Space
// - This is a space where the object is ready to be projected onto the screen.
// - It’s a 2D representation of the scene, but still in a normalized coordinate system, ready for further processing.
// Once the GPU performs the perspective divide (dividing by w), it converts the positions into Normalized Device Coordinates (NDC), where (0, 0) is the center of the screen.

// In last step, what is the Perspective Divide?
// The perspective divide is the process where the clip space coordinates (which are 4D: x, y, z, and w) are divided by the w component to produce Normalized Device Coordinates (NDC).
// The formula is simple:
// NDC coordinates = (𝑥/𝑤, 𝑦/𝑤, 𝑧/𝑤)
// This is called the perspective divide because it ensures that objects farther from the camera appear smaller, giving the scene a perspective effect.

// Why Divide by w?
// The w component comes from the projection matrix, which applies perspective distortion.
// After projection, w encodes the depth information (distance from the camera).
// Dividing by w scales the x, y, and z values appropriately, so objects further away are scaled down.
// For example:
// An object at (4, 4, 10) in clip space with w = 10 becomes:
// NDC = (0.4,0.4,1.0) ... This ensures the object is "normalized" relative to its depth.

// Normalized Device Coordinates (NDC)
// After the perspective divide:
// The x and y values are now within a fixed range of [-1, 1].
// The center of the screen is (0, 0).
// Edges of the screen correspond to:
// x = -1 (left), x = 1 (right)
// y = -1 (bottom), y = 1 (top)

// Depth in NDC (z)
// The z-value is also normalized:

// Typically, z is mapped to the range [0, 1] (or sometimes [-1, 1], depending on the graphics API).
// This value is used for depth testing to determine which objects are in front of others.

// Why Is This Important?
// The NDC is a standardized space, making it easier for the GPU to:

// Map positions to screen pixels during rasterization.
// Cull objects (discard those outside the range [-1, 1], as they won't appear on screen).
// Perform depth testing using the normalized z-values
