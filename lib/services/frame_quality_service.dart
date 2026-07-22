class FrameQualityService {
  const FrameQualityService._();

  static double calculate({
    required double detectionConfidence,
    required double brightness,
    required double sharpness,
    required double areaRatio,
  }) {
    final brightnessScore = (1 - ((brightness - 0.55).abs() / 0.55)).clamp(
      0.0,
      1.0,
    );
    final areaScore = (areaRatio / 0.35).clamp(0.0, 1.0);
    final sharpnessScore = (sharpness / 0.12).clamp(0.0, 1.0);

    return (detectionConfidence.clamp(0.0, 1.0) * 0.45) +
        (brightnessScore * 0.20) +
        (sharpnessScore * 0.25) +
        (areaScore * 0.10);
  }
}
