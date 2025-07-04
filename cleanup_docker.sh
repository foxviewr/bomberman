#!/bin/sh

# Find and stop containers using port 8087
for cid in $(docker ps --format '{{.ID}} {{.Ports}}' | awk '/0.0.0.0:8087->/ {print $1}'); do
  echo "Stopping container $cid using port 8087..."
  docker stop $cid
  docker rm $cid
done

# Remove any old bomberman containers (if any)
for cid in $(docker ps -a --filter "name=bomberman" --format '{{.ID}}'); do
  echo "Removing old bomberman container $cid..."
  docker rm $cid
done

# Optionally, remove old bomberman images (uncomment if needed)
# for img in $(docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | awk '/bomberman/ {print $2}'); do
#   echo "Removing old bomberman image $img..."
#   docker rmi $img
# done

echo "Cleanup complete. Now rebuild and re-apply Terraform." 