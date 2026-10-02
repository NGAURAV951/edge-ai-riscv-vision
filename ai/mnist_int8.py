from pathlib import Path

import numpy as np


MODEL_FILE = Path("models/mnist_linear_int8.npz")


class MNISTInt8Classifier:
    """INT8 weight / INT32 accumulation MNIST inference."""

    def __init__(self, model_file=MODEL_FILE):
        model = np.load(model_file)

        self.weights = model["weights"].astype(np.int8)
        self.bias = model["bias"].astype(np.int32)
        self.weight_scale = float(model["weight_scale"])

    def predict(self, image):
        image = np.asarray(image, dtype=np.uint8)

        if image.shape != (28, 28):
            raise ValueError(
                f"Expected 28x28 image, got {image.shape}"
            )

        # Keep input pixels as uint8 and use INT32 accumulation.
        x = image.reshape(-1).astype(np.int32)

        weights = self.weights.astype(np.int32)

        scores = weights @ x + self.bias

        predicted_digit = int(np.argmax(scores))

        return predicted_digit, scores


if __name__ == "__main__":
    data = np.load("data/mnist.npz")

    classifier = MNISTInt8Classifier()

    image = data["images"][0].reshape(28, 28)
    label = int(data["labels"][0])

    prediction, scores = classifier.predict(image)

    print(f"Expected digit: {label}")
    print(f"Predicted digit: {prediction}")
    print(f"Scores:          {scores}")
