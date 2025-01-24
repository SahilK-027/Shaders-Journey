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

    this.initGeometry();
    this.initCamera();
    this.initRenderer();
    this.initControls();
    this.initEventListeners();
    this.initGUI();
    this.initLightHelpers();
    this.startAnimationLoop();
  }

  initGeometry() {
    // Shader material for Suzanne
    this.materialParams = {};
    this.materialParams.uBaseColor = "#ffffff";
    this.materialParams.uAmbientLightColor = "#363030";
    this.materialParams.uDirectionalLightColor = new THREE.Color(0.1, 0.0, 1.0);
    this.materialParams.uDirectionalLightPosition = new THREE.Vector3(
      0.0,
      0.5,
      2.5
    );
    this.materialParams.uPointLightColor = new THREE.Color(0.8, 0.0, 0.25);
    this.materialParams.uPointLightPosition = new THREE.Vector3(0.0, 2.1, 0.0);
    this.materialParams.uPointLightIntensity = 1.0;
    this.materialParams.uPointLightSpecularPower = 20.0;

    this.material = new THREE.ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uBaseColor: new THREE.Uniform(
          new THREE.Color(this.materialParams.uBaseColor)
        ),
        uAmbientLightColor: new THREE.Uniform(
          new THREE.Color(this.materialParams.uAmbientLightColor)
        ),
        uAmbientLightIntensity: { value: 0.1 },
        uDirectionalLightColor: new THREE.Uniform(
          this.materialParams.uDirectionalLightColor
        ),
        uDirectionalLightIntensity: { value: 1.0 },
        uDirectionalLightPosition: {
          value: this.materialParams.uDirectionalLightPosition,
        },
        uDirectionalLightSpecularPower: {
          value: 20.0,
        },
        uPointLightColor: new THREE.Uniform(
          this.materialParams.uPointLightColor
        ),
        uPointLightPosition: {
          value: this.materialParams.uPointLightPosition,
        },
        uPointLightIntensity: {
          value: this.materialParams.uPointLightIntensity,
        },
        uPointLightSpecularPower: {
          value: this.materialParams.uPointLightSpecularPower,
        },
        uPointLightDecay: { value: 0.4 },
        uTime: { value: 0.0 },
      },
    });

    // Load Suzanne model
    new GLTFLoader().load("/suzanne.glb", (gltf) => {
      this.suzanne = gltf.scene;
      this.suzanne.traverse((child) => {
        if (child.isMesh) {
          child.material = this.material;
        }
      });

      this.scene.add(this.suzanne);
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
    this.camera.position.set(2.4, 2.4, 1.7);
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

  initLightHelpers() {
    this.directionalLightHelper = new THREE.Mesh(
      new THREE.PlaneGeometry(),
      new THREE.MeshBasicMaterial({
        color: this.materialParams.uDirectionalLightColor,
        side: THREE.DoubleSide,
        wireframe: true,
      })
    );
    this.directionalLightHelper.position.set(
      this.materialParams.uDirectionalLightPosition.x,
      this.materialParams.uDirectionalLightPosition.y,
      this.materialParams.uDirectionalLightPosition.z
    );

    this.pointLightHelper = new THREE.Mesh(
      new THREE.SphereGeometry(0.08, 8, 8),
      new THREE.MeshBasicMaterial({
        color: this.materialParams.uPointLightColor,
        wireframe: true,
      })
    );
    this.pointLightHelper.position.set(
      this.materialParams.uPointLightPosition.x,
      this.materialParams.uPointLightPosition.y,
      this.materialParams.uPointLightPosition.z
    );

    this.scene.add(this.directionalLightHelper);
    this.scene.add(this.pointLightHelper);
  }

  initGUI() {
    this.gui.addColor(this.materialParams, "uBaseColor").onChange(() => {
      this.material.uniforms.uBaseColor.value.set(
        this.materialParams.uBaseColor
      );
    });

    // Create a folder for ambient light
    this.ambientLightFolder = this.gui.addFolder("Ambient Light");

    this.ambientLightFolder
      .addColor(this.materialParams, "uAmbientLightColor")
      .onChange(() => {
        this.material.uniforms.uAmbientLightColor.value.set(
          this.materialParams.uAmbientLightColor
        );
      });
    this.ambientLightFolder
      .add(this.material.uniforms.uAmbientLightIntensity, "value")
      .name("uAmbientLightIntensity")
      .min(0.0)
      .max(1.0)
      .step(0.01);

    // Create a folder for directional light
    this.directionalLightFolder = this.gui.addFolder("Directional Light");

    this.directionalLightFolder
      .addColor(this.materialParams, "uDirectionalLightColor")
      .onChange(() => {
        this.material.uniforms.uDirectionalLightColor.value.set(
          this.materialParams.uDirectionalLightColor
        );
        this.directionalLightHelper.material.color.set(
          this.materialParams.uDirectionalLightColor
        );
      });

    this.directionalLightFolder
      .add(this.material.uniforms.uDirectionalLightIntensity, "value")
      .name("uDirectionalLightIntensity")
      .min(0.0)
      .max(5.0)
      .step(0.01);

    this.directionalLightFolder
      .add(this.materialParams.uDirectionalLightPosition, "x")
      .name("positionX")
      .min(-10)
      .max(10)
      .step(0.001)
      .onChange(() => {
        this.directionalLightHelper.position.x =
          this.materialParams.uDirectionalLightPosition.x;
        this.material.uniforms.uDirectionalLightPosition.value.copy(
          this.materialParams.uDirectionalLightPosition
        );
      });

    this.directionalLightFolder
      .add(this.materialParams.uDirectionalLightPosition, "y")
      .name("positionY")
      .min(-10)
      .max(10)
      .step(0.001)
      .onChange(() => {
        this.directionalLightHelper.position.y =
          this.materialParams.uDirectionalLightPosition.y;
        this.material.uniforms.uDirectionalLightPosition.value.copy(
          this.materialParams.uDirectionalLightPosition
        );
      });

    this.directionalLightFolder
      .add(this.materialParams.uDirectionalLightPosition, "z")
      .name("positionZ")
      .min(-10)
      .max(10)
      .step(0.001)
      .onChange(() => {
        this.directionalLightHelper.position.z =
          this.materialParams.uDirectionalLightPosition.z;
        this.material.uniforms.uDirectionalLightPosition.value.copy(
          this.materialParams.uDirectionalLightPosition
        );
      });

    this.directionalLightFolder
      .add(this.material.uniforms.uDirectionalLightSpecularPower, "value")
      .name("uDirectionalLightSpecularPower")
      .min(1.0)
      .max(500.0)
      .step(1);

    // Create a folder for point light
    this.pointLightFolder = this.gui.addFolder("Point Light");

    this.pointLightFolder
      .addColor(this.materialParams, "uPointLightColor")
      .onChange(() => {
        this.material.uniforms.uPointLightColor.value.set(
          this.materialParams.uPointLightColor
        );
        this.pointLightHelper.material.color.set(
          this.materialParams.uPointLightColor
        );
      });

    this.pointLightFolder
      .add(this.material.uniforms.uPointLightIntensity, "value")
      .name("uPointLightIntensity")
      .min(0.0)
      .max(5.0)
      .step(0.01);

    this.pointLightFolder
      .add(this.materialParams.uPointLightPosition, "x")
      .name("positionX")
      .min(-10)
      .max(10)
      .step(0.001)
      .onChange(() => {
        this.pointLightHelper.position.x =
          this.materialParams.uPointLightPosition.x;
        this.material.uniforms.uPointLightPosition.value.copy(
          this.materialParams.uPointLightPosition
        );
      });

    this.pointLightFolder
      .add(this.materialParams.uPointLightPosition, "y")
      .name("positionY")
      .min(-10)
      .max(10)
      .step(0.001)
      .onChange(() => {
        this.pointLightHelper.position.y =
          this.materialParams.uPointLightPosition.y;
        this.material.uniforms.uPointLightPosition.value.copy(
          this.materialParams.uPointLightPosition
        );
      });

    this.pointLightFolder
      .add(this.materialParams.uPointLightPosition, "z")
      .name("positionZ")
      .min(-10)
      .max(10)
      .step(0.001)
      .onChange(() => {
        this.pointLightHelper.position.z =
          this.materialParams.uPointLightPosition.z;
        this.material.uniforms.uPointLightPosition.value.copy(
          this.materialParams.uPointLightPosition
        );
      });

    this.pointLightFolder
      .add(this.material.uniforms.uPointLightSpecularPower, "value")
      .name("uPointLightSpecularPower")
      .min(1.0)
      .max(500.0)
      .step(1);

    this.pointLightFolder
      .add(this.material.uniforms.uPointLightDecay, "value")
      .name("uPointLightDecay")
      .min(0.1)
      .max(2.0)
      .step(0.001);
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

    if (this.suzanne) {
      this.suzanne.rotation.y += 0.0025;
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
