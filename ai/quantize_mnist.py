from pathlib import Path

import numpy as np


MODEL_FILE = Path("models/mnist_linear.npz")
QUANTIZED_MODEL_FILE = Path("models/mnist_linear_int8.npz")


def main():
    model = np.load(MODEL_FILE)

    weights = model["weights"].astype(np.float32)
    bias = model["bias"].astype(np.float32)

    # Symmetric INT8 quantization for weights.
    max_abs = np.max(np.abs(weights))

    weight_scale = max_abs / 127.0

    quantized_weights = np.round(
        weights / weight_scale
    ).astype(np.int8)

    # Keep bias in INT32 for safe accumulation.
    quantized_bias = np.round(
        bias / weight_scale
    ).astype(np.int32)

    np.savez_compressed(
        QUANTIZED_MODEL_FILE,
        weights=quantized_weights,
        bias=quantized_bias,
        weight_scale=np.float32(weight_scale),
    )

    print("INT8 quantization complete")
    print(f"Original weights:   {weights.shape}, {weights.dtype}")
    print(f"Quantized weights:  {quantized_weights.shape}, {quantized_weights.dtype}")
    print(f"Bias:               {quantized_bias.shape}, {quantized_bias.dtype}")
    print(f"Weight scale:       {weight_scale:.8f}")
    print(f"Weight range:       {quantized_weights.min()} to {quantized_weights.max()}")
    print(f"Saved:              {QUANTIZED_MODEL_FILE}")


if __name__ == "__main__":
    main()
