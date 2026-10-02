from pathlib import Path

import numpy as np


MODEL_FILE = Path("models/mnist_linear.npz")


class MNISTClassifier:
    """Lightweight NumPy inference engine for the trained MNIST model."""

    def __init__(self, model_file=MODEL_FILE):
        model = np.load(model_file)

        self.weights = model["weights"].astype(np.float32)
        self.bias = model["bias"].astype(np.float32)

        if self.weights.shape != (10, 784):
            raise ValueError(
                f"Unexpected weight shape: {self.weights.shape}"
            )

        if self.bias.shape != (10,):
            raise ValueError(
                f"Unexpected bias shape: {self.bias.shape}"
            )

    @staticmethod
    def preprocess(image):
        image = np.asarray(image, dtype=np.uint8)

        if image.shape != (28, 28):
            raise ValueError(
                f"Expected 28x28 image, got {image.shape}"
            )

        return image.astype(np.float32).reshape(1, 784) / 255.0

    def predict(self, image):
        x = self.preprocess(image)

        logits = x @ self.weights.T + self.bias

        logits = logits - np.max(logits, axis=1, keepdims=True)
        probabilities = np.exp(logits)
        probabilities /= np.sum(
            probabilities,
            axis=1,
            keepdims=True,
        )

        predicted_digit = int(np.argmax(probabilities[0]))
        confidence = float(probabilities[0, predicted_digit])

        return predicted_digit, confidence


if __name__ == "__main__":
    data = np.load("data/mnist.npz")

    classifier = MNISTClassifier()

    image = data["images"][0].reshape(28, 28)
    label = int(data["labels"][0])

    prediction, confidence = classifier.predict(image)

    print(f"Expected digit: {label}")
    print(f"Predicted digit: {prediction}")
    print(f"Confidence:      {confidence:.4f}")
