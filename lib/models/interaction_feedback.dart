enum InteractionCommand {
  friendlyGreeting,
  comeHere,
  foodSoon,
  letsPlay,
  calmDown,
}

enum CatReaction {
  approached,
  relaxed,
  vocalizedBack,
  ignored,
  movedAway,
  becameActive,
}

enum InteractionOutcome {
  positive,
  neutral,
  negative,
}

class InteractionFeedback {
  final InteractionCommand command;
  final String soundUsed;
  final CatReaction reaction;
  final InteractionOutcome outcome;

  InteractionFeedback({
    required this.command,
    required this.soundUsed,
    required this.reaction,
    required this.outcome,
  });
}