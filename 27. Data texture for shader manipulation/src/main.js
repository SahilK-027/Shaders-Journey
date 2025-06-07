import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import GUI from "lil-gui";
import vertexShader from "./shaders/vertex.glsl";
import fragmentShader from "./shaders/fragment.glsl";
import dataTexture from "./textures/1.png";
import waterTexture from "./textures/water.png";
import grassTexture from "./textures/grass.png";
import landTexture from "./textures/land.png";
import "./style.css";

class ShaderRenderer {
  constructor() {
    // Debug GUI
    this.gui = new GUI();

    // Canvas
    this.canvas = document.querySelector("canvas.webgl");

    // Scene
    this.scene = new THREE.Scene();

    // Sizes
    this.sizes = {
      width: window.innerWidth,
      height: window.innerHeight,
    };

    this.initGeometry();
    this.initCamera();
    this.initRenderer();
    this.initControls();
    this.initEventListeners();
    this.startAnimationLoop();
  }

  initGeometry() {
    const loader = new THREE.TextureLoader();

    // Load data texture
    this.texture = loader.load(dataTexture);
    this.texture.wrapS = THREE.RepeatWrapping;
    this.texture.wrapT = THREE.RepeatWrapping;
    this.texture.magFilter = THREE.NearestFilter;
    this.texture.minFilter = THREE.NearestFilter;

    // Load terrain textures
    this.waterTexture = loader.load(waterTexture);
    this.grassTexture = loader.load(grassTexture);
    this.landTexture = loader.load(landTexture);

    // Configure texture wrapping and filtering
    [this.waterTexture, this.grassTexture, this.landTexture].forEach(
      (texture) => {
        texture.wrapS = THREE.RepeatWrapping;
        texture.wrapT = THREE.RepeatWrapping;
        texture.magFilter = THREE.LinearFilter;
        texture.minFilter = THREE.LinearMipMapLinearFilter;
      }
    );

    // Geometry
    this.geometry = new THREE.PlaneGeometry(10, 10, 64, 64);
    this.geometry.rotateX(-Math.PI / 2);

    // Material with uniforms
    this.material = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      side: THREE.DoubleSide,
      uniforms: {
        uTexture: { value: this.texture },
        uWaterTexture: { value: this.waterTexture },
        uGrassTexture: { value: this.grassTexture },
        uLandTexture: { value: this.landTexture },
        uTime: { value: 0 },
        uWaveHeight: { value: 0.3 },
        uWaveSpeed: { value: 1.7 },
        uGroundHeight: { value: 0.7 },
        uGrassHeight: { value: 0.3 },
        uScaleFactor: { value: 30.0 },
        uRandom: { value: Math.max(0.5, Math.random()) },
      },
    });

    // Add GUI controls for uniforms
    const folder = this.gui.addFolder("Uniforms");
    folder
      .add(this.material.uniforms.uWaveHeight, "value", 0, 2, 0.01)
      .name("Wave Height");
    folder
      .add(this.material.uniforms.uWaveSpeed, "value", 0, 5, 0.01)
      .name("Wave Speed");
    folder
      .add(this.material.uniforms.uGroundHeight, "value", 0, 5, 0.01)
      .name("Ground Height");
    folder
      .add(this.material.uniforms.uGrassHeight, "value", 0, 5, 0.01)
      .name("Grass Height");
    folder
      .add(this.material.uniforms.uScaleFactor, "value", 0, 100, 0.01)
      .name("Scale Factor");
    folder.open();

    // Mesh
    this.mesh = new THREE.Mesh(this.geometry, this.material);
    this.scene.add(this.mesh);
  }

  initCamera() {
    this.camera = new THREE.PerspectiveCamera(
      75,
      this.sizes.width / this.sizes.height,
      0.1,
      100
    );
    this.camera.position.set(6.7, 4.0, 6.3);
    this.scene.add(this.camera);
  }

  initRenderer() {
    this.renderer = new THREE.WebGLRenderer({
      canvas: this.canvas,
    });
    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  }

  initControls() {
    this.controls = new OrbitControls(this.camera, this.canvas);
    this.controls.enableDamping = true;
  }

  initEventListeners() {
    window.addEventListener("resize", () => this.handleResize());
  }

  handleResize() {
    this.sizes.width = window.innerWidth;
    this.sizes.height = window.innerHeight;

    this.camera.aspect = this.sizes.width / this.sizes.height;
    this.camera.updateProjectionMatrix();

    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  }

  animate() {
    this.material.uniforms.uTime.value +=
      0.01 * this.material.uniforms.uWaveSpeed.value;

    this.controls.update();
    this.renderer.render(this.scene, this.camera);
    window.requestAnimationFrame(() => this.animate());
  }

  startAnimationLoop() {
    this.animate();
  }
}

// Initialize the renderer when the script loads
const shaderRenderer = new ShaderRenderer();

export default shaderRenderer;
