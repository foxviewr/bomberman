#!/bin/sh

# Stop containers using port 8087 (but do not remove them)
for cid in $(docker ps --format '{{.ID}} {{.Ports}}' | awk '/0.0.0.0:8087->/ {print $1}'); do
  echo "Stopping container $cid using port 8087..."
  docker stop $cid
  # Do NOT remove
  done

# Stop any old bomberman containers (by name, but do not remove)
for cid in $(docker ps -a --filter "name=bomberman" --format '{{.ID}}'); do
  echo "Stopping bomberman container $cid..."
  docker stop $cid 2>/dev/null
  # Do NOT remove
  done

echo "All relevant containers stopped (but not removed)." 