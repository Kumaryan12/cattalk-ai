class TrainingSample {
  final String imageBase64;
  final String? imagePath;

  final String? hfPredictedLabel;
  final double? hfConfidence;
  final Map<String, dynamic>? hfScores;

  final String fusionPredictedState;
  final double fusionConfidence;
  final Map<String, dynamic> fusionScores;
  final List<String> reasoning;

  final String correctedState;
  final DateTime timestamp;

  TrainingSample({
    required this.imageBase64,
    required this.imagePath,
    required this.hfPredictedLabel,
    required this.hfConfidence,
    required this.hfScores,
    required this.fusionPredictedState,
    required this.fusionConfidence,
    required this.fusionScores,
    required this.reasoning,
    required this.correctedState,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageBase64': imageBase64,
      'imagePath': imagePath,
      'hfPredictedLabel': hfPredictedLabel,
      'hfConfidence': hfConfidence,
      'hfScores': hfScores,
      'fusionPredictedState': fusionPredictedState,
      'fusionConfidence': fusionConfidence,
      'fusionScores': fusionScores,
      'reasoning': reasoning,
      'correctedState': correctedState,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TrainingSample.fromJson(Map<String, dynamic> json) {
    return TrainingSample(
      imageBase64: json['imageBase64'],
      imagePath: json['imagePath'],
      hfPredictedLabel: json['hfPredictedLabel'],
      hfConfidence: json['hfConfidence'] == null
          ? null
          : (json['hfConfidence'] as num).toDouble(),
      hfScores: json['hfScores'] == null
          ? null
          : Map<String, dynamic>.from(json['hfScores']),
      fusionPredictedState: json['fusionPredictedState'],
      fusionConfidence: (json['fusionConfidence'] as num).toDouble(),
      fusionScores: Map<String, dynamic>.from(json['fusionScores']),
      reasoning: List<String>.from(json['reasoning']),
      correctedState: json['correctedState'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}