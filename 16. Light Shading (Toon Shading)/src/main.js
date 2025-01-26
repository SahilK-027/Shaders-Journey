import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
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
    this.initGround();
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
    this.scene.backgroundBlurriness = 1.0;
  }

  initGeometry() {
    this.materialParams = {};

    const cameraWorldPosition = new THREE.Vector3();
    this.camera.getWorldPosition(cameraWorldPosition);

    // Create the custom shader material
    this.material = new THREE.ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uTime: { value: 0.0 },
        uEnvironmentMap: { value: this.environment },
        uCameraPosition: { value: cameraWorldPosition },

        uLightColor: {
          value: new THREE.Color("#fff9eb"),
        },
        uLightIntensity: { value: 0.7 },
        uLightPosition: { value: new THREE.Vector3(1.0, 1.0, 1.0) },
        uSpecularPower: { value: 50.0 },
        uRimLightColor: {
          value: new THREE.Color("#fff9eb"),
        },
        uRimLightPower: { value: 10.0 },
        uEnvironmentReflectionIntensity: { value: 0.01 },
      },
    });

    new GLTFLoader().load("/whitebeard.glb", (gltf) => {
      this.model = gltf.scene;

      this.model.traverse((child) => {
        if (child.isMesh) {
          const texture = child.material.map;

          child.material = this.material.clone();
          child.material.uniforms.uModelTexture = { value: texture };

          child.castShadow = true;
        }
      });

      this.scene.add(this.model);
      this.model.position.set(0, -1.7, 0);
    });
  }

  initGround() {
    this.groundGeometry = new THREE.PlaneGeometry(50, 50);
    this.groundMaterial = new THREE.ShadowMaterial({ opacity: 0.4 });

    this.ground = new THREE.Mesh(this.groundGeometry, this.groundMaterial);
    this.ground.rotation.x = -Math.PI / 2;
    this.ground.position.y = -1.7;

    this.ground.receiveShadow = true;
    this.scene.add(this.ground);

    const light = new THREE.DirectionalLight(0xfafafa, 1.0);
    light.position.set(5, 10, 5);
    light.castShadow = true;

    light.shadow.mapSize.width = 1024;
    light.shadow.mapSize.height = 1024;
    light.shadow.camera.near = 0.5;
    light.shadow.camera.far = 50;

    this.scene.add(light);
  }

  initCamera() {
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

    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;

    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  }

  initControls() {
    this.controls = new OrbitControls(this.camera, this.canvas);
    this.controls.enableDamping = true;
    this.controls.minPolarAngle = Math.PI / 6;
    this.controls.maxPolarAngle = Math.PI / 2;
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
    if (this.model) {
      this.model.rotation.y += 0.0025;
    }

    this.controls.update();

    this.renderer.render(this.scene, this.camera);

    window.requestAnimationFrame(() => this.animate());
  }

  startAnimationLoop() {
    this.animate();
  }
}

new ShaderRenderer();
