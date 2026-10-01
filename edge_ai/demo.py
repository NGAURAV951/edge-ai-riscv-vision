from ai.dataset import make_demo_frame
from ai.inference import EdgeClassifier
from ai.benchmark import benchmark

def main():
    model = EdgeClassifier()
    frame = make_demo_frame(seed=7)
    result = model.predict(frame)
    stats = benchmark(model, frame, repeats=500)

    print("=== Edge-AI RISC-V Vision MVP ===")
    print(f"class:      {result.label}")
    print(f"confidence: {result.confidence:.3f}")
    print(f"features:   {result.features.tolist()}")
    print(f"latency:    {stats['mean_ms']:.4f} ms")
    print(f"throughput: {stats['fps']:.1f} FPS")

if __name__ == "__main__":
    main()
