from pathlib import Path

import numpy as np


MODEL_FILE = Path("models/mnist_linear_int8.npz")
TILE_SIZE = 16
INPUT_SIZE = 784


def tiled_class_score(image, weights, bias):
    image = np.asarray(image, dtype=np.uint8)

    if image.shape != (28, 28):
        raise ValueError(
            f"Expected 28x28 image, got {image.shape}"
        )

    x = image.reshape(-1).astype(np.int32)
    w = np.asarray(weights, dtype=np.int32)

    if w.shape != (INPUT_SIZE,):
        raise ValueError(
            f"Expected 784 weights, got {w.shape}"
        )

    total = int(bias)

    for start in range(0, INPUT_SIZE, TILE_SIZE):
        x_tile = x[start:start + TILE_SIZE]
        w_tile = w[start:start + TILE_SIZE]

        total += int(np.sum(x_tile * w_tile))

    return total


def main():
    model = np.load(MODEL_FILE)
    data = np.load("data/mnist.npz")

    weights = model["weights"].astype(np.int8)
    bias = model["bias"].astype(np.int32)

    image = data["images"][0].reshape(28, 28)
    label = int(data["labels"][0])

    x = image.reshape(-1).astype(np.int32)

    # Normal full 784-element reference score for every class.
    reference_scores = (
        weights.astype(np.int32) @ x
        + bias
    )

    # Same computation using 49 sequential 16-element tiles.
    tiled_scores = np.array(
        [
            tiled_class_score(
                image,
                weights[class_index],
                bias[class_index],
            )
            for class_index in range(10)
        ],
        dtype=np.int32,
    )

    print(f"Expected digit:       {label}")
    print(f"Reference scores:     {reference_scores}")
    print(f"Tiled scores:         {tiled_scores}")
    print(f"Tiles per class:      {INPUT_SIZE // TILE_SIZE}")

    if np.array_equal(reference_scores, tiled_scores):
        print("FULL_SCORE_PASS")
    else:
        print("FULL_SCORE_FAIL")

    reference_prediction = int(np.argmax(reference_scores))
    tiled_prediction = int(np.argmax(tiled_scores))

    print(f"Reference prediction: {reference_prediction}")
    print(f"Tiled prediction:     {tiled_prediction}")

    if reference_prediction == tiled_prediction:
        print("PREDICTION_MATCH_PASS")
    else:
        print("PREDICTION_MATCH_FAIL")


if __name__ == "__main__":
    main()
