#!/bin/bash

# Script to download data from the course repository
# Usage: ./get_data.sh

echo "Downloading data from course repository..."

# Check if data directory already exists
if [ -d "data" ] && [ "$(ls -A data 2>/dev/null)" ]; then
    echo "Data directory already exists and is not empty."
    read -p "Do you want to overwrite it? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    rm -rf data
fi

# Create data directory
mkdir -p data

# Download data using git sparse-checkout or wget/curl
echo "Cloning data from repository..."

# Option 1: Use git sparse-checkout (most efficient)
if command -v git &> /dev/null; then
    echo "Using git sparse-checkout..."
    cd data
    
    # Initialize git repo
    git init
    git remote add origin https://github.com/joestubbs/coe379L-fa25.git
    git config core.sparseCheckout true
    
    # Set sparse checkout paths
    echo "datasets/unit03/Project2/*" > .git/info/sparse-checkout
    
    # Pull only the needed directory
    git pull --depth=1 origin main
    
    # Move files to current directory
    if [ -d "datasets/unit03/Project2" ]; then
        mv datasets/unit03/Project2/* .
        rm -rf datasets
        cd ..
        echo "Data downloaded successfully!"
    else
        echo "Error: Could not find data in repository"
        cd ..
        exit 1
    fi
else
    # Option 2: Use wget to download zip
    echo "Git not available, trying wget..."
    if command -v wget &> /dev/null; then
        cd data
        wget -q https://github.com/joestubbs/coe379L-fa25/archive/refs/heads/main.zip
        unzip -q main.zip
        if [ -d "coe379L-fa25-main/datasets/unit03/Project2" ]; then
            mv coe379L-fa25-main/datasets/unit03/Project2/* .
            rm -rf coe379L-fa25-main main.zip
            cd ..
            echo "Data downloaded successfully!"
        else
            echo "Error: Could not find data in repository"
            cd ..
            exit 1
        fi
    else
        echo "Error: Neither git nor wget is available"
        echo "Please install git: sudo apt-get install git"
        exit 1
    fi
fi

echo ""
echo "Data structure:"
ls -la data/
echo ""
echo "You can now test the inference server with:"
echo "  FIRST_IMG=\$(ls data/damage/*.jpeg | head -1)"
echo "  curl -X POST http://localhost:5000/inference -H 'Content-Type: application/octet-stream' --data-binary @\"\$FIRST_IMG\""

