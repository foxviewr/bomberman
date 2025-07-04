#!/bin/sh

# Find and stop containers using port 8087
for cid in $(docker ps --format '{{.ID}} {{.Ports}}' | awk '/0.0.0.0:8087->/ {print $1}'); do
  echo "Stopping container $cid using port 8087..."
  docker stop $cid
  docker rm $cid
done

# Remove any old bomberman containers (if any)
for cid in $(docker ps -a --filter "name=bomberman" --format '{{.ID}}'); do
  echo "Stopping and removing old bomberman container $cid..."
  docker stop $cid 2>/dev/null
  docker rm $cid
done

# Remove all bomberman-related images (including dev and dangling)
for img in $(docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | awk '/bomberman/ {print $2}'); do
  echo "Removing bomberman image $img..."
  docker rmi $img
done

# Remove dangling images (optional, but helps keep things clean)
for img in $(docker images -f "dangling=true" -q); do
  echo "Removing dangling image $img..."
  docker rmi $img
done

echo "Cleanup complete. Now rebuild and re-apply Terraform." 