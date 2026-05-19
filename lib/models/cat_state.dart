enum CatState {
  relaxed,
  exploratorySocial,
  alertCautious,
  playfulActive,
  defensiveStressed,
  attentionSeeking,
  unknown,
}

class CatStateResult {
  final CatState state;
  final double confidence;
  final Map<CatState, double> scores;
  final List<String> reasons;

  CatStateResult({
    required this.state,
    required this.confidence,
    required this.scores,
    required this.reasons,
  });
}