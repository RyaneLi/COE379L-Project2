# Testing on Class VM - Step by Step Guide

## Prerequisites
- Access to your class VM (SSH credentials)
- Docker installed on the VM
- Your Docker Hub image pushed: `slrpz/hurricane-damage-classifier:latest`

## Step 1: Connect to Your Class VM

```bash
# SSH into your class VM (replace with your actual VM details)
ssh your-username@vm-address
```

## Step 2: Clone or Transfer Your Project

**Option A: Clone from GitHub (Recommended)**
```bash
git clone https://github.com/RyaneLi/COE379L-Project2.git
cd COE379L-Project2
```

**Option B: Transfer files via SCP**
```bash
# From your local machine
scp -r /Users/slrpz/Downloads/Github/COE379L-Project2 your-username@vm-address:~/
```

## Step 2.5: Download Test Data (Optional but Recommended)

To test the inference endpoint, you'll need test images. Download them from the course repository:

```bash
# Run the data download script
./get_data.sh
```

This will download the data from: https://github.com/joestubbs/coe379L-fa25/tree/main/datasets/unit03/Project2

**Alternative: Manual download**
```bash
# Create data directory
mkdir -p data

# Clone just the data directory using sparse checkout
cd data
git init
git remote add origin https://github.com/joestubbs/coe379L-fa25.git
git config core.sparseCheckout true
echo "datasets/unit03/Project2/*" > .git/info/sparse-checkout
git pull --depth=1 origin main
mv datasets/unit03/Project2/* .
rm -rf datasets
cd ..
```

## Step 3: Update docker-compose.yml

Edit `docker-compose.yml` to use your Docker Hub image:

```bash
nano docker-compose.yml
```

Make sure it has:
```yaml
image: slrpz/hurricane-damage-classifier:latest
```

## Step 4: Pull and Run the Container

```bash
# Pull the image from Docker Hub
docker pull slrpz/hurricane-damage-classifier:latest

# Verify it's x86/amd64 architecture
docker inspect slrpz/hurricane-damage-classifier:latest | grep Architecture
# Should show: "Architecture": "amd64"

# Start the container
docker-compose up -d

# Check if it's running
docker-compose ps
# Should show: STATUS: Up (healthy)
```

## Step 5: Test the Endpoints

### Test GET /summary
```bash
curl http://localhost:5000/summary | python3 -m json.tool
```

Expected: JSON response with model metadata

### Test POST /inference
```bash
# Make sure you have downloaded the data (see Step 2.5)
# Then test with an actual image from the dataset

# Get first available images (files have coordinate-based names)
FIRST_DAMAGE=$(ls data/damage/*.jpeg 2>/dev/null | head -1)
FIRST_NO_DAMAGE=$(ls data/no_damage/*.jpeg 2>/dev/null | head -1)

# Test with damaged image
curl -X POST http://localhost:5000/inference \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"$FIRST_DAMAGE" | python3 -m json.tool

# Test with non-damaged image
curl -X POST http://localhost:5000/inference \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"$FIRST_NO_DAMAGE" | python3 -m json.tool
```

Expected: `{"prediction": "damage"}` or `{"prediction": "no_damage"}`

**Note:** If you don't have the data directory, run `./get_data.sh` first to download test images from the course repository.

## Step 6: Run the Grader

The grader will test your server automatically. The grader uses a Docker container that needs to connect to your server.

### Option A: Using the grader Docker container (Recommended)

```bash
cd grader

# Make sure your server is running first
docker-compose ps  # (from project root)

# Run the grader
./start_grader.sh
```

**Important:** The grader container needs to access your server. The grader expects the server at `http://172.17.0.1:5000` (Docker's default bridge network gateway).

If the grader can't connect, you may need to:
1. Check your server is accessible: `curl http://localhost:5000/summary`
2. Check Docker network: `docker network inspect coe379l-project2_default`
3. The grader container should be on the same Docker network or use host networking

### Option B: Run grader directly (if you have the data)

```bash
cd grader

# Update base_url if needed (default is http://172.17.0.1:5000)
# Edit grader.py and change: base_url = "http://localhost:5000"

python3 grader.py
```

**Note:** For the grader to work, you need the test data in `/data/damage` and `/data/no_damage` directories.

## Step 7: View Logs (if needed)

```bash
# View container logs
docker-compose logs -f

# Check container status
docker-compose ps

# View detailed container info
docker inspect hurricane-damage-classifier
```

## Step 8: Stop the Server

```bash
docker-compose down
```

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs

# Check if port 5000 is in use
sudo netstat -tulpn | grep 5000
# Or
sudo lsof -i :5000
```

### Image not found
```bash
# Make sure you're logged into Docker Hub
docker login

# Pull the image again
docker pull slrpz/hurricane-damage-classifier:latest
```

### Architecture mismatch
```bash
# Verify architecture
docker inspect slrpz/hurricane-damage-classifier:latest | grep -i architecture
# Should be "amd64" or "x86_64"
```

### Grader can't connect
```bash
# Check if container is running
docker-compose ps

# Test endpoint manually
curl http://localhost:5000/summary

# Check Docker network
docker network ls
docker network inspect coe379l-project2_default
```

## Quick Test Script

Create a simple test script on the VM:

```bash
#!/bin/bash
echo "Testing inference server..."

echo "1. Testing GET /summary..."
curl -s http://localhost:5000/summary | python3 -m json.tool > /dev/null && echo "✓ GET /summary works" || echo "✗ GET /summary failed"

echo "2. Testing POST /inference..."
# You'll need a test image for this
# curl -X POST http://localhost:5000/inference -H "Content-Type: application/octet-stream" --data-binary @test.jpg
echo "  (Requires test image)"

echo "3. Container status:"
docker-compose ps
```

Save as `test_server.sh`, make executable: `chmod +x test_server.sh`, run: `./test_server.sh`

