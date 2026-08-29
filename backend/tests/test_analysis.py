import unittest
from unittest.mock import patch

import numpy as np

from routes.analysis import (
    CAT_CLASS_ID,
    DETECTOR_CONFIDENCE,
    DETECTOR_IMAGE_SIZE,
    STATE_PROMPTS,
    _best_cat_detection,
    prediction_from_results,
)
from main import health


class PredictionMappingTests(unittest.TestCase):
    def test_detector_keeps_low_confidence_cat_candidates(self):
        class EmptyDetector:
            def __init__(self):
                self.options = None

            def predict(self, _image, **options):
                self.options = options
                return []

        detector = EmptyDetector()
        with patch("routes.analysis.get_detector", return_value=detector):
            result = _best_cat_detection(np.zeros((32, 32, 3), dtype=np.uint8))

        self.assertIsNone(result)
        self.assertEqual(detector.options["classes"], [CAT_CLASS_ID])
        self.assertEqual(detector.options["conf"], DETECTOR_CONFIDENCE)
        self.assertEqual(detector.options["imgsz"], DETECTOR_IMAGE_SIZE)
        self.assertLessEqual(DETECTOR_CONFIDENCE, 0.10)

    def test_health_reports_model_readiness(self):
        response = health()

        self.assertEqual(response["status"], "ok")
        self.assertIn("model_ready", response)

    def test_maps_prompt_labels_to_canonical_states(self):
        results = [
            {"label": STATE_PROMPTS["relaxed"], "score": 0.7},
            {"label": STATE_PROMPTS["alert_cautious"], "score": 0.3},
        ]

        prediction = prediction_from_results(results)

        self.assertEqual(prediction["state"], "relaxed")
        self.assertEqual(prediction["confidence"], 0.7)
        self.assertEqual(prediction["scores"]["alert_cautious"], 0.3)

    def test_marks_a_mixed_result_as_low_confidence(self):
        results = [
            {"label": STATE_PROMPTS["playful_active"], "score": 0.34},
            {"label": STATE_PROMPTS["attention_seeking"], "score": 0.33},
            {"label": STATE_PROMPTS["exploratory_social"], "score": 0.33},
        ]

        prediction = prediction_from_results(results)

        self.assertEqual(prediction["state"], "playful_active")
        self.assertTrue(any("low confidence" in reason for reason in prediction["reasons"]))


if __name__ == "__main__":
    unittest.main()
