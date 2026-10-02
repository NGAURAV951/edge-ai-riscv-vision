from pathlib import Path

import numpy as np


MODEL_FILE = Path("models/mnist_linear_int8.npz")
TILE_SIZE = 16
INPUT_SIZE = 784
NUM_CLASSES = 10


class MNISTTiledInt8Classifier:
    """
    MNIST INT8 inference using the same 16-element
    tiled dot-product structure verified by the RTL.
    """

    def __init__(self, model_file=MODEL_FILE):
        model = np.load(model_file)

        self.weights = model["weights"].astype(np.int8)
        self.bias = model["bias"].astype(np.int32)
        self.weight_scale = float(model["weight_scale"])

        if self.weights.shape != (NUM_CLASSES, INPUT_SIZE):
            raise ValueError(
                f"Unexpected weight shape: {self.weights.shape}"
            )

        if self.bias.shape != (NUM_CLASSES,):
            raise ValueError(
                f"Unexpected bias shape: {self.bias.shape}"
            )

        if INPUT_SIZE % TILE_SIZE != 0:
            raise ValueError("Input size must be divisible by tile size")

    def predict(self, image):
        image = np.asarray(image, dtype=np.uint8)

        if image.shape != (28, 28):
            raise ValueError(
                f"Expected 28x28 image, got {image.shape}"
            )

        x = image.reshape(-1).astype(np.int32)

        scores = np.zeros(NUM_CLASSES, dtype=np.int32)

        for class_index in range(NUM_CLASSES):
            total = int(self.bias[class_index])

            for start in range(0, INPUT_SIZE, TILE_SIZE):
                x_tile = x[start:start + TILE_SIZE]
                w_tile = self.weights[
                    class_index,
                    start:start + TILE_SIZE
                ].astype(np.int32)

                total += int(np.sum(x_tile * w_tile))

            scores[class_index] = total

        predicted_digit = int(np.argmax(scores))

        return predicted_digit, scores


def main():
    data = np.load("data/mnist.npz")

    classifier = MNISTTiledInt8Classifier()

    correct = 0

    for i in range(100):
        image = data["images"][i].reshape(28, 28)
        label = int(data["labels"][i])

        prediction, _ = classifier.predict(image)

        if prediction == label:
            correct += 1

    print(f"Tiled INT8 accuracy: {correct / 100 * 100:.2f}%")
    print(f"Correct:             {correct}/100")
    print(f"Tiles per class:     {INPUT_SIZE // TILE_SIZE}")
    print(f"Classes:             {NUM_CLASSES}")

    if correct >= 90:
        print("TILED_MNIST_PASS")
    else:
        print("TILED_MNIST_CHECK")


if __name__ == "__main__":
    main()
