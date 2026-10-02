import numpy as np


TILE_SIZE = 16


def tiled_dot_product(x, weights):
    """
    Compute a dot product using the same 16-element
    tile structure as the RTL accelerator.
    """
    x = np.asarray(x, dtype=np.int32).reshape(-1)
    weights = np.asarray(weights, dtype=np.int32).reshape(-1)

    if x.shape != weights.shape:
        raise ValueError("Input and weight vectors must have the same length")

    if len(x) % TILE_SIZE != 0:
        raise ValueError("Vector length must be divisible by 16")

    total = 0

    for start in range(0, len(x), TILE_SIZE):
        x_tile = x[start:start + TILE_SIZE]
        w_tile = weights[start:start + TILE_SIZE]

        partial = int(np.sum(x_tile * w_tile))
        total += partial

    return total


def main():
    rng = np.random.default_rng(42)

    x = rng.integers(-8, 8, size=784, dtype=np.int32)
    weights = rng.integers(-8, 8, size=784, dtype=np.int32)

    reference = int(np.dot(x, weights))
    tiled = tiled_dot_product(x, weights)

    print(f"Reference dot product: {reference}")
    print(f"Tiled dot product:     {tiled}")
    print(f"Tiles:                  {len(x) // TILE_SIZE}")

    if reference == tiled:
        print("TILED_REFERENCE_PASS")
    else:
        print("TILED_REFERENCE_FAIL")


if __name__ == "__main__":
    main()
