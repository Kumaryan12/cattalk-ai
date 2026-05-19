import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/cat_state.dart';
import '../models/interaction_feedback.dart';
import '../models/interaction_log.dart';
import '../services/local_storage_service.dart';

class ReactionFeedbackScreen extends StatefulWidget {
  final CatState predictedState;
  final CatState finalState;
  final double stateConfidence;
  final InteractionCommand command;
  final String soundUsed;

  const ReactionFeedbackScreen({
    super.key,
    required this.predictedState,
    required this.finalState,
    required this.stateConfidence,
    required this.command,
    required this.soundUsed,
  });

  @override
  State<ReactionFeedbackScreen> createState() => _ReactionFeedbackScreenState();
}

class _ReactionFeedbackScreenState extends State<ReactionFeedbackScreen> {
  CatReaction? selectedReaction;
  InteractionOutcome? selectedOutcome;

  String reactionName(CatReaction reaction) {
    switch (reaction) {
      case CatReaction.approached:
        return 'Cat approached';
      case CatReaction.relaxed:
        return 'Cat relaxed';
      case CatReaction.vocalizedBack:
        return 'Cat vocalized back';
      case CatReaction.ignored:
        return 'Cat ignored';
      case CatReaction.movedAway:
        return 'Cat moved away';
      case CatReaction.becameActive:
        return 'Cat became active';
    }
  }

  String outcomeName(InteractionOutcome outcome) {
    switch (outcome) {
      case InteractionOutcome.positive:
        return 'Positive';
      case InteractionOutcome.neutral:
        return 'Neutral';
      case InteractionOutcome.negative:
        return 'Negative';
    }
  }

  Future<void> saveFeedback() async {
    if (selectedReaction == null || selectedOutcome == null) return;

    final log = InteractionLog(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      predictedState: widget.predictedState,
      finalState: widget.finalState,
      stateConfidence: widget.stateConfidence,
      command: widget.command,
      soundUsed: widget.soundUsed,
      reaction: selectedReaction!,
      outcome: selectedOutcome!,
    );

    await LocalStorageService().saveInteractionLog(log);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved: ${reactionName(selectedReaction!)} / ${outcomeName(selectedOutcome!)}',
        ),
      ),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reaction Feedback'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'How did the cat react?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sound used: ${widget.soundUsed}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<CatReaction>(
            value: selectedReaction,
            decoration: const InputDecoration(
              labelText: 'Cat reaction',
              border: OutlineInputBorder(),
            ),
            items: CatReaction.values
                .map(
                  (reaction) => DropdownMenuItem(
                    value: reaction,
                    child: Text(reactionName(reaction)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedReaction = value;
              });
            },
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<InteractionOutcome>(
            value: selectedOutcome,
            decoration: const InputDecoration(
              labelText: 'Outcome',
              border: OutlineInputBorder(),
            ),
            items: InteractionOutcome.values
                .map(
                  (outcome) => DropdownMenuItem(
                    value: outcome,
                    child: Text(outcomeName(outcome)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedOutcome = value;
              });
            },
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: selectedReaction == null || selectedOutcome == null
                ? null
                : saveFeedback,
            child: const Text('Save Reaction Feedback'),
          ),
        ],
      ),
    );
  }
}