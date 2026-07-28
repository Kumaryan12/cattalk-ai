import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../ui/cattalk_theme.dart';
import 'image_scan_screen.dart';
import 'realtime_scan_screen_stub.dart'
    if (dart.library.html) 'realtime_scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Navigation(),
                        const SizedBox(height: 34),
                        _EditorialHero(
                          onLive: () =>
                              _open(context, const RealtimeScanScreen()),
                          onPhoto: () =>
                              _open(context, const ImageScanScreen()),
                        ),
                        const SizedBox(height: 72),
                        const _Process(),
                        const SizedBox(height: 58),
                        const _Footer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Row(
      children: [
        Text(
          'CatTalk',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            compact
                ? 'PRIVATE · NO ACCOUNT'
                : 'VISIBLE BEHAVIOUR · GENTLE RESPONSE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: CatTalkColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditorialHero extends StatelessWidget {
  final VoidCallback onLive;
  final VoidCallback onPhoto;

  const _EditorialHero({required this.onLive, required this.onPhoto});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Portrait(height: 430),
              const SizedBox(height: 34),
              _HeroCopy(onLive: onLive, onPhoto: onPhoto),
            ],
          );
        }
        return SizedBox(
          height: 720,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 64, bottom: 24),
                  child: _HeroCopy(onLive: onLive, onPhoto: onPhoto),
                ),
              ),
              const Expanded(flex: 6, child: _Portrait()),
            ],
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final VoidCallback onLive;
  final VoidCallback onPhoto;

  const _HeroCopy({required this.onLive, required this.onPhoto});

  @override
  Widget build(BuildContext context) {
    final name = AppConfig.recipientName.trim().isEmpty
        ? 'there'
        : AppConfig.recipientName.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'HI, ${name.toUpperCase()}',
          style: const TextStyle(
            color: CatTalkColors.accentStrong,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Listen with\nyour eyes.',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 28),
        Text(
          'Cats rarely announce what they need. Start with a clear moment, notice the visible cues, then choose a response that leaves room for their choice.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: CatTalkColors.muted,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 34),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onLive,
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Open the camera',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_outward_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onPhoto,
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Use an existing photo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.photo_outlined, size: 19),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Portrait extends StatelessWidget {
  final double? height;

  const _Portrait({this.height});

  @override
  Widget build(BuildContext context) {
    final image = Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/cat-portrait-pexels-osman-arabaci.jpg',
          ),
          fit: BoxFit.cover,
          alignment: Alignment(0.1, 0.52),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              color: CatTalkColors.background.withValues(alpha: 0.78),
              child: const Text(
                'OBSERVE · DON’T ASSUME',
                style: TextStyle(
                  color: CatTalkColors.text,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.25,
                ),
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 12,
            child: Text(
              'Photo: Osman Arabacı / Pexels',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.64),
                fontSize: 9,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
    if (height != null) return image;
    return SizedBox.expand(child: image);
  }
}

class _Process extends StatelessWidget {
  const _Process();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        '01',
        'Catch the moment',
        'Live camera or a recent photo. Clear light and a full view work best.',
      ),
      (
        '02',
        'Read the posture',
        'See a cautious interpretation of the broad visual signals.',
      ),
      (
        '03',
        'Leave them a choice',
        'Choose a practical next move, with an optional sound played once.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                'A quieter way to connect.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const Text(
              'HOW IT WORKS',
              style: TextStyle(
                color: CatTalkColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            if (compact) {
              return Column(
                children: [
                  for (final step in steps)
                    _Step(number: step.$1, title: step.$2, body: step.$3),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < steps.length; index++) ...[
                  Expanded(
                    child: _Step(
                      number: steps[index].$1,
                      title: steps[index].$2,
                      body: steps[index].$3,
                      showBorder: false,
                    ),
                  ),
                  if (index < steps.length - 1)
                    const SizedBox(
                      height: 145,
                      child: VerticalDivider(width: 42),
                    ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final bool showBorder;

  const _Step({
    required this.number,
    required this.title,
    required this.body,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(bottom: BorderSide(color: CatTalkColors.border))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              number,
              style: const TextStyle(
                color: CatTalkColors.accentStrong,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    color: CatTalkColors.muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 620;
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 18),
        if (compact)
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Images are used only for the current result and are not saved.',
                style: TextStyle(
                  color: CatTalkColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Visual guidance, not veterinary advice.',
                style: TextStyle(
                  color: CatTalkColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          )
        else
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Images are used only for the current result and are not saved.',
                  style: TextStyle(
                    color: CatTalkColors.muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(width: 24),
              Text(
                'Visual guidance, not veterinary advice.',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: CatTalkColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
