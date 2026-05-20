import 'cat_state.dart';
import 'interaction_feedback.dart';

class InteractionLog {
  final String id;
  final DateTime timestamp;

  final CatState predictedState;
  final CatState finalState;
  final double stateConfidence;

  final InteractionCommand command;
  final String goal;
  final String soundUsed;

  final CatReaction reaction;
  final InteractionOutcome outcome;

  InteractionLog({
    required this.id,
    required this.timestamp,
    required this.predictedState,
    required this.finalState,
    required this.stateConfidence,
    required this.command,
    required this.goal,
    required this.soundUsed,
    required this.reaction,
    required this.outcome,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'predictedState': predictedState.name,
      'finalState': finalState.name,
      'stateConfidence': stateConfidence,
      'command': command.name,
      'goal': goal,
      'soundUsed': soundUsed,
      'reaction': reaction.name,
      'outcome': outcome.name,
    };
  }
}