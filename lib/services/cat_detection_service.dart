import 'dart:typed_data';

import '../models/cat_cues.dart';
import '../models/cat_detection_result.dart';

class CatDetectionService {
  Future<CatDetectionResult> detectCat(Uint8List imageBytes) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (imageBytes.isEmpty) {
      return CatDetectionResult(
        bbox:null,
        catDetected: false,
        confidence: 0,
        message: 'No image data found.',
        suggestedMovement: MovementCue.unknown,
        suggestedEars: EarCue.unknown,
        suggestedTail: TailCue.unknown,
        suggestedBody: BodyCue.unknown,
        suggestedVocal: VocalCue.unknown,
      );
    }

    return CatDetectionResult(
      catDetected: true,
      bbox:null,
      confidence: 0.78,
      message: 'Mock cue detection: cat likely present. Suggested cues generated.',
      suggestedMovement: MovementCue.still,
      suggestedEars: EarCue.neutral,
      suggestedTail: TailCue.neutral,
      suggestedBody: BodyCue.relaxed,
      suggestedVocal: VocalCue.unknown,
    );
  }
}