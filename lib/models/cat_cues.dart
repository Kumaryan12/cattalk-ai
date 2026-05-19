enum MovementCue {
  approaching,
  still,
  movingAway,
  active,
  unknown,
}

enum EarCue {
  forward,
  neutral,
  backward,
  unknown,
}

enum TailCue {
  up,
  neutral,
  twitching,
  puffed,
  unknown,
}

enum BodyCue {
  relaxed,
  crouched,
  tense,
  playful,
  unknown,
}

enum VocalCue {
  silent,
  softMeow,
  repeatedMeow,
  hissGrowl,
  purr,
  unknown,
}

class CatCues {
  final MovementCue movement;
  final EarCue ears;
  final TailCue tail;
  final BodyCue body;
  final VocalCue vocal;

  CatCues({
    required this.movement,
    required this.ears,
    required this.tail,
    required this.body,
    required this.vocal,
  });
}