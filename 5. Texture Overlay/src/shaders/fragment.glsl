uniform sampler2D uTexture;
uniform sampler2D uOverlay;

varying vec2 vUv;

void main() {
    vec4 color = texture2D(uTexture, vUv);
    vec4 overlay = texture2D(uOverlay, vUv);
    // This will simply multiply two textures and display output
    gl_FragColor = color * overlay;
    // When bg of overlay is transparent
    // So to display one texture over other we will use alpha channel
    // So we need to mix between texture and overlay
    // gl_FragColor = mix(color, overlay, overlay.w);
}
