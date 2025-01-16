import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import GUI from "lil-gui";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import vertexShader from "./shaders/vertex.glsl";
import fragmentShader from "./shaders/fragment.glsl";
import "./style.css";

class ShaderRenderer {
  constructor() {
    // Debug
    this.gui = new GUI();
    this.gui.close();

    // Canvas
    this.canvas = document.querySelector("canvas.webgl");

    // Scene
    this.scene = new THREE.Scene();

    // Sizes
    this.sizes = {
      width: window.innerWidth,
      height: window.innerHeight,
    };

    this.Clock = new THREE.Clock();

    this.initEnvironment();
    this.initGeometry();
    this.initCamera();
    this.initRenderer();
    this.initControls();
    this.initEventListeners();
    this.startAnimationLoop();
  }

  initEnvironment() {
    const cubeTextureLoader = new THREE.CubeTextureLoader();
    this.environment = cubeTextureLoader.load([
      "/map/px.png",
      "/map/nx.png",
      "/map/py.png",
      "/map/ny.png",
      "/map/pz.png",
      "/map/nz.png",
    ]);
    this.scene.background = this.environment;
  }

  initGeometry() {
    // Shader material for Suzanne
    this.materialParams = {};

    this.material = new THREE.ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uTime: { value: 0.0 },
      },
    });

    // Load model
    new GLTFLoader().load("/model.glb", (gltf) => {
      this.model = gltf.scene;
      this.model.traverse((child) => {
        if (child.isMesh) {
          child.material = this.material;
        }
      });
      this.model.rotation.x = Math.PI / 2;
      this.scene.add(this.model);
    });
  }

  initCamera() {
    // Base camera
    this.camera = new THREE.PerspectiveCamera(
      75,
      this.sizes.width / this.sizes.height,
      0.1,
      100
    );
    this.camera.position.set(0, 0, 3);
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
    // Update controls
    this.material.uniforms.uTime.value = this.Clock.getElapsedTime();

    if (this.model) {
      this.model.rotation.y += 0.0025;
    }

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
new ShaderRenderer();
