# Important Notes

## 🧊 Understanding Vectors and Matrices in Computer Graphics

### Introduction

This guide explains how we use vectors and matrices to transform objects in computer graphics. While these mathematical concepts might seem intimidating at first, they're powerful tools that become intuitive with practice.

### Vectors

### What is a Vector?

A vector represents both direction and magnitude (length). Think of it like GPS directions:

- "Drive east for 5 miles, then north for 3 miles"
- Here, "east" and "north" are directions, while "5 miles" and "3 miles" are magnitudes

Vectors can exist in any number of dimensions, but in graphics we typically use:

- 2D vectors for screen coordinates and textures
- 3D vectors for world positions and directions
- 4D vectors for certain transformations (homogeneous coordinates)

### Vector Operations

1. Scalar Operations

When we multiply a vector by a scalar (regular number), we multiply each component:

```
Vector × 2 = [3, 4, 5] × 2 = [6, 8, 10]
```

2. Vector Negation

Negating a vector reverses its direction:

```
-[3, 4, 5] = [-3, -4, -5]
```

3. Vector Addition and Subtraction

Adding vectors means combining their components:

```
[1, 2, 3] + [4, 5, 6] = [5, 7, 9]
```

![img](./assets/vectors_addition.png)

Subtracting vectors gives us the difference between their positions:

```
[4, 5, 6] - [1, 2, 3] = [3, 3, 3]
```

![img](./assets/vectors_subtraction.png)

4. Vector Length

We calculate a vector's length using the Pythagorean theorem:

```
length = √(x² + y² + z²)
```

![img](./assets/vectors_len.png)

5. Advanced Vector Operations

- Dot Product

The dot product helps us find angles between vectors and determine how aligned they are:

```
A · B = Ax × Bx + Ay × By + Az × Bz
```

Key properties:

- Results in a single number (scalar)
- If vectors are normalized (length = 1), dot product = cos(θ)
- Equals 1 when vectors align perfectly
- Equals 0 when vectors are perpendicular
- Equals -1 when vectors point in opposite directions

- Cross Product

The cross product creates a new vector perpendicular to both input vectors:

```
A × B = [
    Ay × Bz - Az × By,
    Az × Bx - Ax × Bz,
    Ax × By - Ay × Bx
]
```

Uses:

- Creating surface normals
- Establishing coordinate systems
- Computing rotations

### Matrices

### What is a Matrix?

A matrix is a grid of numbers that we use to transform vectors and points. Each type of transformation (rotation, scaling, etc.) has its own matrix format.

### Basic Matrix Operations

1. Matrix Addition and Subtraction

Matrices of the same size can be added or subtracted element by element:

```
| 1 2 |   | 5 6 |   | 6  8 |
| 3 4 | + | 7 8 | = | 10 12 |
```

2. Matrix-Scalar Multiplication

Multiply each element by the scalar:

```
    | 1 2 |   | 2 4 |
2 × | 3 4 | = | 6 8 |
```

3. Matrix-Matrix Multiplication

Multiply rows by columns:

```
| 1 2 |   | 5 6 |   | 1×5+2×7  1×6+2×8 |
| 3 4 | × | 7 8 | = | 3×5+4×7  3×6+4×8 |
```

### Transformation Matrices

1. Scale Matrix

```
| Sx  0  0 |
|  0 Sy  0 |
|  0  0 Sz |
```

- Sx: Scale factor for x-axis
- Sy: Scale factor for y-axis
- Sz: Scale factor for z-axis

2. Translation Matrix (4×4)

```
| 1  0  0  Tx |
| 0  1  0  Ty |
| 0  0  1  Tz |
| 0  0  0   1 |
```

- Tx: Distance to move along x-axis
- Ty: Distance to move along y-axis
- Tz: Distance to move along z-axis

3. Rotation Matrix (around Z-axis)

```
| cos(θ) -sin(θ)  0  0 |
| sin(θ)  cos(θ)  0  0 |
|   0       0     1  0 |
|   0       0     0  1 |
```

- θ: Rotation angle in radians

### Practical Tips

1. Order matters in matrix multiplication

   - Scaling then rotating gives different results than rotating then scaling
   - Generally, multiply matrices from right to left

