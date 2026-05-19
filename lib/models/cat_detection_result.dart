import 'cat_cues.dart';

class CatDetectionResult {
  final bool catDetected;
  final double confidence;
  final String message;

  final List<double>? bbox;

  final MovementCue suggestedMovement;
  final EarCue suggestedEars;
  final TailCue suggestedTail;
  final BodyCue suggestedBody;
  final VocalCue suggestedVocal;

  CatDetectionResult({
    required this.catDetected,
    required this.confidence,
    required this.message,
    required this.bbox,
    required this.suggestedMovement,
    required this.suggestedEars,
    required this.suggestedTail,
    required this.suggestedBody,
    required this.suggestedVocal,
  });
}