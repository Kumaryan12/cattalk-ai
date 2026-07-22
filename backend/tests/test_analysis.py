import unittest

from routes.analysis import STATE_PROMPTS, prediction_from_results
from main import health


class PredictionMappingTests(unittest.TestCase):
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
