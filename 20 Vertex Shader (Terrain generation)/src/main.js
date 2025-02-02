import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import vertexShader from "./shaders/vertex.glsl";
import fragmentShader from "./shaders/fragment.glsl";
import "./style.css";

class ShaderRenderer {
  constructor() {
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

    this.initRenderer();
    this.initEnvironment();
    this.initCamera();
    this.initGeometry();
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
    // this.scene.background = this.environment;
    // this.scene.backgroundBlurriness = 1.0;
  }

  initGeometry() {
    this.materialParams = {};

    // Create the custom shader material
    this.material = new THREE.ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uTime: { value: 0.0 },
      },
      side: THREE.DoubleSide,
      wireframe: true,
    });

    this.geometry = new THREE.PlaneGeometry(4, 4, 128, 128);
    this.mesh = new THREE.Mesh(this.geometry, this.material);
    this.mesh.rotation.x = Math.PI / 2;
    this.scene.add(this.mesh);
  }

  initCamera() {
    this.camera = new THREE.PerspectiveCamera(
      75,
      this.sizes.width / this.sizes.height,
      0.1,
      100
    );
    this.camera.position.set(0.6, 0.45, 1.05);
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
    this.mesh.rotation.z += 0.001;
    this.material.uniforms.uTime.value = this.Clock.getElapsedTime();

    this.controls.update();

    this.renderer.render(this.scene, this.camera);

    window.requestAnimationFrame(() => this.animate());
  }

  startAnimationLoop() {
    this.animate();
  }
}

new ShaderRenderer();
