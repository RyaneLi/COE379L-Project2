#!/bin/bash

# Script to download grader code from the course repository
# Usage: ./get_grader.sh

echo "Downloading grader code from course repository..."

# Check if grader directory already exists and has content
if [ -d "grader" ] && [ "$(ls -A grader 2>/dev/null)" ]; then
    echo "Grader directory already exists."
    read -p "Do you want to overwrite it? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    rm -rf grader
fi

# Create grader directory
mkdir -p grader

# Download grader using git sparse-checkout
echo "Cloning grader code from repository..."

cd grader

# Initialize git repo
git init
git remote add origin https://github.com/joestubbs/coe379L-fa25.git
git config core.sparseCheckout true

# Set sparse checkout paths
echo "code/Project2/*" > .git/info/sparse-checkout

# Pull only the needed directory
git pull --depth=1 origin main

# Move files to current directory
if [ -d "code/Project2" ]; then
    mv code/Project2/* .
    rm -rf code
    cd ..
    echo "Grader code downloaded successfully!"
    echo ""
    echo "Grader files:"
    ls -la grader/
else
    echo "Error: Could not find grader code in repository"
    cd ..
    exit 1
fi

echo ""
echo "You can now run the grader with:"
echo "  cd grader"
echo "  ./start_grader.sh"

