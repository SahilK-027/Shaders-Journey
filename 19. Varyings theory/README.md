# Varyings in Way More Depth

By far it's very clear that, in shaders, "varying" refers to variables that are calculated in the vertex shader and then passed on to the fragment shader.

But what are they exactly and how do they work? Let’s dive deep into the concept of varyings and understand their inner workings, and limitations:

## Understanding through code:

### In fragment shader

Let’s say we want to blend two colors (red and blue) based on the position of each pixel. Here’s what the fragment shader might look like:

```glsl
// Input varying from vertex shader
varying vec3 vPosition;

void main() {
    // Remap position from [-0.5, 0.5] to [0.0, 1.0]
    float mixStrength = remap(vPosition.x, -0.5, 0.5, 0.0, 1.0);

    // Apply a non-linear curve for a smoother transition
    mixStrength = pow(mixStrength, 2.0);

    // Define colors to blend
    vec3 red = vec3(1.0, 0.0, 0.0);
    vec3 blue = vec3(0.0, 0.0, 1.0);

    // Blend colors based on mixStrength
    vec3 mixColor = mix(red, blue, mixStrength);

    // Output the final color
    gl_FragColor = vec4(mixColor, 1.0);
}
```

The result would show a smooth gradient transitioning between red and blue based on each pixel's horizontal position.

![img](../assets/pow-blending-fragment.png)

### In vertex shader

Now, let’s attempt the same blending in the vertex shader and pass the blended color to the fragment shader as a varying:

```glsl
// Output varying to fragment shader
varying vec3 vMixColor;

void main() {

    // .. All the same steps we did in fragment

    // Blend colors based on mixStrength
    vec3 mixColor = mix(red, blue, mixStrength);

    // Pass as varying
    vMixColor = mixColor;
}
```

In this case the output will look noticeably different:

![img](../assets/pow-blending-vertex.png)

## But why? 🤔

For this let's understand how veryings work?

When a triangle is rasterized (broken into fragments or pixels), the values of varying variables are interpolated between the three vertices of the triangle. The interpolation is linear, but in perspective-correct rendering, this is adjusted to account for the depth of each vertex.

In the example above:

- The vertex shader runs once for each vertex.

- The values of vMixColor at each vertex are linearly interpolated for every pixel within the triangle.

And since there are only 4 vertices, you can figure out what values are generated at those two vertices, top-left mixStrength = 0, and top-right mixStrength = 1, and at every pixel in the middle the varying was linearly interpolated in between. Meaning you smoothly went from 0 to 1.

The fragment shader on the other hand ran for millions of pixels.

## Improving Quality by Increasing Detail

So, if we increase details in plane we will get different result as varying will be interpolated across more pixels.

The accuracy of vertex shader computations can be improved by increasing the number of vertices in the model (i.e., increasing the mesh density). For example, adding more subdivisions to the plane will create more vertices, allowing the interpolation to better approximate the desired effect:

![img](../assets/pow-blending-vertex-improved.png)

## Data Types and Limits

Varyings are subject to hardware limits, often capped at a maximum number of floats (e.g., 32 floats in older hardware). Exceeding this limit will result in compilation errors.

## Performance Considerations

- For what to use Vertex Shader: Suitable for calculations that don’t require pixel-level precision, as the vertex shader runs only once per vertex.

- For what to use Fragment Shader: Necessary for effects requiring per-pixel accuracy, though more computationally expensive due to the higher number of invocations.

## Common Use Cases of Varyings

- Texture Mapping: Passing UV coordinates from vertex to fragment shader. ✅ [Lesson 1](/1.%20UV/)

- Lighting: Passing interpolated normals or light intensities for per-pixel lighting. ✅ [Lesson 13](</13.%20Light%20Shading%20(Ambient,%20Directional,%20Point,%20Specular)/>)

- Fog or Gradients: Calculating fog intensity or gradient transitions based on depth or position.

## Conclusion

The point here is you must very careful about what you compute in vertex shader and what in fragment shader.

Some calculations, like color blending, may need to be performed in the fragment shader to ensure precision, while others, like position transformations, can be efficiently computed in the vertex shader.

The choice of where to compute a value ultimately depends on the effect you’re trying to achieve and the level of detail in your model. Understanding the behavior of varyings is key to writing shaders that are both efficient and visually pleasing.
