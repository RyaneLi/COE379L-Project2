#!/bin/bash

# Get the project root directory (one level up from grader/)
PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)

# Mount the data directory from project root
# Use host network so grader can access inference server at localhost:5000
docker run -it --rm \
  -v "$PROJECT_ROOT/data:/data" \
  -v "$(pwd)/grader.py:/grader.py" \
  -v "$(pwd)/project3-results:/results" \
  --network host \
  --entrypoint=python \
  jstubbs/coe379l /grader.py