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
    this.initCamera();
    this.initGeometry();
    this.initRenderer();
    this.initControls();
    this.initEventListeners();
    this.startAnimationLoop();
  }

  initEnvironment() {
    const cubeTextureLoader = new THREE.CubeTextureLoader();
    this.environment = cubeTextureLoader.load([
      "/map3/px.png",
      "/map3/nx.png",
      "/map3/py.png",
      "/map3/ny.png",
      "/map3/pz.png",
      "/map3/nz.png",
    ]);
    this.scene.background = this.environment;
  }

  initGeometry() {
    this.materialParams = {};

    const cameraWorldPosition = new THREE.Vector3();
    this.camera.getWorldPosition(cameraWorldPosition);

    this.material = new THREE.ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uTime: { value: 0.0 },
        uEnvironmentMap: { value: this.environment },
        uCameraPosition: { value: cameraWorldPosition },
      },
    });

    new GLTFLoader().load("/monkey.glb", (gltf) => {
      this.model = gltf.scene;
      this.model.traverse((child) => {
        if (child.isMesh) {
          child.material = this.material;
        }
      });
      this.scene.add(this.model);

      this.model.position.set(1.25, -0.5, 0);
    });

    const torusKnotGeometry = new THREE.TorusKnotGeometry(0.5, 0.2, 100, 16);
    const torusKnotMaterial = this.material;
    this.torusKnot = new THREE.Mesh(torusKnotGeometry, torusKnotMaterial);

    this.torusKnot.position.set(-1.25, 0, 0);
    this.scene.add(this.torusKnot);
  }

  initCamera() {
    // Base camera
    this.camera = new THREE.PerspectiveCamera(
      75,
      this.sizes.width / this.sizes.height,
      0.1,
      100
    );
    this.camera.position.set(0.05, 1.0, 3.5);
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
    // this.material.uniforms.uTime.value = this.Clock.getElapsedTime();

    if (this.model) {
      this.model.rotation.y += 0.0025;
      this.torusKnot.rotation.z += 0.0025;
      this.torusKnot.rotation.y += 0.0025;
      this.torusKnot.rotation.x += 0.0025;
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
