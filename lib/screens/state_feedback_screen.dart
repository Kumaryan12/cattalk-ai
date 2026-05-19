import 'package:flutter/material.dart';

import '../models/cat_state.dart';
import 'command_screen.dart';
class StateFeedbackScreen extends StatefulWidget {
  final CatState predictedState;
  final double confidence;

  const StateFeedbackScreen({
    super.key,
    required this.predictedState,
    required this.confidence,
  });

  @override
  State<StateFeedbackScreen> createState() => _StateFeedbackScreenState();
}

class _StateFeedbackScreenState extends State<StateFeedbackScreen> {
  CatState? correctedState;
  bool? wasCorrect;

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

  void submitFeedback() {
  final finalState = wasCorrect == true
      ? widget.predictedState
      : correctedState ?? widget.predictedState;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('State feedback saved: ${stateName(finalState)}'),
    ),
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CommandScreen(
  predictedState: widget.predictedState,
  finalState: finalState,
  stateConfidence: widget.confidence,
),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (widget.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Was our state prediction correct?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Predicted: ${stateName(widget.predictedState)}\nConfidence: $confidencePercent%',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                setState(() {
                  wasCorrect = true;
                  correctedState = widget.predictedState;
                });
                submitFeedback();
              },
              child: const Text('Yes, this is correct'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  wasCorrect = false;
                });
              },
              child: const Text('No, I want to correct it'),
            ),
            const SizedBox(height: 20),
            if (wasCorrect == false)
              DropdownButtonFormField<CatState>(
                value: correctedState,
                decoration: const InputDecoration(
                  labelText: 'Correct state',
                  border: OutlineInputBorder(),
                ),
                items: CatState.values
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
            const SizedBox(height: 20),
            if (wasCorrect == false)
              FilledButton(
                onPressed: correctedState == null ? null : submitFeedback,
                child: const Text('Save Corrected State'),
              ),
          ],
        ),
      ),
    );
  }
}