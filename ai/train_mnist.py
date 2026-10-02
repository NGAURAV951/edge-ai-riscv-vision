from pathlib import Path

import numpy as np


DATA_FILE = Path("data/mnist.npz")
MODEL_DIR = Path("models")
MODEL_FILE = MODEL_DIR / "mnist_linear.npz"


def softmax(logits):
    logits = logits - np.max(logits, axis=1, keepdims=True)
    exp_logits = np.exp(logits)
    return exp_logits / np.sum(exp_logits, axis=1, keepdims=True)


def main():
    print("Loading MNIST...")
    data = np.load(DATA_FILE)

    images = data["images"]
    labels = data["labels"].astype(np.int64)

    # Normalize pixels to 0-1.
    X = images.astype(np.float32) / 255.0
    y = labels

    # Use a manageable subset for local training.
    X = X[:20000]
    y = y[:20000]

    # Deterministic train/test split.
    rng = np.random.default_rng(42)
    indices = rng.permutation(len(X))

    split = int(len(X) * 0.8)

    train_idx = indices[:split]
    test_idx = indices[split:]

    X_train = X[train_idx]
    y_train = y[train_idx]

    X_test = X[test_idx]
    y_test = y[test_idx]

    print(f"Training samples: {len(X_train)}")
    print(f"Test samples:     {len(X_test)}")

    # 10-class linear classifier.
    num_features = X_train.shape[1]
    num_classes = 10

    weights = np.zeros((num_classes, num_features), dtype=np.float32)
    bias = np.zeros(num_classes, dtype=np.float32)

    learning_rate = 0.5
    epochs = 10
    batch_size = 128

    print("Training NumPy linear classifier...")

    for epoch in range(epochs):
        order = rng.permutation(len(X_train))

        for start in range(0, len(X_train), batch_size):
            batch_idx = order[start:start + batch_size]

            xb = X_train[batch_idx]
            yb = y_train[batch_idx]

            logits = xb @ weights.T + bias
            probabilities = softmax(logits)

            probabilities[np.arange(len(yb)), yb] -= 1.0

            probabilities /= len(yb)

            grad_weights = probabilities.T @ xb
            grad_bias = probabilities.sum(axis=0)

            weights -= learning_rate * grad_weights
            bias -= learning_rate * grad_bias

        train_logits = X_train @ weights.T + bias
        train_predictions = np.argmax(train_logits, axis=1)
        train_accuracy = np.mean(train_predictions == y_train)

        print(
            f"Epoch {epoch + 1:02d}/{epochs} "
            f"- train accuracy: {train_accuracy * 100:.2f}%"
        )

    test_logits = X_test @ weights.T + bias
    test_predictions = np.argmax(test_logits, axis=1)
    test_accuracy = np.mean(test_predictions == y_test)

    print(f"Test accuracy: {test_accuracy * 100:.2f}%")

    MODEL_DIR.mkdir(parents=True, exist_ok=True)

    np.savez_compressed(
        MODEL_FILE,
        weights=weights,
        bias=bias,
    )

    print(f"Saved model: {MODEL_FILE}")
    print(f"Weights shape: {weights.shape}")
    print(f"Bias shape:    {bias.shape}")


if __name__ == "__main__":
    main()
