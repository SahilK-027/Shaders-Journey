# Important Notes

## How matrix transformations works under the hood

By using (multiple) matrix objects, we can easily transform (Scale, rotate etc.) an object.

Matrices are very powerful mathematical constructs that seem scary at first, but once you'll grow accustomed to them they'll prove extremely useful.

But, to fully understand transformations we first have to delve a bit deeper into vectors before discussing matrices.

### Vectors

In its most basic definition, vectors are directions and nothing more. A vector has a direction and a magnitude (also known as its strength or length). You can think of vectors like directions on a treasure map: 'go left 10 steps, now go north 3 steps and go right 5 steps'; here 'left' is the direction and '10 steps' is the magnitude of the vector. The directions for the treasure map thus contains 3 vectors. Vectors can have any dimension, but we usually work with dimensions of 2 to 4. If a vector has 2 dimensions it represents a direction on a plane (think of 2D graphs) and when it has 3 dimensions it can represent any direction in a 3D world.

Ex. `v¯=⎜xyz⎟`

Because vectors are specified as directions it is sometimes hard to visualize them as positions. If we want to visualize vectors as positions we can imagine the origin of the direction vector to be (0,0,0) and then point towards a certain direction that specifies the point, making it a position vector (we could also specify a different origin and then say: 'this vector points to that point in space from this origin'). The position vector (3,5) would then point to (3,5) on the graph with an origin of (0,0). Using vectors we can thus describe directions and positions in 2D and 3D space.

#### Vector operations

1. Scalar vector operations
   A scalar is a single digit. When adding/subtracting/multiplying or dividing a vector with a scalar we simply add/subtract/multiply or divide each element of the vector by the scalar. For addition it would look like this:
   `[1,2,3] + x = [1+x, 2+x, 3+x]`

2. Vector negation
   Negating a vector results in a vector in the reversed direction. A vector pointing north-east would point south-west after negation. To negate a vector we add a minus-sign to each component (you can also represent it as a scalar-vector multiplication with a scalar value of -1)
   `- v¯= -1 * ⎜x, y, z⎟ = ⎜-x, -y, -z⎟`

3. Addition and subtraction
   Addition of two vectors is defined as component-wise addition, that is each component of one vector is added to the same component of the other vector like so:

   ![img](./assets/vectors_addition.png)

   Subtracting two vectors from each other results in a vector that's the difference of the positions both vectors are pointing at. This proves useful in certain cases where we need to retrieve a vector that's the difference between two points.

   ![img](./assets/vectors_subtraction.png)

4. Length
   To retrieve the length/magnitude of a vector we use the `Pythagoras theorem`. A vector forms a triangle when you visualize its individual x and y component as two sides of a triangle:

   ![img](./assets/vectors_len.png)

5. Vector-vector multiplication
   In computer graphics, dot product and cross product of vectors are fundamental operations used for various tasks like lighting, shading, geometry calculations, and transformations.

   - Dot product
     The dot product of two vectors, A = (Ax, Ay, Az), B = (Bx, By, Bz) is defined as,

     `A⋅B = Ax * Bx + Ay * By + Az * Bz`

     Properties:

     - The result is a scalar.
     - Measures how aligned two vectors are.
     - Useful for finding angles between vectors:
     - cos 𝜃 = 𝐴 ⋅ 𝐵 / ∣A∣∣B∣, where ∣A∣ is the magnitude of A. Calculated as, sqroot(Ax^2 + Ay^2 + Az^2).

     The dot product of two vectors is equal to the scalar product of their lengths times the cosine of the angle between them. If this sounds confusing take a look at its formula:
     ` v¯⋅k¯= |v¯|⋅|k¯|⋅ cosθ`, Where the angle between them is represented as theta (θ ). Why is this interesting? Well, imagine if v¯ and k¯ are unit vectors then their length would be equal to 1. This would effectively reduce the formula to: `v̂ ⋅k̂ = 1 ⋅ 1 ⋅ cosθ = cosθ`

   - Cross product
     The cross product of two vectors **𝐴 = (𝐴ₓ, 𝐴ᵧ, 𝐴𝓏)** and **𝐵 = (𝐵ₓ, 𝐵ᵧ, 𝐵𝓏)** is defined as:
     
     `𝐴 × 𝐵 = (𝐴ᵧ𝐵𝓏 - 𝐴𝓏𝐵ᵧ, 𝐴𝓏𝐵ₓ - 𝐴ₓ𝐵𝓏, 𝐴ₓ𝐵ᵧ - 𝐴ᵧ𝐵ₓ)`

     Properties:

     1. The result is a **vector** perpendicular to both **𝐴** and **𝐵**.
     2. The direction follows the **right-hand rule**.
     3. The magnitude of the result is given by:

     `|𝐴 × 𝐵| = |𝐴| |𝐵| sin𝜃`

     where **𝜃** is the angle between **𝐴** and **𝐵**.

     Applications in Graphics:

     1. **Surface Normals**: Calculating a normal vector for a triangle or polygon surface.
     2. **Orientation**: Finding a perpendicular direction for constructing coordinate systems.
     3. **Torque and Rotation**: Used in physics simulations for rotational calculations.

## Coordinate Systems

### The global picture

### Local space

### World space

### View space

### Clip space

### Orthographic projection

### Perspective projection
