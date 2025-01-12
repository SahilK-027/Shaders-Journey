uniform sampler2D uTexture;

varying vec2 vUv;

void main() {
    vec2 uvs = vUv * 6.0;
    // in texture co-ordinates (0,0) is bottom left and (1,1) is top right
    // So past 1 in any direction what does that even mean to GPU?
    // Luckily openGL has answer for that
    // When you create a texture you also have to decide the addressing mode
    // Basically what ae the rules what are behaviors when you go outside [0, 1]
    // There are three common addressing modes:
    // ClampToEdge
    // Repeat
    // MirroredRepeat
    vec2 TextureUV = vec2(uvs.x, uvs.y);
    vec4 texture = texture2D(uTexture, TextureUV);
    gl_FragColor = texture;
}
