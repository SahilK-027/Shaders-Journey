uniform sampler2D uTexture;

varying vec2 vUv;

void main() {
    // Texture co-ordinates are the way of mapping an Image on geometry
    // With bottom-left texture coordinate: (0,0)
    // As you go from left to right in texture co-ordinates it is referred to as U-axis
    // And bottom to up is referred to as V-axis
    // So the texture coordinates are often called uv coordinates
    // vec4 texture = texture2D(uTexture, vUv);
    // gl_FragColor = texture;

    // Gray scale
    // gl_FragColor = vec4(texture.x);

    // Wanna see only r-channel?
    // gl_FragColor = vec4(texture.x, 0.0, 0.0, 1.0);

    // How to flip the image?
    // Simply to flip the image we wanna make all y negatives
    // vec2 flippedTextureUV = vec2(vUv.x, 1.0 - vUv.y);
    // vec4 flippedTexture = texture2D(uTexture, flippedTextureUV);
    // gl_FragColor = flippedTexture;

    // Add tint with multiplicative blending?
    // When you multiply two vectors then multiplication is component wise
    // Ex v1 = (1.0, 0.2, 0.5, 1.0), v2 = (0.6, 0.4, 0.3, 1.0)
    // Then  result v1 * v2 = (0.6, 0.08, 0.15, 1.0)
    vec2 TextureUV = vec2(vUv.x, vUv.y);
    vec4 texture = texture2D(uTexture, TextureUV);
    vec4 purpleTint = vec4(0.5, 0.3, 0.9, 1.0);
    gl_FragColor = texture * purpleTint;
}
