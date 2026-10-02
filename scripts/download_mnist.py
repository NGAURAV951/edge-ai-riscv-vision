from pathlib import Path

import numpy as np
from sklearn.datasets import fetch_openml


DATA_DIR = Path("data")
OUTPUT_FILE = DATA_DIR / "mnist.npz"


def main():
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    print("Downloading/loading MNIST...")
    mnist = fetch_openml(
        "mnist_784",
        version=1,
        as_frame=False,
        parser="auto",
    )

    images = mnist.data.astype(np.uint8)
    labels = mnist.target.astype(np.uint8)

    np.savez_compressed(
        OUTPUT_FILE,
        images=images,
        labels=labels,
    )

    print(f"Saved: {OUTPUT_FILE}")
    print(f"Images: {images.shape}")
    print(f"Labels: {labels.shape}")


if __name__ == "__main__":
    main()
