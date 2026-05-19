import '../models/cat_cues.dart';
import '../models/cat_state.dart';

class CatStateEngine {
  CatStateResult predict(CatCues cues) {
    final scores = <CatState, double>{
      CatState.relaxed: 0,
      CatState.exploratorySocial: 0,
      CatState.alertCautious: 0,
      CatState.playfulActive: 0,
      CatState.defensiveStressed: 0,
      CatState.attentionSeeking: 0,
      CatState.unknown: 0,
    };

    final reasons = <String>[];

    if (cues.body == BodyCue.relaxed) {
      scores[CatState.relaxed] = scores[CatState.relaxed]! + 2;
      reasons.add('Relaxed body posture increased relaxed score.');
    }

    if (cues.movement == MovementCue.still) {
      scores[CatState.relaxed] = scores[CatState.relaxed]! + 1;
      scores[CatState.alertCautious] = scores[CatState.alertCautious]! + 0.5;
      reasons.add('Still posture can indicate calmness or cautious observation.');
    }

    if (cues.vocal == VocalCue.purr) {
      scores[CatState.relaxed] = scores[CatState.relaxed]! + 2;
      reasons.add('Purring increased relaxed score.');
    }

    if (cues.movement == MovementCue.approaching) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 2;
      scores[CatState.attentionSeeking] =
          scores[CatState.attentionSeeking]! + 1;
      reasons.add('Approaching increased exploratory/social and attention-seeking scores.');
    }

    if (cues.ears == EarCue.forward) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 1.5;
      scores[CatState.alertCautious] = scores[CatState.alertCautious]! + 0.5;
      reasons.add('Forward ears suggested curiosity or alert attention.');
    }

    if (cues.tail == TailCue.up) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 1.5;
      reasons.add('Tail-up posture increased exploratory/social score.');
    }

    if (cues.vocal == VocalCue.softMeow) {
      scores[CatState.exploratorySocial] =
          scores[CatState.exploratorySocial]! + 1;
      reasons.add('Soft meow increased exploratory/social score.');
    }

    if (cues.movement == MovementCue.active) {
      scores[CatState.playfulActive] =
          scores[CatState.playfulActive]! + 2;
      reasons.add('Active movement increased playful/active score.');
    }

    if (cues.body == BodyCue.playful) {
      scores[CatState.playfulActive] =
          scores[CatState.playfulActive]! + 2;
      reasons.add('Playful body posture increased playful/active score.');
    }

    if (cues.tail == TailCue.twitching) {
      scores[CatState.playfulActive] =
          scores[CatState.playfulActive]! + 1;
      scores[CatState.alertCautious] = scores[CatState.alertCautious]! + 0.8;
      reasons.add('Tail twitching increased playful/active and alert/cautious scores.');
    }

    if (cues.ears == EarCue.backward) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 2;
      scores[CatState.alertCautious] = scores[CatState.alertCautious]! + 1;
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
          scores[CatState.defensiveStressed]! + 2;
      reasons.add('Puffed tail increased defensive/stressed score.');
    }

    if (cues.vocal == VocalCue.hissGrowl) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 3;
      reasons.add('Hiss or growl strongly increased defensive/stressed score.');
    }

    if (cues.movement == MovementCue.movingAway) {
      scores[CatState.defensiveStressed] =
          scores[CatState.defensiveStressed]! + 1.5;
      scores[CatState.alertCautious] = scores[CatState.alertCautious]! + 1;
      reasons.add('Moving away increased defensive/stressed and alert/cautious scores.');
    }

    if (cues.vocal == VocalCue.repeatedMeow) {
      scores[CatState.attentionSeeking] =
          scores[CatState.attentionSeeking]! + 2;
      reasons.add('Repeated meowing increased attention-seeking score.');
    }

    final total = scores.values.fold<double>(0, (sum, value) => sum + value);

    if (total == 0) {
      return CatStateResult(
        state: CatState.unknown,
        confidence: 0,
        scores: scores,
        reasons: const [
          'Not enough cues were available to make a reliable prediction.',
        ],
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
      reasons: reasons,
    );
  }
}