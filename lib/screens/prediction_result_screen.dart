import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/cat_state.dart';
import '../ui/cat_state_ui.dart';
import '../ui/cattalk_theme.dart';
import 'interaction_goal_screen.dart';

class PredictionResultScreen extends StatelessWidget {
  final Uint8List? imageBytes;
  final CatStateResult result;
  final String advisory;
  final String sourceLabel;
  final String secondaryActionLabel;

  const PredictionResultScreen({
    super.key,
    this.imageBytes,
    required this.result,
    required this.advisory,
    required this.sourceLabel,
    this.secondaryActionLabel = 'Try a different photo',
  });

  String _confidenceLabel(double confidence, bool isMixed) {
    if (isMixed) return 'Mixed visual signals';
    if (confidence >= 0.62) return 'Clear visual match';
    if (confidence >= 0.38) return 'Moderate visual match';
    return 'Mixed visual signals';
  }

  @override
  Widget build(BuildContext context) {
    final state = result.state;
    final color = state.color(context);
    final ranked = result.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final second = ranked.length > 1 ? ranked[1] : null;
    final isMixed =
        second != null &&
        second.value >= 0.16 &&
        (ranked.first.value - second.value) < 0.12;
    final resultLabel = isMixed
        ? '${ranked.first.key.label} or ${second.key.label}'
        : state.label;
    final resultSummary = isMixed
        ? 'The snapshot contains overlapping visual patterns for both states. Treat this as an uncertain estimate and respond to whichever signs you can observe directly.'
        : state.summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Your result')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _ResultHero(
                imageBytes: imageBytes,
                state: state,
                color: color,
                sourceLabel: sourceLabel,
                resultLabel: resultLabel,
                resultSummary: resultSummary,
                confidence: result.confidence,
                confidenceLabel: _confidenceLabel(result.confidence, isMixed),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What shaped this estimate?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...result.reasons.map(
                        (reason) => Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 20,
                                color: color,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: const TextStyle(height: 1.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (ranked.length > 1) ...[
                        const SizedBox(height: 5),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          title: const Text(
                            'See all visual matches',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          children: ranked
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 9),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(entry.key.label)),
                                      Text(
                                        '${(entry.value * 100).round()}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  color: CatTalkColors.warmSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CatTalkColors.warm.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: CatTalkColors.warm,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        advisory,
                        style: const TextStyle(
                          color: CatTalkColors.text,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InteractionGoalScreen(result: result),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Choose what to do next'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(secondaryActionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultHero extends StatelessWidget {
  final Uint8List? imageBytes;
  final CatState state;
  final Color color;
  final String sourceLabel;
  final String resultLabel;
  final String resultSummary;
  final double confidence;
  final String confidenceLabel;

  const _ResultHero({
    required this.imageBytes,
    required this.state,
    required this.color,
    required this.sourceLabel,
    required this.resultLabel,
    required this.resultSummary,
    required this.confidence,
    required this.confidenceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final summary = Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.13), CatTalkColors.cream],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: CatTalkColors.panelRaised,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(state.icon, color: color, size: 30),
          ),
          const SizedBox(height: 18),
          Text(
            sourceLabel.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(resultLabel, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          Text(
            resultSummary,
            style: const TextStyle(
              color: CatTalkColors.mutedInk,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: confidence.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.10),
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(confidence * 100).round()}%',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            confidenceLabel,
            style: const TextStyle(
              color: CatTalkColors.mutedInk,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    final image = imageBytes == null
        ? null
        : ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.memory(
              imageBytes!,
              width: double.infinity,
              height: 320,
              fit: BoxFit.cover,
            ),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (image == null || constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (image != null) ...[image, const SizedBox(height: 14)],
              summary,
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: image),
              const SizedBox(width: 14),
              Expanded(flex: 6, child: summary),
            ],
          ),
        );
      },
    );
  }
}
