#!/bin/bash

# Test script for POST /inference endpoint
# Usage: ./test_inference.sh [path_to_image]

if [ -z "$1" ]; then
    echo "Usage: ./test_inference.sh <path_to_image>"
    echo ""
    echo "Example:"
    echo "  ./test_inference.sh data/damage/-93.528502_30.987438.jpeg"
    echo "  ./test_inference.sh data/no_damage/-93.528502_30.987438.jpeg"
    exit 1
fi

IMAGE_PATH=$1

if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: Image file '$IMAGE_PATH' not found"
    exit 1
fi

echo "Testing POST /inference with: $IMAGE_PATH"
echo ""

RESPONSE=$(curl -s -X POST http://localhost:5000/inference \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"$IMAGE_PATH")

echo "Response:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"

echo ""
echo "Prediction: $(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['prediction'])" 2>/dev/null || echo 'N/A')"

