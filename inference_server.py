from flask import Flask, request, jsonify
from tensorflow import keras
import numpy as np
from PIL import Image
import io

app = Flask(__name__)

# Load the model
MODEL_PATH = 'best_model.h5'
TARGET_SIZE = (128, 128)  # Must match training size

try:
    model = keras.models.load_model(MODEL_PATH)
    print(f"Model loaded successfully from {MODEL_PATH}")
except Exception as e:
    print(f"Error loading model: {e}")
    model = None

@app.route('/summary', methods=['GET'])
def get_summary():
    """
    GET /summary endpoint
    Returns JSON with model metadata
    """
    if model is None:
        return jsonify({"error": "Model not loaded"}), 500

    # Get model summary
    summary_list = []
    model.summary(print_fn=lambda x: summary_list.append(x))
    summary_str = "\n".join(summary_list)

    # Count parameters - fixed for TensorFlow 2.x compatibility
    total_params = model.count_params()
    trainable_params = sum([np.prod(w.shape) for w in model.trainable_weights])
    non_trainable_params = total_params - trainable_params

    # Get input/output shapes safely
    input_shape = list(model.input_shape[1:]) if model.input_shape else None
    output_shape = list(model.output_shape[1:]) if model.output_shape else None

    return jsonify({
        "model_name": "Hurricane Harvey Building Damage Classifier",
        "architecture": "Best performing model from training",
        "input_shape": input_shape,
        "output_shape": output_shape,
        "total_parameters": int(total_params),
        "trainable_parameters": int(trainable_params),
        "non_trainable_parameters": int(non_trainable_params),
        "summary": summary_str
    })

@app.route('/inference', methods=['POST'])
def inference():
    """
    POST /inference endpoint
    Accepts binary image data and returns prediction
    Must return JSON with top-level "prediction" key: "damage" or "no_damage"
    """
    if model is None:
        return jsonify({"error": "Model not loaded"}), 500

    try:
        # Get image data from request body (binary)
        image_data = request.data

        if not image_data:
            return jsonify({"error": "No image data provided"}), 400

        # Load and preprocess image
        img = Image.open(io.BytesIO(image_data))

        # Convert to RGB if needed
        if img.mode != 'RGB':
            img = img.convert('RGB')

        # Resize to target size (must match training)
        img = img.resize(TARGET_SIZE, Image.Resampling.LANCZOS)

        # Convert to array and normalize to [0, 1]
        img_array = np.array(img).astype('float32') / 255.0

        # Add batch dimension
        img_array = np.expand_dims(img_array, axis=0)

        # Make prediction
        prediction_proba = model.predict(img_array, verbose=0)[0][0]

        # Determine prediction: damage (1) or no_damage (0)
        prediction = "damage" if prediction_proba > 0.5 else "no_damage"

        # Return JSON object with top-level "prediction" key as required
        return jsonify({
            "prediction": prediction
        })

    except Exception as e:
        return jsonify({"error": f"Error processing image: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
