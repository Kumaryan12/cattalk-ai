import 'package:flutter/material.dart';

import '../models/cat_state.dart';
import 'recommended_interaction_screen.dart';

enum UserGoal {
  calmCat,
  callCat,
  playWithCat,
  buildTrust,
  getAttention,
}

class InteractionGoalScreen extends StatelessWidget {
  final CatStateResult result;

  const InteractionGoalScreen({
    super.key,
    required this.result,
  });

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

  IconData goalIcon(UserGoal goal) {
    switch (goal) {
      case UserGoal.calmCat:
        return Icons.spa;

      case UserGoal.callCat:
        return Icons.campaign;

      case UserGoal.playWithCat:
        return Icons.sports_esports;

      case UserGoal.buildTrust:
        return Icons.favorite;

      case UserGoal.getAttention:
        return Icons.notifications_active;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Interaction Goal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'What would you like to do?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          ...UserGoal.values.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RecommendedInteractionScreen(
                        result: result,
                        goal: goal,
                      ),
                    ),
                  );
                },
                icon: Icon(goalIcon(goal)),
                label: Text(
                  goalName(goal),
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}