import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/backend_prediction.dart';
import '../models/cat_state.dart';
import '../models/training_sample.dart';
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

  Map<String, dynamic> fusionScoresToJson() {
    return widget.result.scores.map(
      (state, score) => MapEntry(stateName(state), score),
    );
  }

  Future<void> saveFeedback({
    required bool correct,
  }) async {
    final finalState = correct ? widget.result.state : correctedState;

    if (finalState == null) return;

    final hf = widget.backendPrediction;

    final sample = TrainingSample(
      imageBase64: base64Encode(widget.imageBytes),
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

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mood feedback saved successfully.'),
      ),
    );
  }

  void goToInteractionGoal() {
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
    final hf = widget.backendPrediction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Prediction'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              widget.imageBytes,
              height: 280,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 24),

          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fusion Prediction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    stateName(result.state),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Reasoning',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  ...result.reasons.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $reason'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (hf != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Hugging Face Raw Estimate\n'
                  'Label: ${hf.predictedLabel}\n'
                  'Confidence: ${(hf.confidence * 100).toStringAsFixed(1)}%\n\n'
                  '${hf.warning}',
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          const Text(
            'Was this prediction correct?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: () async {
              await saveFeedback(correct: true);

              if (!context.mounted) return;

              goToInteractionGoal();
            },
            icon: const Icon(Icons.check),
            label: const Text('Yes, Correct'),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<CatState>(
            value: correctedState,
            decoration: const InputDecoration(
              labelText: 'Select actual mood if incorrect',
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
            onChanged: (value) {
              setState(() {
                correctedState = value;
              });
            },
          ),

          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: correctedState == null
                ? null
                : () async {
                    await saveFeedback(correct: false);

                    if (!context.mounted) return;

                    goToInteractionGoal();
                  },
            icon: const Icon(Icons.save),
            label: const Text('Save Corrected Mood'),
          ),
        ],
      ),
    );
  }
}