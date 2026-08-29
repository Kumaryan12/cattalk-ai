import 'package:flutter/material.dart';

import '../models/cat_state.dart';

extension CatStateUi on CatState {
  String get label {
    switch (this) {
      case CatState.relaxed:
        return 'Relaxed';
      case CatState.exploratorySocial:
        return 'Curious & social';
      case CatState.alertCautious:
        return 'Alert & cautious';
      case CatState.playfulActive:
        return 'Playful & active';
      case CatState.defensiveStressed:
        return 'Defensive or stressed';
      case CatState.attentionSeeking:
        return 'Seeking attention';
      case CatState.unknown:
        return 'Unclear';
    }
  }

  String get summary {
    switch (this) {
      case CatState.relaxed:
        return 'Your cat appears comfortable. Keep the interaction gentle and predictable.';
      case CatState.exploratorySocial:
        return 'Your cat looks open to exploring or connecting with you.';
      case CatState.alertCautious:
        return 'Your cat is paying close attention. Move slowly and let them choose the distance.';
      case CatState.playfulActive:
        return 'Your cat may be ready for a short, energetic play session.';
      case CatState.defensiveStressed:
        return 'Your cat may need space. Avoid reaching in and reduce stimulation around them.';
      case CatState.attentionSeeking:
        return 'Your cat may be inviting contact, food, play, or another familiar routine.';
      case CatState.unknown:
        return 'There is not enough visual evidence for a useful estimate.';
    }
  }

  IconData get icon {
    switch (this) {
      case CatState.relaxed:
        return Icons.spa_rounded;
      case CatState.exploratorySocial:
        return Icons.explore_rounded;
      case CatState.alertCautious:
        return Icons.visibility_rounded;
      case CatState.playfulActive:
        return Icons.toys_rounded;
      case CatState.defensiveStressed:
        return Icons.shield_outlined;
      case CatState.attentionSeeking:
        return Icons.favorite_outline_rounded;
      case CatState.unknown:
        return Icons.help_outline_rounded;
    }
  }

  Color color(BuildContext context) {
    switch (this) {
      case CatState.relaxed:
        return const Color(0xFF75D9B0);
      case CatState.exploratorySocial:
        return const Color(0xFF68D5E8);
      case CatState.alertCautious:
        return const Color(0xFFFFC56E);
      case CatState.playfulActive:
        return const Color(0xFFA8A6FF);
      case CatState.defensiveStressed:
        return const Color(0xFFFF8585);
      case CatState.attentionSeeking:
        return const Color(0xFFFF9ED7);
      case CatState.unknown:
        return Theme.of(context).colorScheme.outline;
    }
  }
}
