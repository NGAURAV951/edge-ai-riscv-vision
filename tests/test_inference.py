import numpy as np
from ai.dataset import make_demo_frame
from ai.inference import EdgeClassifier

def test_demo_frame_is_reproducible():
    assert np.array_equal(make_demo_frame(seed=7), make_demo_frame(seed=7))

def test_feature_shape():
    result = EdgeClassifier().predict(make_demo_frame())
    assert result.features.shape == (3,)

def test_demo_frame_is_alert():
    result = EdgeClassifier().predict(make_demo_frame())
    assert result.label == "ALERT"
    assert 0.5 <= result.confidence <= 1.0

def test_zero_frame_is_safe():
    result = EdgeClassifier().predict(np.zeros((32, 32), dtype=np.uint8))
    assert result.label == "SAFE"


def test_accelerator_score_matches_reference():
    frame = make_demo_frame()
    classifier = EdgeClassifier()

    reference_score, reference_features = classifier.score(frame)
    accelerator_score, accelerator_features = classifier.accelerator_score(frame)

    assert accelerator_score == reference_score
    assert np.array_equal(accelerator_features, reference_features)

def test_int8_inference_matches_label():
    from ai.mnist_int8 import MNISTInt8Classifier

    data = np.load("data/mnist.npz")

    classifier = MNISTInt8Classifier()

    correct = 0

    for i in range(100):
        image = data["images"][i].reshape(28, 28)
        label = int(data["labels"][i])

        prediction, _ = classifier.predict(image)

        if prediction == label:
            correct += 1

    assert correct >= 90
