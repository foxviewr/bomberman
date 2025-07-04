terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "bomberman" {
  name         = "bomberman:latest"
  build {
    context    = "${path.module}/.."
    dockerfile = "${path.module}/../Dockerfile"
  }
}

resource "docker_container" "bomberman" {
  name  = "bomberman"
  image = docker_image.bomberman.image_id
  ports {
    internal = 3000
    external = 8087
  }
  restart = "unless-stopped"
}

resource "docker_image" "bomberman_dev" {
  name = "bomberman:dev"
  build {
    context    = "${path.module}/.."
    dockerfile = "${path.module}/../Dockerfile.dev"
  }
}

resource "docker_container" "bomberman_dev" {
  name  = "bomberman-dev"
  image = docker_image.bomberman_dev.image_id
  ports {
    internal = 3000
    external = 8093
  }
  restart = "unless-stopped"
} 