2. Common combinations

   - Model matrix = Scale × Rotation × Translation
   - View matrix = Camera's inverse transformation
   - Projection matrix = Perspective or orthographic projection

3. Performance considerations
   - Combine multiple transformations into a single matrix when possible
   - Use 4×4 matrices for consistency, even for 2D transformations
   - Cache frequently used matrices (like the identity matrix)

While the math may look complex, modern graphics libraries handle most of the details. Focus on understanding the concepts, and the implementation will become natural with practice.

## ፨ Coordinate Systems

Before starting to read the next section go ahead and watch this:

https://github.com/user-attachments/assets/e7764194-e2cd-4412-a4e5-4b44a1b1e245

credits:

- https://www.youtube.com/@MiolithYT
- https://youtu.be/o-xwmTODTUI?feature=shared

### The global

![img](/assets/global-positioning.png)

### Local space (Object Space)

- This is the space where the object exists relative to itself. irrespective of anything else on screen. As if this object only sees itself.
- Think of it as the object's "personal" coordinate system.
- For example, the center of a cube is by default at (0, 0, 0) in local space, no matter where the cube is in the world.
- Model Matrix is used to move from local space to world space.

Model transformation: Transform the vertex position from local object space to `world space` using the modelMatrix.

### World space

- This is the space where everything in the 3D scene is positioned.
- Here, the object has been placed in the "world" along with other objects, based on the scene setup.
- For instance, that cube at (0, 0, 0) in local space might now be at (5, 2, -3) in world space, depending on its position in the scene.
- View Matrix is used to move from world space to view space.

View transformation: Transform the vertex position from world space to `view space` using the viewMatrix.

### View space (Camera Space)

- This is the space as seen from the camera's perspective.
- It's like you're looking through the camera lens, so the object's position is now relative to the camera.
- For example, if the camera is at (0, 0, 0) and the cube is in front of it, the cube's position is transformed to reflect how the camera "sees" it.
  Projection Matrix is used to move from view space to clip space.

Projection transformation: Transform the vertex position from view space to `clip space` using the projectionMatrix.

### Clip space

- This is a space where the object is ready to be projected onto the screen.
- It’s a 2D representation of the scene, but still in a normalized coordinate system, ready for further processing.
  Once the GPU performs the perspective divide (dividing by w), it converts the positions into Normalized Device Coordinates (NDC), where (0, 0) is the center of the screen.

### In last step, what is the Perspective Divide?

- The perspective divide is the process where the clip space coordinates (which are 4D: x, y, z, and w) are divided by the w component to produce Normalized Device Coordinates (NDC).
- The formula is simple:

```glsl
   NDC coordinates = (𝑥/𝑤, 𝑦/𝑤, 𝑧/𝑤)
```

- This is called the perspective divide because it ensures that objects farther from the camera appear smaller, giving the scene a perspective effect.

### Why Divide by w?

- The w component comes from the projection matrix, which applies perspective distortion.
- After projection, w encodes the depth information (distance from the camera).
- Dividing by w scales the x, y, and z values appropriately, so objects further away are scaled down.
- For example:

```glsl
   An object at (4, 4, 10) in clip space with w = 10 becomes:
   NDC = (0.4,0.4,1.0) ... This ensures the object is "normalized" relative to its depth.
```

### Normalized Device Coordinates (NDC)

- After the perspective divide:
- The x and y values are now within a fixed range of [-1, 1].
- The center of the screen is (0, 0).
- Edges of the screen correspond to:

```glsl
   x = -1 (left), x = 1 (right)
   y = -1 (bottom), y = 1 (top)
```

### epth in NDC (z)

- The z-value is also normalized:
- Typically, z is mapped to the range [0, 1] (or sometimes [-1, 1], depending on the graphics API).
- This value is used for depth testing to determine which objects are in front of others.

### Why Is This Important?

- The NDC is a standardized space, making it easier for the GPU to:
- Map positions to screen pixels during rasterization.
- Cull objects (discard those outside the range [-1, 1], as they won't appear on screen).
- Perform depth testing using the normalized z-values

### Orthographic projection

### Perspective projection
