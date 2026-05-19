import '../models/backend_prediction.dart';
import '../models/cat_cues.dart';
import '../models/cat_state.dart';

class MoodFusionEngine {
  CatStateResult predict({
    required CatCues cues,
    BackendPrediction? backendPrediction,
  }) {
    final scores = <CatState, double>{
      CatState.relaxed: 0,
      CatState.exploratorySocial: 0,
      CatState.playfulActive: 0,
      CatState.alertCautious: 0,
      CatState.defensiveStressed: 0,
      CatState.attentionSeeking: 0,
      CatState.unknown: 0,
    };

    final reasons = <String>[];

    // Visual cue rules
    if (cues.body == BodyCue.relaxed) {
      scores[CatState.relaxed] = scores[CatState.relaxed]! + 2.5;
      reasons.add('Relaxed body posture increased the relaxed score.');
    }

    if (cues.movement == MovementCue.still) {
      scores[CatState.relaxed] = scores[CatState.relaxed]! + 0.8;
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 0.6;
      scores[CatState.alertCautious] = scores[CatState.alertCautious]! + 0.5;
      reasons.add('Still posture can indicate calmness, observation, or cautious alertness.');
    }

    if (cues.movement == MovementCue.approaching) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 2;
      scores[CatState.attentionSeeking] =
          scores[CatState.attentionSeeking]! + 1;
      reasons.add('Approaching behavior increased exploratory/social and attention-seeking scores.');
    }

    if (cues.ears == EarCue.forward || cues.ears == EarCue.neutral) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 1.5;
      scores[CatState.alertCautious] = scores[CatState.alertCautious]! + 0.8;
      reasons.add('Forward or neutral ears suggested curiosity or alert observation.');
    }

    if (cues.tail == TailCue.up) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 1.5;
      reasons.add('Tail-up posture increased exploratory/social score.');
    }

    if (cues.tail == TailCue.twitching) {
      scores[CatState.playfulActive] =
          scores[CatState.playfulActive]! + 1.2;
      scores[CatState.alertCautious] = scores[CatState.alertCautious]! + 0.8;
      reasons.add('Tail twitching increased playful/active and alert/cautious scores.');
    }

    if (cues.ears == EarCue.backward) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 2;
      scores[CatState.alertCautious] = scores[CatState.alertCautious]! + 1.2;
      reasons.add('Backward ears increased defensive/stressed and alert/cautious scores.');
    }

    if (cues.body == BodyCue.crouched || cues.body == BodyCue.tense) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 2;
      scores[CatState.alertCautious] = scores[CatState.alertCautious]! + 1.5;
      reasons.add('Crouched or tense body posture increased defensive/stressed and alert/cautious scores.');
    }

    if (cues.tail == TailCue.puffed) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 3;
      reasons.add('Puffed tail strongly increased defensive/stressed score.');
    }

    if (cues.vocal == VocalCue.hissGrowl) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 3;
      reasons.add('Hiss or growl strongly increased defensive/stressed score.');
    }

    if (cues.vocal == VocalCue.repeatedMeow) {
      scores[CatState.attentionSeeking] =
          scores[CatState.attentionSeeking]! + 2;
      reasons.add('Repeated meowing increased attention-seeking score.');
    }

    // Hugging Face weak signal
    final prediction = backendPrediction;
    if (prediction != null) {
      for (final entry in prediction.scores.entries) {
        final label = entry.key.toString().toLowerCase();
        final value = (entry.value as num).toDouble();

        // Keep HF influence weaker than interpretable cues.
        final weighted = value * 1.5;
        if (value > 0.15) {
          reasons.add('Hugging Face weak signal: "$label" scored ${(value * 100).toStringAsFixed(1)}%.');
        }

        if (label.contains('relaxed') || label.contains('calm')) {
          scores[CatState.relaxed] = scores[CatState.relaxed]! + weighted;
        } else if (label.contains('curious') ||
            label.contains('exploratory')) {
          scores[CatState.exploratorySocial] =
              scores[CatState.exploratorySocial]! + weighted;
        } else if (label.contains('playful') ||
            label.contains('active')) {
          scores[CatState.playfulActive] =
              scores[CatState.playfulActive]! + weighted;
        } else if (label.contains('attention')) {
          scores[CatState.attentionSeeking] =
              scores[CatState.attentionSeeking]! + weighted;
        } else if (label.contains('stressed') ||
            label.contains('anxious') ||
            label.contains('defensive') ||
            label.contains('aggressive')) {
          scores[CatState.defensiveStressed] =
              scores[CatState.defensiveStressed]! + weighted;
          scores[CatState.alertCautious] =
              scores[CatState.alertCautious]! + weighted * 0.6;
        }
      }
    }

    // Anti-false-aggression correction
    final hasStrongAggressionCue =
        cues.ears == EarCue.backward ||
        cues.tail == TailCue.puffed ||
        cues.body == BodyCue.tense ||
        cues.body == BodyCue.crouched ||
        cues.vocal == VocalCue.hissGrowl;

    if (!hasStrongAggressionCue) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! * 0.45;
      reasons.add('No strong aggression cue was found, so defensive/stressed score was reduced.');
    } else {
      reasons.add('Strong aggression/stress cues were present, so defensive/stressed score was preserved.');
    }

    final total = scores.values.fold<double>(0, (sum, value) => sum + value);

    if (total == 0) {
      return CatStateResult(
        state: CatState.unknown,
        confidence: 0,
        scores: scores,
        reasons: const ['Not enough cues were available to make a reliable prediction.'],
      );
    }

    final normalized = scores.map(
      (state, score) => MapEntry(state, score / total),
    );

    final best = normalized.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );

    return CatStateResult(
      state: best.key,
      confidence: best.value,
      scores: normalized,
      reasons: reasons,
    );
  }
}