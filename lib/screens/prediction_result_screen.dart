import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/backend_prediction.dart';
import '../models/cat_state.dart';
import '../models/training_sample.dart';
import '../services/backend_storage_service.dart';
import '../services/training_memory_service.dart';
import 'interaction_goal_screen.dart';

class PredictionResultScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final CatStateResult result;
  final BackendPrediction? backendPrediction;

  const PredictionResultScreen({
    super.key,
    required this.imageBytes,
    required this.result,
    required this.backendPrediction,
  });

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen> {
  CatState? correctedState;
  bool showCorrectionPicker = false;
  bool isSaving = false;

  String stateName(CatState state) {
    switch (state) {
      case CatState.relaxed:
        return 'Relaxed';
      case CatState.exploratorySocial:
        return 'Exploratory / Social';
      case CatState.alertCautious:
        return 'Alert / Cautious';
      case CatState.playfulActive:
        return 'Playful / Active';
      case CatState.defensiveStressed:
        return 'Defensive / Stressed';
      case CatState.attentionSeeking:
        return 'Attention Seeking';
      case CatState.unknown:
        return 'Unknown';
    }
  }

  String confidenceLabel(double confidence) {
    if (confidence >= 0.70) return 'High';
    if (confidence >= 0.45) return 'Medium';
    return 'Low';
  }

  Color moodColor(CatState state) {
    switch (state) {
      case CatState.relaxed:
        return Colors.green;
      case CatState.exploratorySocial:
        return Colors.teal;
      case CatState.alertCautious:
        return Colors.orange;
      case CatState.playfulActive:
        return Colors.blue;
      case CatState.defensiveStressed:
        return Colors.red;
      case CatState.attentionSeeking:
        return Colors.purple;
      case CatState.unknown:
        return Colors.grey;
    }
  }

  String friendlySummary(CatState state) {
    switch (state) {
      case CatState.relaxed:
        return 'Your cat appears calm and comfortable.';
      case CatState.exploratorySocial:
        return 'Your cat appears curious and socially open.';
      case CatState.alertCautious:
        return 'Your cat appears alert and cautious.';
      case CatState.playfulActive:
        return 'Your cat appears active and playful.';
      case CatState.defensiveStressed:
        return 'Your cat may be stressed or defensive. Approach gently.';
      case CatState.attentionSeeking:
        return 'Your cat may be trying to get attention.';
      case CatState.unknown:
        return 'The system is not confident enough to classify this state.';
    }
  }

  Map<String, dynamic> fusionScoresToJson() {
    return widget.result.scores.map(
      (state, score) => MapEntry(stateName(state), score),
    );
  }

  Future<void> saveFeedback({
    required bool correct,
  }) async {
    if (isSaving) return;

    final finalState = correct ? widget.result.state : correctedState;
    if (finalState == null) return;

    setState(() {
      isSaving = true;
    });

    final hf = widget.backendPrediction;

    String? imagePath;
    try {
      imagePath = await BackendStorageService().uploadImage(widget.imageBytes);
    } catch (_) {
      imagePath = null;
    }

    final sample = TrainingSample(
      imageBase64: base64Encode(widget.imageBytes),
      imagePath: imagePath,
      hfPredictedLabel: hf?.predictedLabel,
      hfConfidence: hf?.confidence,
      hfScores: hf?.scores,
      fusionPredictedState: stateName(widget.result.state),
      fusionConfidence: widget.result.confidence,
      fusionScores: fusionScoresToJson(),
      reasoning: widget.result.reasons,
      correctedState: stateName(finalState),
      timestamp: DateTime.now(),
    );

    await TrainingMemoryService().saveSample(sample);

    if (imagePath != null) {
      await BackendStorageService().uploadTrainingSample(sample);
    }

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InteractionGoalScreen(
          result: widget.result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final color = moodColor(result.state);
    final reasons = result.reasons.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Prediction'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              widget.imageBytes,
              height: 280,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Mood Estimate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    stateName(result.state),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    friendlySummary(result.state),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Confidence: ${confidenceLabel(result.confidence)} '
                    '(${(result.confidence * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: result.confidence.clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Why this result?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (reasons.isEmpty)
                    const Text('No detailed reasoning available.')
                  else
                    ...reasons.map(
                      (reason) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $reason',
                          style: const TextStyle(height: 1.35),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Was this prediction correct?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: isSaving
                ? null
                : () async {
                    await saveFeedback(correct: true);
                  },
            icon: const Icon(Icons.check),
            label: Text(isSaving ? 'Saving...' : 'Yes, it is correct'),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: isSaving
                ? null
                : () {
                    setState(() {
                      showCorrectionPicker = true;
                    });
                  },
            icon: const Icon(Icons.edit),
            label: const Text('No, correct the mood'),
          ),

          if (showCorrectionPicker) ...[
            const SizedBox(height: 16),

            DropdownButtonFormField<CatState>(
              value: correctedState,
              decoration: const InputDecoration(
                labelText: 'Actual mood',
                border: OutlineInputBorder(),
              ),
              items: CatState.values
                  .where((e) => e != CatState.unknown)
                  .map(
                    (state) => DropdownMenuItem(
                      value: state,
                      child: Text(stateName(state)),
                    ),
                  )
                  .toList(),
              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        correctedState = value;
                      });
                    },
            ),

            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: correctedState == null || isSaving
                  ? null
                  : () async {
                      await saveFeedback(correct: false);
                    },
              icon: const Icon(Icons.save),
              label: Text(isSaving ? 'Saving...' : 'Save and Continue'),
            ),
          ],
        ],
      ),
    );
  }
}