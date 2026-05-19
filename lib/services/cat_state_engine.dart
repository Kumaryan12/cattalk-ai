import '../models/cat_cues.dart';
import '../models/cat_state.dart';

class CatStateEngine {
  CatStateResult predict(CatCues cues) {
    final scores = <CatState, double>{
      CatState.relaxed: 0,
      CatState.exploratorySocial: 0,
      CatState.playfulActive: 0,
      CatState.defensiveStressed: 0,
      CatState.attentionSeeking: 0,
      CatState.unknown: 0,
    };

    if (cues.body == BodyCue.relaxed) {
      scores[CatState.relaxed] = scores[CatState.relaxed]! + 2;
    }

    if (cues.movement == MovementCue.still) {
      scores[CatState.relaxed] = scores[CatState.relaxed]! + 1;
    }

    if (cues.vocal == VocalCue.purr) {
      scores[CatState.relaxed] = scores[CatState.relaxed]! + 2;
    }

    if (cues.movement == MovementCue.approaching) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 2;
    }

    if (cues.ears == EarCue.forward) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 1.5;
    }

    if (cues.tail == TailCue.up) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 1.5;
    }

    if (cues.vocal == VocalCue.softMeow) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 1;
    }

    if (cues.movement == MovementCue.active) {
      scores[CatState.playfulActive] =
          scores[CatState.playfulActive]! + 2;
    }

    if (cues.body == BodyCue.playful) {
      scores[CatState.playfulActive] =
          scores[CatState.playfulActive]! + 2;
    }

    if (cues.tail == TailCue.twitching) {
      scores[CatState.playfulActive] =
          scores[CatState.playfulActive]! + 1;
    }

    if (cues.ears == EarCue.backward) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 2;
    }

    if (cues.body == BodyCue.crouched || cues.body == BodyCue.tense) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 2;
    }

    if (cues.tail == TailCue.puffed) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 2;
    }

    if (cues.vocal == VocalCue.hissGrowl) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 3;
    }

    if (cues.movement == MovementCue.movingAway) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 1.5;
    }

    if (cues.vocal == VocalCue.repeatedMeow) {
      scores[CatState.attentionSeeking] =
          scores[CatState.attentionSeeking]! + 2;
    }

    if (cues.movement == MovementCue.approaching) {
      scores[CatState.attentionSeeking] =
          scores[CatState.attentionSeeking]! + 1;
    }

    final total = scores.values.fold<double>(0, (sum, value) => sum + value);

    if (total == 0) {
      return CatStateResult(
        state: CatState.unknown,
        confidence: 0,
        scores: scores,
      );
    }

    final normalizedScores = scores.map(
      (state, score) => MapEntry(state, score / total),
    );

    final bestEntry = normalizedScores.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );

    return CatStateResult(
      state: bestEntry.key,
      confidence: bestEntry.value,
      scores: normalizedScores,
    );
  }
}