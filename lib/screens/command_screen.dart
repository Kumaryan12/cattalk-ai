import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../models/cat_state.dart';
import '../models/interaction_feedback.dart';
import 'reaction_feedback_screen.dart';

class CommandScreen extends StatelessWidget {
  final CatState predictedState;
  final CatState finalState;
  final double stateConfidence;

  const CommandScreen({
    super.key,
    required this.predictedState,
    required this.finalState,
    required this.stateConfidence,
  });

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

  String commandName(InteractionCommand command) {
    switch (command) {
      case InteractionCommand.friendlyGreeting:
        return 'Friendly Greeting';
      case InteractionCommand.comeHere:
        return 'Come Here';
      case InteractionCommand.foodSoon:
        return 'Food Soon';
      case InteractionCommand.letsPlay:
        return 'Let\'s Play';
      case InteractionCommand.calmDown:
        return 'Calm Down';
    }
  }

  String soundForCommand(InteractionCommand command) {
    switch (command) {
      case InteractionCommand.friendlyGreeting:
        return 'soft_trill_01';
      case InteractionCommand.comeHere:
        return 'short_meow_01';
      case InteractionCommand.foodSoon:
        return 'food_call_01';
      case InteractionCommand.letsPlay:
        return 'play_chirp_01';
      case InteractionCommand.calmDown:
        return 'calm_purr_01';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interaction Commands'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Final State: ${stateName(finalState)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Original Prediction: ${stateName(predictedState)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ...InteractionCommand.values.map(
              (command) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton(
                  onPressed: () async{
                    final sound = soundForCommand(command);

                    await AudioService().playSound(sound);

if (!context.mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Played sound: $sound'),
  ),
);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReactionFeedbackScreen(
                          predictedState: predictedState,
                          finalState: finalState,
                          stateConfidence: stateConfidence,
                          command: command,
                          soundUsed: sound,
                        ),
                      ),
                    );
                  },
                  child: Text(commandName(command)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}