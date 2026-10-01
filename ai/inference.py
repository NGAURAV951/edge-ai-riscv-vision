from dataclasses import dataclass
import numpy as np

@dataclass(frozen=True)
class Prediction:
    label: str
    confidence: float
    features: np.ndarray

class EdgeClassifier:
    # Tiny fixed-point-style classifier suitable for embedded porting.
    LABELS = ("SAFE", "ALERT")

    def __init__(self):
        self.weights = np.array([3, 5, 2], dtype=np.int16)
        self.bias = np.int16(-350)

    @staticmethod
    def features(frame):
        frame = np.asarray(frame, dtype=np.uint8)
        mean = int(frame.mean())
        active = int((frame > 70).mean() * 100)
        peak = int(frame.max())
        return np.array([mean, active, peak], dtype=np.int16)

    def score(self, frame):
        x = self.features(frame)
        return int(x @ self.weights + self.bias), x

    def accelerator_score(self, frame):
        x = self.features(frame)

        a = np.array([x[0], x[1], x[2], 0], dtype=np.int16)
        b = np.array([self.weights[0], self.weights[1], self.weights[2], 0], dtype=np.int16)
        

        dot_product = int(
            a[0] * b[0] +
            a[1] * b[1] +
            a[2] * b[2] +
            a[3] * b[3]
        )

        return dot_product + int(self.bias), x

    def predict(self, frame):
        score, x = self.score(frame)
        label = self.LABELS[1] if score >= 0 else self.LABELS[0]
        confidence = float(1.0 / (1.0 + np.exp(-score / 100.0)))

        return Prediction(label, confidence, x)







