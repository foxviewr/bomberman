# Bomberman Game

A simple Bomberman-inspired browser game built with **Node.js**, **VueJS**, **Nuxt.js** and **Docker/Terraform**.

---

## Prerequisites

- **Docker**
- **Terraform** (>= 1.0.0)

### Install Docker
- [Download Docker Desktop](https://www.docker.com/products/docker-desktop/) and follow the installation instructions for your OS.
- After installation, verify Docker is running:
  ```sh
  docker --version
  docker info
  ```

### Install Terraform
- [Download Terraform](https://developer.hashicorp.com/terraform/downloads) and follow the installation instructions for your OS.
- After installation, verify Terraform is installed:
  ```sh
  terraform version
  ```

---

## Project Setup

### 1. Clone the Repository
```sh
git clone git@github.com:foxviewr/bomberman.git
cd bomberman
```

### 2. Build and Run with Docker & Terraform

#### a. Build the Docker Images and Start Containers

You can use the provided script to initialize and apply the Terraform configuration (this will start the Docker containers):
```sh
./start_docker.sh
```
This script will automatically run `terraform init` and `terraform apply` in the `terraform` directory.

Alternatively, you can run the steps manually:

1. **Initialize Terraform:**
   ```sh
   cd terraform
   terraform init
   ```
2. **Apply the Terraform configuration:**
   ```sh
   terraform apply
   ```
   - Approve the plan when prompted.

#### b. Access the Game
- **Production (SSR) mode:** [http://localhost:8087](http://localhost:8087)
- **Development (hot reload) mode:** [http://localhost:8093](http://localhost:8093)

---

## Custom Docker & Terraform Configurations

- **Production (SSR) Container:**
  - Uses `Dockerfile` to build and run the Nuxt SSR server on port 3000 (mapped to 8087 on your host).
- **Development Container:**
  - Uses `Dockerfile.dev` to run `npm run dev` on port 3000 (mapped to 8093 on your host).
- **Terraform** manages both containers and images. See `terraform/main.tf` for details.

---

## Managing Containers

- **Start containers:**
  ```sh
  ./start_docker.sh
  ```
  Initializes and applies the Terraform configuration to start all Docker containers.

- **Stop containers (without removing):**
  ```sh
  ./stop_docker.sh
  ```
  Stops all Bomberman-related containers, but does not remove them or any images.

- **Stop and remove all containers and images:**
  ```sh
  ./cleanup_docker.sh
  ```
  Stops and removes all Bomberman containers and images, including those using port 8087.

---

## Troubleshooting

- If you see the default Nginx page or changes are not reflected, try:
  - Running `./cleanup_docker.sh` to remove old containers.
  - Rebuilding the Docker images with `docker build --no-cache ...`.
  - Forcing Terraform to recreate containers:
    ```sh
    terraform apply -replace="docker_container.bomberman"
    terraform apply -replace="docker_container.bomberman_dev"
    ```
- For browser cache issues, use a hard refresh (`Cmd+Shift+R` or `Ctrl+Shift+R`) or open in incognito mode.

---

## How to Play

- **Move:** Use the arrow keys (↑, ↓, ←, →) to move your character.
- **Drop Bomb:** Press the <kbd>Space</kbd> key to drop a bomb (you can only drop as many bombs as your current power allows).
- **Destroy Walls:** Bombs will destroy breakable (orange) walls in a cross pattern. Unbreakable (gray) walls block explosions.
- **Collect Power-ups:**
  - 💥 (blue/white): Increases your bomb explosion area by 1.
  - 💣 (red/white): Allows you to place one more bomb at the same time.
- **Win:** Destroy all breakable walls to win. Your completion time will be displayed.
- **Lose:** If you are caught in a bomb explosion, you lose the game.
- **Restart:** Use the on-screen button to play again after winning or losing.

Enjoy playing!
