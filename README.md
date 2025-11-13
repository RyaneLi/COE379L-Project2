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

**IMPORTANT: Build on x86 architecture (use class VM or specify platform)**

```bash
# Build the image (on x86 VM)
docker build -t your-dockerhub-username/hurricane-damage-classifier:latest .

# Tag for Docker Hub
docker tag your-dockerhub-username/hurricane-damage-classifier:latest your-dockerhub-username/hurricane-damage-classifier:latest

# Push to Docker Hub
docker push your-dockerhub-username/hurricane-damage-classifier:latest
```

### Running with Docker Compose

**Start the server:**
```bash
docker-compose up -d
```

**Stop the server:**
```bash
docker-compose down
```

**View logs:**
```bash
docker-compose logs -f
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

**Example:**
```bash
curl -X POST http://localhost:5000/inference \
  -H "Content-Type: application/octet-stream" \
  --data-binary @test_image.jpg
```

**Response:**
```json
{
  "prediction": "damage",
  "confidence": 0.95
}
```

### Testing the Server

Use the provided grader code to test your server:
```bash
python grader.py
```

## Files
- `project2.ipynb` - Main notebook with model training
- `inference_server.py` - Flask inference server
- `best_model.h5` - Saved best model
- `Dockerfile` - Docker image definition
- `docker-compose.yml` - Docker Compose configuration
- `requirements.txt` - Python dependencies
