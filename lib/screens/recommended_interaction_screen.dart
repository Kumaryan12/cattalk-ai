import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cat_sound.dart';
import '../models/cat_state.dart';
import '../services/audio_service.dart';
import '../services/sound_library_service.dart';
import '../ui/cat_state_ui.dart';
import '../ui/cattalk_theme.dart';
import 'interaction_goal_screen.dart';

class RecommendedInteractionScreen extends StatefulWidget {
  final CatStateResult result;
  final UserGoal goal;
  const RecommendedInteractionScreen({
    super.key,
    required this.result,
    required this.goal,
  });

  @override
  State<RecommendedInteractionScreen> createState() =>
      _RecommendedInteractionScreenState();
}

class _RecommendedInteractionScreenState
    extends State<RecommendedInteractionScreen> {
  final _audio = AudioService();
  StreamSubscription<void>? _completionSubscription;
  bool _playing = false;
  String? _soundError;
  double _volume = 0.35;

  @override
  void initState() {
    super.initState();
    _completionSubscription = _audio.onComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
    unawaited(_prepareSound());
  }

  CatSound _sound() {
    final sounds = SoundLibraryService().getAllSounds();
    final state = widget.result.state;
    if (state == CatState.defensiveStressed ||
        state == CatState.alertCautious) {
      return sounds.firstWhere(
        (sound) =>
            sound.id ==
            (widget.goal == UserGoal.calmCat
                ? 'calm_purr_01'
                : 'soft_trill_01'),
      );
    }
    switch (widget.goal) {
      case UserGoal.playWithCat:
        return sounds.firstWhere((sound) => sound.id == 'play_chirp_01');
      case UserGoal.callCat:
      case UserGoal.getAttention:
        return sounds.firstWhere((sound) => sound.id == 'short_meow_01');
      case UserGoal.calmCat:
        return sounds.firstWhere((sound) => sound.id == 'calm_purr_01');
      case UserGoal.buildTrust:
        return sounds.firstWhere((sound) => sound.id == 'soft_trill_01');
    }
  }

  List<String> _steps() {
    final state = widget.result.state;
    if (state == CatState.defensiveStressed) {
      return [
        'Create distance and leave a clear exit path.',
        'Lower your body, look slightly away, and keep hands still.',
        'If you use the sound, play it once at low volume.',
        'Stop immediately if the cat retreats, hisses, or stiffens.',
      ];
    }
    if (state == CatState.alertCautious) {
      return [
        'Pause and let the cat observe you first.',
        'Move slowly and avoid leaning over them.',
        'Play the sound once, then wait quietly.',
        'Let the cat decide whether to approach.',
      ];
    }
    if (state == CatState.playfulActive &&
        widget.goal == UserGoal.playWithCat) {
      return [
        'Prepare a wand or toss toy before playing the cue.',
        'Play the sound once to begin the routine.',
        'Keep the session short and let the cat catch the toy.',
        'Finish with a calm pause rather than abrupt handling.',
      ];
    }
    return [
      'Approach slowly from the side.',
      'Play the sound once at a comfortable volume.',
      'Wait several seconds instead of repeating it.',
      'Continue only if the cat stays loose and chooses to engage.',
    ];
  }

  Future<void> _prepareSound() async {
    if (mounted) {
      setState(() => _soundError = null);
    }

    try {
      await _audio.prepareSound(_sound().assetName, volume: _volume);
    } catch (_) {
      if (mounted) {
        setState(() {
          _playing = false;
          _soundError =
              'The sound could not be prepared. Check your connection and try again.';
        });
      }
    }
  }

  Future<void> _toggleSound() async {
    if (_playing) {
      await _audio.stopSound();
      if (mounted) setState(() => _playing = false);
      return;
    }

    // Start playback immediately, while the mobile browser still considers
    // this call part of the user's tap. Do not await any setup before it.
    final playback = _audio.resumeSound();
    if (mounted) {
      setState(() {
        _playing = true;
        _soundError = null;
      });
    }
    try {
      await playback;
    } catch (_) {
      if (mounted) {
        setState(() {
          _playing = false;
          _soundError =
              'Your browser blocked the sound. Tap “Try loading sound again”, then play it once.';
        });
      }
    }
  }

  @override
  void dispose() {
    _completionSubscription?.cancel();
    _audio.stopSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sound = _sound();
    final state = widget.result.state;
    final color = state.color(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Interaction plan')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.16),
                      CatTalkColors.panel,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: color.withValues(alpha: 0.16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.goal.label.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Keep it gentle.\nLet your cat choose.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This plan is tuned for a cat that appears ${state.label.toLowerCase()}.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: CatTalkColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Try this',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._steps().asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${entry.key + 1}',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(height: 1.4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: CatTalkColors.lilac,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.graphic_eq_rounded,
                              color: CatTalkColors.plum,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sound.displayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '${sound.energy} energy · ${sound.bestFor}',
                                  style: const TextStyle(
                                    color: CatTalkColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Icon(
                            Icons.volume_down_rounded,
                            color: CatTalkColors.mutedInk,
                          ),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              min: 0.15,
                              max: 0.60,
                              divisions: 9,
                              label: '${(_volume * 100).round()}%',
                              onChanged: _playing
                                  ? null
                                  : (value) {
                                      setState(() => _volume = value);
                                      unawaited(_audio.setVolume(value));
                                    },
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              '${(_volume * 100).round()}%',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: CatTalkColors.mutedInk,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _toggleSound,
                          icon: Icon(
                            _playing
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            _playing ? 'Stop sound' : 'Play once at low volume',
                          ),
                        ),
                      ),
                      if (_soundError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _soundError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: CatTalkColors.mutedInk,
                          ),
                        ),
                        Center(
                          child: TextButton.icon(
                            onPressed: _prepareSound,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try loading sound again'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          _playing
                              ? 'Playing once — watch your cat, and stop if they seem uncomfortable.'
                              : 'The sound stops automatically. Never use it to corner or repeatedly call the cat.',
                          key: ValueKey(_playing),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: CatTalkColors.mutedInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () {
                  _audio.stopSound();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Start a new scan'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Choose a different goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
