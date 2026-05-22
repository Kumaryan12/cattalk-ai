import 'package:flutter/material.dart';

import '../models/cat_sound.dart';
import '../models/cat_state.dart';
import '../models/interaction_feedback.dart';
import '../services/audio_service.dart';
import '../services/sound_library_service.dart';
import 'interaction_goal_screen.dart';
import 'reaction_feedback_screen.dart';

class RecommendedInteractionScreen extends StatelessWidget {
  final CatStateResult result;
  final UserGoal goal;

  const RecommendedInteractionScreen({
    super.key,
    required this.result,
    required this.goal,
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

  String goalName(UserGoal goal) {
    switch (goal) {
      case UserGoal.calmCat:
        return 'Calm the Cat';
      case UserGoal.callCat:
        return 'Call the Cat';
      case UserGoal.playWithCat:
        return 'Play with the Cat';
      case UserGoal.buildTrust:
        return 'Build Trust';
      case UserGoal.getAttention:
        return 'Get Attention';
    }
  }

  InteractionCommand commandFromGoal(UserGoal goal) {
    switch (goal) {
      case UserGoal.calmCat:
        return InteractionCommand.calmDown;
      case UserGoal.callCat:
        return InteractionCommand.comeHere;
      case UserGoal.playWithCat:
        return InteractionCommand.letsPlay;
      case UserGoal.buildTrust:
        return InteractionCommand.friendlyGreeting;
      case UserGoal.getAttention:
        return InteractionCommand.friendlyGreeting;
    }
  }

  CatSound recommendedSound() {
    final sounds = SoundLibraryService().getAllSounds();
    final state = result.state;

    if (state == CatState.defensiveStressed || state == CatState.alertCautious) {
      if (goal == UserGoal.calmCat || goal == UserGoal.buildTrust) {
        return sounds.firstWhere((s) => s.id == 'calm_purr_01');
      }
      return sounds.firstWhere((s) => s.id == 'soft_trill_01');
    }

    if (goal == UserGoal.playWithCat) {
      return sounds.firstWhere((s) => s.id == 'play_chirp_01');
    }

    if (goal == UserGoal.callCat) {
      return sounds.firstWhere((s) => s.id == 'short_meow_01');
    }

    if (goal == UserGoal.getAttention) {
      return sounds.firstWhere((s) => s.id == 'short_meow_01');
    }

    if (goal == UserGoal.calmCat) {
      return sounds.firstWhere((s) => s.id == 'calm_purr_01');
    }

    return sounds.firstWhere((s) => s.id == 'soft_trill_01');
  }

  String recommendationText(CatSound sound) {
    final state = result.state;

    if (state == CatState.defensiveStressed) {
      return '''
• Keep distance initially
• Avoid sudden movement
• Avoid direct staring
• Use low volume
• Recommended sound: ${sound.displayName}
''';
    }

    if (state == CatState.alertCautious) {
      return '''
• Move slowly
• Use soft sound only
• Let the cat approach first
• Avoid overstimulation
• Recommended sound: ${sound.displayName}
''';
    }

    if (state == CatState.playfulActive) {
      return '''
• Use playful body language
• Introduce a toy
• Keep interaction short and fun
• Recommended sound: ${sound.displayName}
''';
    }

    return '''
• Use calm interaction
• Observe the cat response carefully
• Stop if the cat moves away
• Recommended sound: ${sound.displayName}
''';
  }

  @override
  Widget build(BuildContext context) {
    final sound = recommendedSound();
    final command = commandFromGoal(goal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Interaction Recommendation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected State: ${stateName(result.state)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Goal: ${goalName(goal)}'),
                  const SizedBox(height: 20),
                  const Text(
                    'Recommended Interaction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recommendationText(sound),
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            color: Colors.purple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Recommended Sound\n'
                'Name: ${sound.displayName}\n'
                'Type: ${sound.type.name}\n'
                'Energy: ${sound.energy}\n'
                'Best for: ${sound.bestFor}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () async {
              await AudioService().playSound(sound.assetName);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Played ${sound.displayName}'),
                ),
              );
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('Play Recommended Sound'),
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () async {
              await AudioService().stopSound();
            },
            icon: const Icon(Icons.stop),
            label: const Text('Stop Sound'),
          ),

          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReactionFeedbackScreen(
                    predictedState: result.state,
                    finalState: result.state,
                    stateConfidence: result.confidence,
                    command: command,
                    goal: goalName(goal),
                    soundUsed: sound.id,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.feedback),
            label: const Text('Record Cat Reaction'),
          ),
        ],
      ),
    );
  }
}