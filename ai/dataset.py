import numpy as np

def make_demo_frame(size=32, seed=7):
    # Deterministic synthetic grayscale frame. The bright rectangle is a
    # simplified foreground/safety object so no external dataset is needed.
    rng = np.random.default_rng(seed)
    frame = rng.normal(20, 4, (size, size)).clip(0, 255)
    frame[8:24, 12:20] += 100
    return frame.clip(0, 255).astype(np.uint8)
