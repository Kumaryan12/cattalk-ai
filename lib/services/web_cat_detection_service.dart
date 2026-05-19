import 'dart:js_interop';

import '../models/cat_cues.dart';
import '../models/cat_detection_result.dart';

@JS('detectCatFromImageElement')
external JSPromise<JSAny?> _detectCatFromImageElement(JSString imageElementId);

extension type CatDetectionJsResult(JSObject _) implements JSObject {
  external bool get catDetected;
  external double get confidence;
  external String get message;
  external JSArray<JSNumber>? get bbox;
}

class WebCatDetectionService {
  Future<CatDetectionResult> detectCatFromElementId(String imageElementId) async {
    final jsResult = await _detectCatFromImageElement(
      imageElementId.toJS,
    ).toDart;

    if (jsResult == null) {
      return CatDetectionResult(
        catDetected: false,
        confidence: 0,
        message: 'No result returned from JS detector.',
        bbox: null,
        suggestedMovement: MovementCue.unknown,
        suggestedEars: EarCue.unknown,
        suggestedTail: TailCue.unknown,
        suggestedBody: BodyCue.unknown,
        suggestedVocal: VocalCue.unknown,
      );
    }

    final result = CatDetectionJsResult(jsResult as JSObject);

    List<double>? parsedBbox;

    final rawBbox = result.bbox;
    if (rawBbox != null) {
      parsedBbox = rawBbox.toDart
          .map((value) => value.toDartDouble)
          .toList();
    }

    return CatDetectionResult(
      catDetected: result.catDetected,
      confidence: result.confidence,
      message: result.message,
      bbox: parsedBbox,
      suggestedMovement: MovementCue.still,
      suggestedEars: EarCue.neutral,
      suggestedTail: TailCue.neutral,
      suggestedBody: BodyCue.relaxed,
      suggestedVocal: VocalCue.unknown,
    );
  }
}