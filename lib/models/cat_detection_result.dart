class CatDetectionResult {
  final bool catDetected;
  final double confidence;
  final String message;

  final List<double>? bbox;

  CatDetectionResult({
    required this.catDetected,
    required this.confidence,
    required this.message,
    required this.bbox,
  });
}
