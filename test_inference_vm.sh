#!/bin/bash

# Test script for inference endpoint on VM
# Usage: ./test_inference_vm.sh

echo "Testing inference server..."
echo ""

# Check if server is running
if ! curl -s http://localhost:5000/summary > /dev/null; then
    echo "Error: Server is not running or not accessible"
    echo "Start it with: docker-compose up -d"
    exit 1
fi

# Find first available image in damage directory
DAMAGE_DIR="data/damage"
NO_DAMAGE_DIR="data/no_damage"

DAMAGE_IMG=$(find "$DAMAGE_DIR" -name "*.jpeg" -o -name "*.jpg" 2>/dev/null | head -1)
NO_DAMAGE_IMG=$(find "$NO_DAMAGE_DIR" -name "*.jpeg" -o -name "*.jpg" 2>/dev/null | head -1)

if [ -z "$DAMAGE_IMG" ] && [ -z "$NO_DAMAGE_IMG" ]; then
    echo "Error: No test images found in data/damage or data/no_damage"
    echo "Please run: ./get_data.sh"
    exit 1
fi

# Test with damaged image if available
if [ -n "$DAMAGE_IMG" ]; then
    echo "Testing with damaged image: $DAMAGE_IMG"
    RESPONSE=$(curl -s -X POST http://localhost:5000/inference \
      -H "Content-Type: application/octet-stream" \
      --data-binary @"$DAMAGE_IMG")
    echo "Response:"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
    echo ""
fi

# Test with non-damaged image if available
if [ -n "$NO_DAMAGE_IMG" ]; then
    echo "Testing with non-damaged image: $NO_DAMAGE_IMG"
    RESPONSE=$(curl -s -X POST http://localhost:5000/inference \
      -H "Content-Type: application/octet-stream" \
      --data-binary @"$NO_DAMAGE_IMG")
    echo "Response:"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
    echo ""
fi

echo "Done!"

