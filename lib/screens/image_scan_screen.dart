import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/cat_analysis_result.dart';
import '../services/backend_api_service.dart';
import '../ui/cat_state_ui.dart';
import '../ui/cattalk_theme.dart';
import 'prediction_result_screen.dart';

class ImageScanScreen extends StatefulWidget {
  const ImageScanScreen({super.key});

  @override
  State<ImageScanScreen> createState() => _ImageScanScreenState();
}

class _ImageScanScreenState extends State<ImageScanScreen> {
  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  CatAnalysisResult? _analysis;
  bool _analyzing = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 86,
      maxWidth: 1800,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _analysis = null;
      _error = null;
    });
    await _analyze();
  }

  Future<void> _analyze() async {
    final bytes = _imageBytes;
    if (bytes == null || _analyzing) return;

    setState(() {
      _analyzing = true;
      _analysis = null;
      _error = null;
    });

    try {
      final result = await BackendApiService().analyzeCat(bytes);
      if (!mounted) return;
      setState(() => _analysis = result);
    } on BackendApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _continue() {
    final prediction = _analysis?.prediction;
    if (prediction == null || _imageBytes == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PredictionResultScreen(
          imageBytes: _imageBytes,
          result: prediction,
          advisory: _analysis!.advisory,
          sourceLabel: 'Photo analysis',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;
    return Scaffold(
      appBar: AppBar(title: const Text('Photo scan')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            children: [
              Text(
                'Choose a clear moment.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Use a recent photo with the cat in good light. We’ll take it from there.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _ImagePanel(
                imageBytes: _imageBytes,
                analysis: analysis,
                analyzing: _analyzing,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _analyzing
                        ? null
                        : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      _imageBytes == null ? 'Choose a photo' : 'Choose another',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _analyzing
                        ? null
                        : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Use camera'),
                  ),
                  if (_imageBytes != null && !_analyzing)
                    TextButton.icon(
                      onPressed: _analyze,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Analyze again'),
                    ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 18),
                _MessageCard(
                  icon: Icons.cloud_off_outlined,
                  title: 'We couldn’t complete the scan',
                  body: _error!,
                  color: CatTalkColors.danger,
                ),
              ],
              if (analysis != null && !analysis.catDetected) ...[
                const SizedBox(height: 18),
                const _MessageCard(
                  icon: Icons.search_off_rounded,
                  title: 'No cat found in this photo',
                  body:
                      'Try a brighter image with the cat centered and their head and body visible.',
                  color: CatTalkColors.warm,
                ),
              ],
              if (analysis?.prediction != null) ...[
                const SizedBox(height: 18),
                _ReadyCard(analysis: analysis!),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _continue,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('See the full result'),
                ),
              ],
              const SizedBox(height: 22),
              const _PhotoTips(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePanel extends StatelessWidget {
  final Uint8List? imageBytes;
  final CatAnalysisResult? analysis;
  final bool analyzing;

  const _ImagePanel({
    required this.imageBytes,
    required this.analysis,
    required this.analyzing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: CatTalkColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: CatTalkColors.border),
      ),
      child: imageBytes == null
          ? const _EmptyImage()
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(imageBytes!, fit: BoxFit.contain),
                if (analysis?.bbox != null)
                  CustomPaint(
                    painter: _BoundingBoxPainter(
                      bbox: analysis!.bbox!,
                      imageWidth: analysis!.imageWidth,
                      imageHeight: analysis!.imageHeight,
                    ),
                  ),
                if (analyzing)
                  Container(
                    color: Colors.black.withValues(alpha: 0.48),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Looking for visible signals…',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _EmptyImage extends StatelessWidget {
  const _EmptyImage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 62,
            color: CatTalkColors.accent,
          ),
          SizedBox(height: 14),
          Text(
            'Your photo will appear here',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CatTalkColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyCard extends StatelessWidget {
  final CatAnalysisResult analysis;
  const _ReadyCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final state = analysis.prediction!.state;
    final color = state.color(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(state.icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cat found — result ready',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Detection confidence ${(analysis.detectionConfidence * 100).round()}%',
                    style: const TextStyle(color: CatTalkColors.muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(height: 5),
                Text(body, style: const TextStyle(height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTips extends StatelessWidget {
  const _PhotoTips();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Wrap(
          spacing: 22,
          runSpacing: 12,
          children: [
            _Tip(icon: Icons.light_mode_outlined, text: 'Good light'),
            _Tip(
              icon: Icons.center_focus_strong_rounded,
              text: 'Whole cat visible',
            ),
            _Tip(
              icon: Icons.motion_photos_paused_outlined,
              text: 'No motion blur',
            ),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 20, color: CatTalkColors.accent),
      SizedBox(width: 8),
      Text(text, style: TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
}

class _BoundingBoxPainter extends CustomPainter {
  final List<double> bbox;
  final double imageWidth;
  final double imageHeight;

  const _BoundingBoxPainter({
    required this.bbox,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bbox.length != 4 || imageWidth <= 0 || imageHeight <= 0) return;
    final scale = (size.width / imageWidth < size.height / imageHeight)
        ? size.width / imageWidth
        : size.height / imageHeight;
    final drawnWidth = imageWidth * scale;
    final drawnHeight = imageHeight * scale;
    final offsetX = (size.width - drawnWidth) / 2;
    final offsetY = (size.height - drawnHeight) / 2;
    final rect = Rect.fromLTRB(
      offsetX + bbox[0] * scale,
      offsetY + bbox[1] * scale,
      offsetX + bbox[2] * scale,
      offsetY + bbox[3] * scale,
    );
    final paint = Paint()
      ..color = const Color(0xFF8BFFCE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BoundingBoxPainter oldDelegate) =>
      oldDelegate.bbox != bbox ||
      oldDelegate.imageWidth != imageWidth ||
      oldDelegate.imageHeight != imageHeight;
}
