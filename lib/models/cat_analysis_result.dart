import 'cat_state.dart';

class CatAnalysisResult {
  final bool catDetected;
  final double detectionConfidence;
  final List<double>? bbox;
  final double imageWidth;
  final double imageHeight;
  final CatStateResult? prediction;
  final String advisory;

  const CatAnalysisResult({
    required this.catDetected,
    required this.detectionConfidence,
    required this.bbox,
    required this.imageWidth,
    required this.imageHeight,
    required this.prediction,
    required this.advisory,
  });

  factory CatAnalysisResult.fromJson(Map<String, dynamic> json) {
    final rawPrediction = json['prediction'] as Map<String, dynamic>?;
    final rawScores = rawPrediction?['scores'] as Map<String, dynamic>? ?? {};

    return CatAnalysisResult(
      catDetected: json['cat_detected'] == true,
      detectionConfidence: (json['detection_confidence'] as num? ?? 0)
          .toDouble(),
      bbox: (json['bbox'] as List<dynamic>?)
          ?.map((value) => (value as num).toDouble())
          .toList(),
      imageWidth: (json['image_width'] as num? ?? 1).toDouble(),
      imageHeight: (json['image_height'] as num? ?? 1).toDouble(),
      prediction: rawPrediction == null
          ? null
          : CatStateResult(
              state: catStateFromApi(rawPrediction['state'] as String?),
              confidence: (rawPrediction['confidence'] as num? ?? 0).toDouble(),
              scores: {
                for (final entry in rawScores.entries)
                  catStateFromApi(entry.key): (entry.value as num).toDouble(),
              },
              reasons: List<String>.from(
                rawPrediction['reasons'] as List<dynamic>? ?? const [],
              ),
            ),
      advisory:
          json['advisory'] as String? ??
          'This is a visual estimate, not a diagnosis.',
    );
  }
}

CatState catStateFromApi(String? value) {
  switch (value) {
    case 'relaxed':
      return CatState.relaxed;
    case 'exploratory_social':
      return CatState.exploratorySocial;
    case 'alert_cautious':
      return CatState.alertCautious;
    case 'playful_active':
      return CatState.playfulActive;
    case 'defensive_stressed':
      return CatState.defensiveStressed;
    case 'attention_seeking':
      return CatState.attentionSeeking;
    default:
      return CatState.unknown;
  }
}
