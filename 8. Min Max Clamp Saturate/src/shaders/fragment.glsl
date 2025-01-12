varying vec2 vUv;

void main() {
    // min(a,b)
    // Min returns minimum of two values

    // max(a,b)
    // max returns maximum of two values

    // clamp(a, minRange, maxRange)
    // Clamp, clamps value of a in range [minRange, maxRange]
    // if(a < minRange) return minRange;
    // if(a > maxRange) return maxRange;
    // return a

    // saturate
    // it's not a builtin function, but used a lot
    // sat(a) -> clams a between [0,1]
    gl_FragColor = vec4(vec3(1.0), 1.0);
}