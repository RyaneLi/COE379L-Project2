Use of AI

---------

[1]. Tool: AI Coding Assistant (Cursor)

     Prompt: Create a function to visualize sample images from both damaged and non-damaged classes in a 2x4 grid layout using matplotlib

     Output:
       def visualize_samples(images, labels, num_samples=8):
           """
           Display sample images from both classes
           """
           fig, axes = plt.subplots(2, 4, figsize=(16, 8))
           fig.suptitle('Sample Images: Damaged (Top) vs Non-Damaged (Bottom)', fontsize=16)
           
           # Get damaged images
           damaged_indices = np.where(labels == 1)[0]
           non_damaged_indices = np.where(labels == 0)[0]
           
           # Display damaged images
           for i in range(min(4, len(damaged_indices))):
               idx = damaged_indices[i]
               axes[0, i].imshow(images[idx])
               axes[0, i].set_title(f'Damaged (Label: 1)\nShape: {images[idx].shape}')
               axes[0, i].axis('off')
           
           # Display non-damaged images
           for i in range(min(4, len(non_damaged_indices))):
               idx = non_damaged_indices[i]
               axes[1, i].imshow(images[idx])
               axes[1, i].set_title(f'Non-Damaged (Label: 0)\nShape: {images[idx].shape}')
               axes[1, i].axis('off')
           
           plt.tight_layout()
           plt.show()

[2]. Tool: AI Coding Assistant (Cursor)

     Prompt: Create a function to plot training history showing accuracy and loss curves side by side using matplotlib subplots

     Output:
       def plot_training_history(history, model_name):
           fig, axes = plt.subplots(1, 2, figsize=(12, 4))
           
           # Plot accuracy
           axes[0].plot(history.history['accuracy'], label='Train Accuracy')
           axes[0].plot(history.history['val_accuracy'], label='Val Accuracy')
           axes[0].set_title(f'{model_name} - Accuracy')
           axes[0].set_xlabel('Epoch')
           axes[0].set_ylabel('Accuracy')
           axes[0].legend()
           axes[0].grid(True)
           
           # Plot loss
           axes[1].plot(history.history['loss'], label='Train Loss')
           axes[1].plot(history.history['val_loss'], label='Val Loss')
           axes[1].set_title(f'{model_name} - Loss')
           axes[1].set_xlabel('Epoch')
           axes[1].set_ylabel('Loss')
           axes[1].legend()
           axes[1].grid(True)
           
           plt.tight_layout()
           plt.show()

[3]. Tool: AI Coding Assistant (Cursor)

     Prompt: How do I create a confusion matrix heatmap using seaborn with proper labels and formatting?

     Output:
       cm = confusion_matrix(y_test, y_pred)
       plt.figure(figsize=(8, 6))
       sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                   xticklabels=['Non-Damaged', 'Damaged'],
                   yticklabels=['Non-Damaged', 'Damaged'])
       plt.title(f'Confusion Matrix - {best_model_name}')
       plt.ylabel('True Label')
       plt.xlabel('Predicted Label')
       plt.show()

[4]. Tool: AI Coding Assistant (Cursor)

     Prompt: Create a Flask inference server with GET /summary and POST /inference endpoints. The POST endpoint should accept binary image data and return JSON with prediction key containing "damage" or "no_damage"

     Output:
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
           summary_str = "\\n".join(summary_list)
           
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
               image_data = request.data
               
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
