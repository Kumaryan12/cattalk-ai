import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/interaction_log.dart';
import '../models/training_sample.dart';

class BackendStorageService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<void> uploadTrainingSample(
    TrainingSample sample,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/training-sample'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image_path': null,

        'hf_predicted_label': sample.hfPredictedLabel,
        'hf_confidence': sample.hfConfidence,
        'hf_scores_json': jsonEncode(sample.hfScores),

        'fusion_state': sample.fusionPredictedState,
        'fusion_confidence': sample.fusionConfidence,
        'fusion_scores_json': jsonEncode(sample.fusionScores),

        'reasoning_json': jsonEncode(sample.reasoning),

        'corrected_state': sample.correctedState,

        'timestamp': sample.timestamp.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to upload training sample',
      );
    }
  }

  Future<void> uploadInteractionFeedback(
    InteractionLog log,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/interaction-feedback'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'state': log.finalState.name,
        'goal': log.goal,
        'sound_used': log.soundUsed,
        'reaction': log.reaction.name,
        'outcome': log.outcome.name,
        'confidence': log.stateConfidence,
        'timestamp': log.timestamp.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to upload interaction feedback',
      );
    }
  }
}