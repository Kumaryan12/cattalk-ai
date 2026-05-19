enum CatState {
  relaxed,
  exploratorySocial,
  playfulActive,
  defensiveStressed,
  attentionSeeking,
  unknown,
}

class CatStateResult {
  final CatState state;
  final double confidence;
  final Map<CatState, double> scores;

  CatStateResult({
    required this.state,
    required this.confidence,
    required this.scores,
  });
}