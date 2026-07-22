import 'package:flutter/material.dart';

import '../models/cat_state.dart';
import '../ui/cat_state_ui.dart';
import '../ui/cattalk_theme.dart';
import 'recommended_interaction_screen.dart';

enum UserGoal { calmCat, callCat, playWithCat, buildTrust, getAttention }

extension UserGoalUi on UserGoal {
  String get label {
    switch (this) {
      case UserGoal.calmCat:
        return 'Help them settle';
      case UserGoal.callCat:
        return 'Invite them closer';
      case UserGoal.playWithCat:
        return 'Start a play moment';
      case UserGoal.buildTrust:
        return 'Build trust gently';
      case UserGoal.getAttention:
        return 'Get their attention';
    }
  }

  String get description {
    switch (this) {
      case UserGoal.calmCat:
        return 'Lower stimulation and create a calmer atmosphere.';
      case UserGoal.callCat:
        return 'Offer a soft invitation without forcing contact.';
      case UserGoal.playWithCat:
        return 'Use a short sound and toy-led interaction.';
      case UserGoal.buildTrust:
        return 'Create a predictable, low-pressure connection.';
      case UserGoal.getAttention:
        return 'Use a familiar cue, then wait for their choice.';
    }
  }

  IconData get icon {
    switch (this) {
      case UserGoal.calmCat:
        return Icons.spa_outlined;
      case UserGoal.callCat:
        return Icons.waving_hand_outlined;
      case UserGoal.playWithCat:
        return Icons.toys_outlined;
      case UserGoal.buildTrust:
        return Icons.favorite_border_rounded;
      case UserGoal.getAttention:
        return Icons.notifications_none_rounded;
    }
  }
}

class InteractionGoalScreen extends StatelessWidget {
  final CatStateResult result;
  const InteractionGoalScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final stateColor = result.state.color(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your goal')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(result.state.icon, color: stateColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Current estimate: ${result.state.label}',
                        style: TextStyle(
                          color: stateColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'What feels right for this moment?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose an intention. We’ll shape a gentle, cat-first plan.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              ...UserGoal.values.map(
                (goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecommendedInteractionScreen(
                            result: result,
                            goal: goal,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: CatTalkColors.lilac,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(goal.icon, color: CatTalkColors.plum),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.label,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    goal.description,
                                    style: const TextStyle(
                                      color: CatTalkColors.mutedInk,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
