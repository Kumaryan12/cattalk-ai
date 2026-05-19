class BackendPrediction {
  final String predictedLabel;
  final double confidence;
  final Map<String, dynamic> scores;
  final String warning;

  BackendPrediction({
    required this.predictedLabel,
    required this.confidence,
    required this.scores,
    required this.warning,
  });

  factory BackendPrediction.fromJson(Map<String, dynamic> json) {
    return BackendPrediction(
      predictedLabel: json['predicted_label'],
      confidence: (json['confidence'] as num).toDouble(),
      scores: json['scores'],
      warning: json['warning'],
    );
  }
}