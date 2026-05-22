class VisionFeaturePrediction {
  final bool catDetected;

  final String? imagePath;
  final String? cropPath;

  final List<dynamic>? bbox;
  final double catConfidence;

  final Map<String, dynamic>? features;

  final String predictedState;
  final double confidence;

  final Map<String, dynamic> scores;
  final List<dynamic> reasoning;

  VisionFeaturePrediction({
    required this.catDetected,
    required this.imagePath,
    required this.cropPath,
    required this.bbox,
    required this.catConfidence,
    required this.features,
    required this.predictedState,
    required this.confidence,
    required this.scores,
    required this.reasoning,
  });

  factory VisionFeaturePrediction.fromJson(
    Map<String, dynamic> json,
  ) {
    final prediction = json['prediction'] ?? {};

    return VisionFeaturePrediction(
      catDetected: json['cat_detected'] ?? false,
      imagePath: json['image_path'],
      cropPath: json['crop_path'],
      bbox: json['bbox'],
      catConfidence:
          (json['cat_confidence'] ?? 0).toDouble(),
      features: json['features'] == null
          ? null
          : Map<String, dynamic>.from(
              json['features'],
            ),
      predictedState:
          prediction['predicted_state'] ?? 'unknown',
      confidence:
          (prediction['confidence'] ?? 0).toDouble(),
      scores: prediction['scores'] == null
          ? {}
          : Map<String, dynamic>.from(
              prediction['scores'],
            ),
      reasoning: prediction['reasoning'] ?? [],
    );
  }
}