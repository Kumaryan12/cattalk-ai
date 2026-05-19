import 'package:flutter/material.dart';

import '../models/cat_cues.dart';
import '../models/cat_state.dart';
import '../services/cat_state_engine.dart';
import 'state_feedback_screen.dart';

class CueReviewScreen extends StatefulWidget {
  const CueReviewScreen({super.key});

  @override
  State<CueReviewScreen> createState() => _CueReviewScreenState();
}

class _CueReviewScreenState extends State<CueReviewScreen> {
  MovementCue movement = MovementCue.unknown;
  EarCue ears = EarCue.unknown;
  TailCue tail = TailCue.unknown;
  BodyCue body = BodyCue.unknown;
  VocalCue vocal = VocalCue.unknown;

  CatStateResult? result;

  void predictState() {
    final cues = CatCues(
      movement: movement,
      ears: ears,
      tail: tail,
      body: body,
      vocal: vocal,
    );

    final prediction = CatStateEngine().predict(cues);

    setState(() {
      result = prediction;
    });
  }

  String stateName(CatState state) {
    switch (state) {
      case CatState.relaxed:
        return 'Relaxed';
      case CatState.exploratorySocial:
        return 'Exploratory / Social';
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

  String confidenceText(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cue Review'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Select observed cat cues',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<MovementCue>(
            value: movement,
            decoration: const InputDecoration(labelText: 'Movement'),
            items: MovementCue.values
                .map((cue) => DropdownMenuItem(
                      value: cue,
                      child: Text(cue.name),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                movement = value ?? MovementCue.unknown;
              });
            },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<EarCue>(
            value: ears,
            decoration: const InputDecoration(labelText: 'Ears'),
            items: EarCue.values
                .map((cue) => DropdownMenuItem(
                      value: cue,
                      child: Text(cue.name),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                ears = value ?? EarCue.unknown;
              });
            },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<TailCue>(
            value: tail,
            decoration: const InputDecoration(labelText: 'Tail'),
            items: TailCue.values
                .map((cue) => DropdownMenuItem(
                      value: cue,
                      child: Text(cue.name),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                tail = value ?? TailCue.unknown;
              });
            },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<BodyCue>(
            value: body,
            decoration: const InputDecoration(labelText: 'Body'),
            items: BodyCue.values
                .map((cue) => DropdownMenuItem(
                      value: cue,
                      child: Text(cue.name),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                body = value ?? BodyCue.unknown;
              });
            },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<VocalCue>(
            value: vocal,
            decoration: const InputDecoration(labelText: 'Vocalization'),
            items: VocalCue.values
                .map((cue) => DropdownMenuItem(
                      value: cue,
                      child: Text(cue.name),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                vocal = value ?? VocalCue.unknown;
              });
            },
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: predictState,
            child: const Text('Predict Cat State'),
          ),

          const SizedBox(height: 24),

          if (result != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prediction Result',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('State: ${stateName(result!.state)}'),
                    Text('Confidence: ${confidenceText(result!.confidence)}'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StateFeedbackScreen(
                              predictedState: result!.state,
                              confidence: result!.confidence,
                            ),
                          ),
                        );
                      },
                      child: const Text('Give State Feedback'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}