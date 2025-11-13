# Hurricane Harvey Building Damage Classification

## Project Overview
This project implements neural networks to classify satellite images as containing damaged or non-damaged buildings after Hurricane Harvey.

## Model Architectures
1. Dense (Fully Connected) ANN
2. LeNet-5 CNN
3. Alternate-LeNet-5 CNN

## Deployment Instructions

### Prerequisites
- Docker installed
- Docker Hub account

### Building the Docker Image

**IMPORTANT: The image must be built for x86/amd64 architecture**

The Dockerfile already specifies `--platform=linux/amd64` to ensure x86 architecture. However, if building on a Mac (ARM), you should also use the `--platform` flag in the build command.

#### Option 1: Build on x86 VM (Recommended)
```bash
# Build the image (on x86 VM - no platform flag needed)
docker build -t your-dockerhub-username/hurricane-damage-classifier:latest .

# Verify architecture
docker inspect your-dockerhub-username/hurricane-damage-classifier:latest | grep Architecture
# Should show: "Architecture": "amd64"

# Push to Docker Hub
docker push your-dockerhub-username/hurricane-damage-classifier:latest
```

#### Option 2: Build on Mac with Platform Flag
```bash
# Build with explicit platform flag (forces x86 even on ARM Mac)
docker build --platform linux/amd64 -t your-dockerhub-username/hurricane-damage-classifier:latest .

# Verify architecture
docker inspect your-dockerhub-username/hurricane-damage-classifier:latest | grep Architecture
# Should show: "Architecture": "amd64"

# Push to Docker Hub
docker push your-dockerhub-username/hurricane-damage-classifier:latest
```

#### Verify Image Architecture
Before pushing, verify the image is x86/amd64:
```bash
# Check image architecture
docker inspect your-dockerhub-username/hurricane-damage-classifier:latest | grep -A 5 "Architecture"

# Or use the provided verification script
./verify_architecture.sh your-dockerhub-username/hurricane-damage-classifier:latest

# Or use docker manifest (after pushing)
docker manifest inspect your-dockerhub-username/hurricane-damage-classifier:latest
```

#### Quick Build Script (Recommended)
Use the provided build script which automatically handles platform detection:
```bash
# Build and push with automatic x86 verification
./build_and_push.sh your-dockerhub-username

# Or with a specific tag
./build_and_push.sh your-dockerhub-username v1.0
```

**Replace `your-dockerhub-username` with your actual Docker Hub username.**

### Running with Docker Compose

**Before starting:** Update `docker-compose.yml` and replace `your-dockerhub-username` with your actual Docker Hub username.

**Start the server:**
```bash
docker-compose up -d
```

**Check server status:**
```bash
docker-compose ps
```

**Stop the server:**
```bash
docker-compose down
```

**View logs:**
```bash
docker-compose logs -f
```

**Restart the server:**
```bash
docker-compose restart
```

### API Endpoints

#### GET /summary
Returns model metadata in JSON format.

**Example:**
```bash
curl http://localhost:5000/summary
```

#### POST /inference
Classifies an image and returns prediction.

**Example using curl:**
```bash
curl -X POST http://localhost:5000/inference \
  -H "Content-Type: application/octet-stream" \
  --data-binary @test_image.jpg
```

**Example using Python:**
```python
import requests

with open('test_image.jpg', 'rb') as f:
    response = requests.post(
        'http://localhost:5000/inference',
        data=f.read(),
        headers={'Content-Type': 'application/octet-stream'}
    )
    print(response.json())
```

**Response:**
```json
{
  "prediction": "damage"
}
```

Note: The prediction will be either `"damage"` or `"no_damage"`.

### Testing the Server

#### Quick Test (Manual)
```bash
# Test GET /summary
curl http://localhost:5000/summary

# Download test data (if not already available)
./get_data.sh

# Test POST /inference (with a test image from the dataset)
FIRST_IMG=$(ls data/damage/*.jpeg 2>/dev/null | head -1)
curl -X POST http://localhost:5000/inference \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"$FIRST_IMG" | python3 -m json.tool
```

#### Using the Grader

The grader will automatically test your server endpoints. See `TESTING_ON_VM.md` for detailed instructions.

**On VM:**
```bash
cd grader
./start_grader.sh
```

**Note:** The grader expects the server at `http://172.17.0.1:5000` when running in Docker. Make sure your server container is running before starting the grader.

## Files
- `project2.ipynb` - Main notebook with model training
- `inference_server.py` - Flask inference server
- `best_model.h5` - Saved best model
- `Dockerfile` - Docker image definition
- `docker-compose.yml` - Docker Compose configuration
- `requirements.txt` - Python dependencies
