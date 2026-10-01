from time import perf_counter

def benchmark(model, frame, repeats=200):
    start = perf_counter()
    for _ in range(repeats):
        model.predict(frame)
    elapsed = perf_counter() - start
    mean_s = elapsed / repeats
    return {
        "mean_ms": mean_s * 1000.0,
        "fps": 1.0 / mean_s if mean_s else float("inf"),
        "repeats": repeats,
    }
