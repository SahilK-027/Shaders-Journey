uniform float uTime;
uniform vec3 uBaseColor;
uniform vec3 uAmbientLightColor;
uniform float uAmbientLightIntensity;
uniform vec3 uDirectionalLightColor;
uniform float uDirectionalLightIntensity;
uniform vec3 uDirectionalLightPosition;
uniform float uDirectionalLightSpecularPower;
uniform vec3 uPointLightColor;
uniform float uPointLightIntensity;
uniform vec3 uPointLightPosition;
uniform float uPointLightSpecularPower;
uniform float uPointLightDecay;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;

#include ./includes/ambientLight.glsl;
#include ./includes/directionalLight.glsl;
#include ./includes/pointLight.glsl;

void main() {
    vec3 normal = normalize(vNormal);
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    // Base color
    vec3 color = uBaseColor;

    // Light
    vec3 light = vec3(0.0);
    light += ambientLight(uAmbientLightColor, uAmbientLightIntensity);
    light += directionalLight(
            uDirectionalLightColor,
            uDirectionalLightIntensity,
            normal,
            uDirectionalLightPosition,
            viewDirection,
            uDirectionalLightSpecularPower
        );
    light += pointLight(
            uPointLightColor,
            uPointLightIntensity,
            normal,
            uPointLightPosition,
            viewDirection,
            uPointLightSpecularPower,
            vPosition,
            uPointLightDecay
        );

    color *= light;

    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
