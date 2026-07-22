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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFCF8), CatTalkColors.canvas],
            stops: [0, 0.52],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 52),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _TopBar(),
                          const SizedBox(height: 30),
                          _Hero(
                            onScan: () =>
                                _open(context, const ImageScanScreen()),
                            onLive: () =>
                                _open(context, const RealtimeScanScreen()),
                          ),
                          if (AppConfig.isPersonalized) ...[
                            const SizedBox(height: 16),
                            const _BirthdayNote(),
                          ],
                          const SizedBox(height: 54),
                          Text(
                            'A little more understanding.\nA lot more connection.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'One photo becomes a cautious estimate, a practical interaction plan, and an optional sound cue.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 28),
                          const _HowItWorks(),
                          const SizedBox(height: 28),
                          const _PrivacyNote(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 440;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [CatTalkColors.plum, CatTalkColors.deepPlum],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CatTalkColors.plum.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(Icons.pets_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CatTalk', style: Theme.of(context).textTheme.titleLarge),
              if (AppConfig.isPersonalized)
                Text(
                  'A birthday gift for ${AppConfig.recipientName}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CatTalkColors.mutedInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: CatTalkColors.mint,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: CatTalkColors.green,
              ),
              if (!compact) ...[
                const SizedBox(width: 6),
                const Text(
                  'Private by design',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: CatTalkColors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onLive;

  const _Hero({required this.onScan, required this.onLive});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0EAFF), Color(0xFFFFF1E5)],
        ),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: const Color(0xFFE0D5F0)),
        boxShadow: [
          BoxShadow(
            color: CatTalkColors.deepPlum.withValues(alpha: 0.10),
            blurRadius: 46,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final copy = _HeroCopy(onScan: onScan, onLive: onLive);
          const art = _CatArt();
          return Padding(
            padding: EdgeInsets.all(compact ? 26 : 48),
            child: compact
                ? Column(children: [copy, const SizedBox(height: 28), art])
                : Row(
                    children: [
                      Expanded(flex: 6, child: copy),
                      const SizedBox(width: 32),
                      const Expanded(flex: 4, child: _CatArt()),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onLive;

  const _HeroCopy({required this.onScan, required this.onLive});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppConfig.isPersonalized
              ? '${AppConfig.giftOccasion.toUpperCase()}, ${AppConfig.recipientName.toUpperCase()}!'
              : 'A GENTLER WAY TO CONNECT',
          style: const TextStyle(
            color: CatTalkColors.plum,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          AppConfig.isPersonalized
              ? '${AppConfig.recipientName}, meet your cat where they are.'
              : 'Meet your cat where they are.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 18),
        Text(
          'A thoughtful little companion for reading visible signals and choosing a kind next step — in under a minute.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: CatTalkColors.mutedInk,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, constraints) {
            final stack = constraints.maxWidth < 470;
            final scan = FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Scan a photo'),
            );
            final live = OutlinedButton.icon(
              onPressed: onLive,
              icon: const Icon(Icons.videocam_outlined),
              label: const Text('Use live camera'),
            );
            if (stack) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [scan, const SizedBox(height: 10), live],
              );
            }
            return Wrap(spacing: 12, runSpacing: 12, children: [scan, live]);
          },
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _QuietPromise(icon: Icons.bolt_rounded, text: 'Quick'),
            _QuietPromise(icon: Icons.lock_rounded, text: 'No account'),
            _QuietPromise(icon: Icons.favorite_rounded, text: 'Cat-first'),
          ],
        ),
      ],
    );
  }
}

class _QuietPromise extends StatelessWidget {
  final IconData icon;
  final String text;
  const _QuietPromise({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: CatTalkColors.deepPlum),
      const SizedBox(width: 5),
      Text(
        text,
        style: const TextStyle(
          color: CatTalkColors.deepPlum,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _BirthdayNote extends StatelessWidget {
  const _BirthdayNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: CatTalkColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CatTalkColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: CatTalkColors.peach,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cake_rounded,
              color: Color(0xFF9A512F),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'For ${AppConfig.recipientName} — wishing you more purrs, playful moments, and wonderfully cat-filled days.',
              style: const TextStyle(
                color: CatTalkColors.mutedInk,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFE58D4B)),
        ],
      ),
    );
  }
}

class _CatArt extends StatelessWidget {
  const _CatArt();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CustomPaint(painter: _CatPortraitPainter()),
              ),
            ),
            const Positioned(right: 20, top: 22, child: _Sparkle()),
            const Positioned(
              left: 24,
              bottom: 26,
              child: _Sparkle(small: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatPortraitPainter extends CustomPainter {
  const _CatPortraitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.53);
    final radius = size.shortestSide * 0.30;
    final halo = Paint()..color = CatTalkColors.peach;
    canvas.drawCircle(center, size.shortestSide * 0.38, halo);

    final cat = Paint()..color = CatTalkColors.plum;
    final leftEar = Path()
      ..moveTo(center.dx - radius * 0.82, center.dy - radius * 0.55)
      ..lineTo(center.dx - radius * 0.60, center.dy - radius * 1.42)
      ..lineTo(center.dx - radius * 0.08, center.dy - radius * 0.78)
      ..close();
    final rightEar = Path()
      ..moveTo(center.dx + radius * 0.82, center.dy - radius * 0.55)
      ..lineTo(center.dx + radius * 0.60, center.dy - radius * 1.42)
      ..lineTo(center.dx + radius * 0.08, center.dy - radius * 0.78)
      ..close();
    canvas.drawPath(leftEar, cat);
    canvas.drawPath(rightEar, cat);
    canvas.drawCircle(center, radius, cat);

    final face = Paint()
      ..color = Colors.white
      ..strokeWidth = radius * 0.10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.34, center.dy - radius * 0.12),
      radius * 0.07,
      face,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.34, center.dy - radius * 0.12),
      radius * 0.07,
      face,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.17, center.dy + radius * 0.23),
      Offset(center.dx, center.dy + radius * 0.34),
      face,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.17, center.dy + radius * 0.23),
      Offset(center.dx, center.dy + radius * 0.34),
      face,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Sparkle extends StatelessWidget {
  final bool small;
  const _Sparkle({this.small = false});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.auto_awesome_rounded,
    size: small ? 24 : 34,
    color: const Color(0xFFE58D4B),
  );
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.photo_camera_outlined,
        '1. Share a clear photo',
        'A side or front view in good light works best.',
      ),
      (
        Icons.psychology_alt_outlined,
        '2. Read the visible state',
        'We detect the cat and compare broad visual patterns.',
      ),
      (
        Icons.waving_hand_outlined,
        '3. Interact gently',
        'Choose your goal and follow a state-aware suggestion.',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 760;
        final cards = items
            .map(
              (item) => Expanded(
                child: _InfoCard(icon: item.$1, title: item.$2, body: item.$3),
              ),
            )
            .toList();
        if (vertical) {
          return Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InfoCard(
                      icon: item.$1,
                      title: item.$2,
                      body: item.$3,
                    ),
                  ),
                )
                .toList(),
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withGaps(cards),
          ),
        );
      },
    );
  }

  List<Widget> _withGaps(List<Widget> children) {
    final result = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) result.add(const SizedBox(width: 14));
      result.add(children[index]);
    }
    return result;
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: CatTalkColors.lilac,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: CatTalkColors.plum),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              body,
              style: const TextStyle(
                height: 1.45,
                color: CatTalkColors.mutedInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CatTalkColors.mint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: CatTalkColors.green),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Your image is processed for this result and is not saved by CatTalk. No account, behavioral history, or feedback collection required.',
              style: TextStyle(
                color: CatTalkColors.green,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
