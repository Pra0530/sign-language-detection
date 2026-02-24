import tensorflow as tf
import numpy as np
import os

print("Creating a basic TFLite model structure for ASL recognition...")

# Define a simple CNN model that accepts 28x28x1 grayscale images
model = tf.keras.Sequential([
    tf.keras.layers.InputLayer(input_shape=(28, 28, 1)),
    tf.keras.layers.Conv2D(32, (3, 3), activation='relu'),
    tf.keras.layers.MaxPooling2D(2, 2),
    tf.keras.layers.Conv2D(64, (3, 3), activation='relu'),
    tf.keras.layers.MaxPooling2D(2, 2),
    tf.keras.layers.Flatten(),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dense(26, activation='softmax') # 26 classes for A-Z
])

model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Create a small dummy dataset to initialize the graph
dummy_x = np.random.rand(1, 28, 28, 1).astype(np.float32)
dummy_y = np.zeros((1, 26))
dummy_y[0, 0] = 1.0

# Train dummy data for 1 step
model.fit(dummy_x, dummy_y, epochs=1, verbose=0)

# Export as TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Determine output path
out_dir = '/Users/praphulragampeta/Desktop/sign language detection/assets/ml'
os.makedirs(out_dir, exist_ok=True)
model_path = os.path.join(out_dir, 'asl_alphabet.tflite')

with open(model_path, 'wb') as f:
    f.write(tflite_model)

print(f"Model saved to {model_path} ({len(tflite_model)} bytes)")

# Save labels
labels = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
labels_path = os.path.join(out_dir, 'asl_labels.txt')
with open(labels_path, 'w') as f:
    for label in labels:
        f.write(f"{label}\n")
print(f"Labels saved to {labels_path}")
