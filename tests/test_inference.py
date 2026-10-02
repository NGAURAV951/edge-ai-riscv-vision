import numpy as np

from ai.dataset import make_demo_frame
from ai.inference import EdgeClassifier


def test_demo_frame_is_reproducible():
    assert np.array_equal(
        make_demo_frame(seed=7),
        make_demo_frame(seed=7)
    )


def test_feature_shape():
    result = EdgeClassifier().predict(make_demo_frame())
    assert result.features.shape == (3,)


def test_demo_frame_is_alert():
    result = EdgeClassifier().predict(make_demo_frame())

    assert result.label == "ALERT"
    assert 0.5 <= result.confidence <= 1.0


def test_zero_frame_is_safe():
    result = EdgeClassifier().predict(
        np.zeros((32, 32), dtype=np.uint8)
    )

    assert result.label == "SAFE"


def test_accelerator_score_matches_reference():
    frame = make_demo_frame()

    classifier = EdgeClassifier()

    reference_score, reference_features = classifier.score(frame)

    accelerator_score, accelerator_features = (
        classifier.accelerator_score(frame)
    )

    assert accelerator_score == reference_score
    assert np.array_equal(
        accelerator_features,
        reference_features
    )


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


def test_mnist_tiled_dot_product_matches_reference():
    from ai.mnist_tiled_reference import tiled_dot_product

    rng = np.random.default_rng(123)

    x = rng.integers(
        -8,
        8,
        size=784,
        dtype=np.int32
    )

    weights = rng.integers(
        -8,
        8,
        size=784,
        dtype=np.int32
    )

    reference = int(np.dot(x, weights))
    tiled = tiled_dot_product(x, weights)

    assert tiled == reference


def test_tiled_mnist_matches_int8_classifier():
    from ai.mnist_int8 import MNISTInt8Classifier
    from ai.mnist_tiled_inference import MNISTTiledInt8Classifier

    data = np.load("data/mnist.npz")

    reference_classifier = MNISTInt8Classifier()
    tiled_classifier = MNISTTiledInt8Classifier()

    for i in range(100):
        image = data["images"][i].reshape(28, 28)

        reference_prediction, _ = reference_classifier.predict(image)
        tiled_prediction, _ = tiled_classifier.predict(image)

        assert tiled_prediction == reference_prediction
