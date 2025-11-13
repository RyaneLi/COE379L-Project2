from flask import Flask, request, jsonify
from tensorflow import keras
import numpy as np
from PIL import Image
import io

app = Flask(__name__)

MODEL_PATH = 'best_model.h5'
TARGET_SIZE = (128, 128)

try:
    model = keras.models.load_model(MODEL_PATH)
    print(f"Model loaded successfully from {MODEL_PATH}")
except Exception as e:
    print(f"Error loading model: {e}")
    model = None

@app.route('/summary', methods=['GET'])
def get_summary():
    if model is None:
        return jsonify({"error": "Model not loaded"}), 500

    summary_list = []
    model.summary(print_fn=lambda x: summary_list.append(x))
    summary_str = "\n".join(summary_list)

    total_params = model.count_params()
    trainable_params = sum([np.prod(w.shape) for w in model.trainable_weights])
    non_trainable_params = total_params - trainable_params

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
    if model is None:
        return jsonify({"error": "Model not loaded"}), 500

    try:
        image_data = None
        
        if 'image' in request.files:
            file = request.files['image']
            image_data = file.read()
        elif request.data:
            image_data = request.data
        elif 'image' in request.form:
            return jsonify({"error": "Image must be sent as binary data or multipart file"}), 400

        if not image_data:
            return jsonify({"error": "No image data provided"}), 400

        img = Image.open(io.BytesIO(image_data))

        if img.mode != 'RGB':
            img = img.convert('RGB')

        img = img.resize(TARGET_SIZE, Image.Resampling.LANCZOS)
        img_array = np.array(img).astype('float32') / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        prediction_proba = model.predict(img_array, verbose=0)[0][0]
        prediction = "damage" if prediction_proba > 0.5 else "no_damage"

        return jsonify({
            "prediction": prediction
        })

    except Exception as e:
        return jsonify({"error": f"Error processing image: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
