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
