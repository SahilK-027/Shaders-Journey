import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import GUI from "lil-gui";
import vertexShader from "./shaders/vertex.glsl";
import fragmentShader from "./shaders/fragment.glsl";
import "./style.css";

class ShaderRenderer {
  constructor() {
    // Debug
    this.gui = new GUI();
    this.gui.close();
    this.debugObject = {};

    // Color
    this.debugObject.c1 = "#ff0066";
    this.debugObject.c2 = "#121316";

    this.clock = new THREE.Clock();

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
    this.initGUI();
    this.startAnimationLoop();
  }

  initGeometry() {
    // Geometry
    this.geometry = new THREE.PlaneGeometry(2, 2, 128, 128);

    // Material
    this.material = new THREE.ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uTime: { value: 0 },

        uTerrainElevation: { value: 0.01 },

        uC1: { value: new THREE.Color(this.debugObject.c1) },
        uC2: { value: new THREE.Color(this.debugObject.c2) },
      },
    });

    // Mesh
    this.mesh = new THREE.Mesh(this.geometry, this.material);
    this.scene.add(this.mesh);
  }

  initCamera() {
    // Base camera
    this.camera = new THREE.PerspectiveCamera(
      75,
      this.sizes.width / this.sizes.height,
      0.1,
      100
    );
    this.camera.position.set(0, 0, 1.0);
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

  initGUI() {
    this.gui
      .add(this.material.uniforms.uTerrainElevation, "value")
      .name("uTerrainElevation")
      .min(0)
      .max(0.05)
      .step(0.01);

    this.gui
      .addColor(this.debugObject, "c1")
      .name("c1")
      .onChange(() => {
        this.material.uniforms.uC1.value.set(this.debugObject.c1);
      });

    this.gui
      .addColor(this.debugObject, "c2")
      .name("c2")
      .onChange(() => {
        this.material.uniforms.uC2.value.set(this.debugObject.c2);
      });
  }

  handleResize() {
    // Update sizes
    this.sizes.width = window.innerWidth;
    this.sizes.height = window.innerHeight;

    // Update camera
    this.camera.aspect = this.sizes.width / this.sizes.height;
    this.camera.updateProjectionMatrix();

    // Update renderer
    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  }

  animate() {
    this.material.uniforms.uTime.value = this.clock.getElapsedTime();
    // Update controls
    this.controls.update();

    // Render
    this.renderer.render(this.scene, this.camera);

    // Call animate again on the next frame
    window.requestAnimationFrame(() => this.animate());
  }

  startAnimationLoop() {
    this.animate();
  }
}

// Initialize the renderer when the script loads
const shaderRenderer = new ShaderRenderer();
