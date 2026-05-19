import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../models/cat_cues.dart';
import '../models/cat_detection_result.dart';
import '../services/web_cat_detection_service.dart';
import 'cue_review_screen.dart';

class RealtimeScanScreen extends StatefulWidget {
  const RealtimeScanScreen({super.key});

  @override
  State<RealtimeScanScreen> createState() => _RealtimeScanScreenState();
}

class _RealtimeScanScreenState extends State<RealtimeScanScreen> {
  static const String videoElementId = 'cat-live-video';
  static const String videoViewType = 'cat-live-video-view';

  html.VideoElement? videoElement;
  html.MediaStream? mediaStream;

  CatDetectionResult? detectionResult;
  Timer? detectionTimer;

  bool isCameraStarting = true;
  bool isDetecting = false;
  bool isLiveDetectionRunning = false;
  String? errorMessage;

  double videoOriginalWidth = 640;
  double videoOriginalHeight = 480;

  @override
  void initState() {
    super.initState();
    setupVideoElement();
    startCamera();
  }

  void setupVideoElement() {
    videoElement = html.VideoElement()
      ..id = videoElementId
      ..autoplay = true
      ..muted = true
      ..setAttribute('playsinline', 'true')
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    try {
      ui_web.platformViewRegistry.registerViewFactory(
        videoViewType,
        (int viewId) => videoElement!,
      );
    } catch (_) {
      // View factory may already be registered during hot restart.
    }
  }

  Future<void> startCamera() async {
    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': true,
        'audio': false,
      });

      if (stream == null) {
        setState(() {
          errorMessage = 'Could not access camera stream.';
          isCameraStarting = false;
        });
        return;
      }

      mediaStream = stream;
      videoElement!.srcObject = stream;

      await videoElement!.play();

      await waitForVideoFrame();

      if (!mounted) return;

      setState(() {
        isCameraStarting = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Camera permission/error: $e';
        isCameraStarting = false;
      });
    }
  }

  Future<void> waitForVideoFrame() async {
    for (int i = 0; i < 20; i++) {
      final video = videoElement;

      if (video != null && video.videoWidth > 0 && video.videoHeight > 0) {
        videoOriginalWidth = video.videoWidth.toDouble();
        videoOriginalHeight = video.videoHeight.toDouble();
        return;
      }

      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void toggleLiveDetection() {
    if (isLiveDetectionRunning) {
      detectionTimer?.cancel();
      setState(() {
        isLiveDetectionRunning = false;
      });
      return;
    }

    setState(() {
      isLiveDetectionRunning = true;
    });

    runDetectionOnce();

    detectionTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => runDetectionOnce(),
    );
  }

  Future<void> runDetectionOnce() async {
    if (isDetecting || videoElement == null || isCameraStarting) return;

    final video = videoElement!;

    if (video.videoWidth <= 0 || video.videoHeight <= 0) {
      await waitForVideoFrame();
    }

    if (video.videoWidth <= 0 || video.videoHeight <= 0) {
      setState(() {
        errorMessage = 'Video frame is not ready yet.';
      });
      return;
    }

    videoOriginalWidth = video.videoWidth.toDouble();
    videoOriginalHeight = video.videoHeight.toDouble();

    setState(() {
      isDetecting = true;
      errorMessage = null;
    });

    try {
      final result = await WebCatDetectionService().detectCatFromElementId(
        videoElementId,
      );

      if (!mounted) return;

      setState(() {
        detectionResult = result;
        isDetecting = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDetecting = false;
        errorMessage = 'Detection error: $e';
      });
    }
  }

  void continueToCueReview() {
    final result = detectionResult;

    final suggestedCues = result == null
        ? null
        : CatCues(
            movement: result.suggestedMovement,
            ears: result.suggestedEars,
            tail: result.suggestedTail,
            body: result.suggestedBody,
            vocal: result.suggestedVocal,
          );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CueReviewScreen(
          initialCues: suggestedCues,
        ),
      ),
    );
  }

  String confidenceText(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  @override
  void dispose() {
    detectionTimer?.cancel();

    final tracks = mediaStream?.getTracks() ?? [];
    for (final track in tracks) {
      track.stop();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = detectionResult?.catDetected == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time AI Cat Scan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Live cat detection',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Use your webcam and TensorFlow.js COCO-SSD to detect cats in real time.',
          ),

          const SizedBox(height: 20),

          if (errorMessage != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(errorMessage!),
              ),
            ),

          if (isCameraStarting)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Starting camera...'),
                  ],
                ),
              ),
            ),

          SizedBox(
            height: 360,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const HtmlElementView(
                    viewType: videoViewType,
                  ),
                ),

                if (detectionResult?.bbox != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: LiveBoundingBoxPainter(
                        bbox: detectionResult!.bbox!,
                        originalWidth: videoOriginalWidth,
                        originalHeight: videoOriginalHeight,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Camera ready: ${!isCameraStarting}\n'
                'Video size: ${videoOriginalWidth.toStringAsFixed(0)} x ${videoOriginalHeight.toStringAsFixed(0)}\n'
                'Detecting now: ${isDetecting ? "Yes" : "No"}\n'
                'Live detection: ${isLiveDetectionRunning ? "Running" : "Stopped"}',
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (detectionResult != null)
            Card(
              color: detectionResult!.catDetected
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${detectionResult!.message}\n'
                  'Cat detected: ${detectionResult!.catDetected ? "Yes" : "No"}\n'
                  'Confidence: ${confidenceText(detectionResult!.confidence)}\n'
                  'Bounding box: ${detectionResult!.bbox ?? "Not available"}\n\n'
                  'Suggested cues:\n'
                  'Movement: ${detectionResult!.suggestedMovement.name}\n'
                  'Ears: ${detectionResult!.suggestedEars.name}\n'
                  'Tail: ${detectionResult!.suggestedTail.name}\n'
                  'Body: ${detectionResult!.suggestedBody.name}\n'
                  'Vocal: ${detectionResult!.suggestedVocal.name}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: isCameraStarting ? null : runDetectionOnce,
            child: const Text('Run Detection Now'),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: isCameraStarting ? null : toggleLiveDetection,
            child: Text(
              isLiveDetectionRunning
                  ? 'Stop Live Detection'
                  : 'Start Live Detection',
            ),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: canContinue ? continueToCueReview : null,
            child: const Text('Continue to Cue Review'),
          ),
        ],
      ),
    );
  }
}

class LiveBoundingBoxPainter extends CustomPainter {
  final List<double> bbox;
  final double originalWidth;
  final double originalHeight;

  LiveBoundingBoxPainter({
    required this.bbox,
    required this.originalWidth,
    required this.originalHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bbox.length != 4) return;
    if (originalWidth <= 0 || originalHeight <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.green;

    final labelPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green;

    final sourceX = bbox[0];
    final sourceY = bbox[1];
    final sourceW = bbox[2];
    final sourceH = bbox[3];

    final scaleX = size.width / originalWidth;
    final scaleY = size.height / originalHeight;

    final coverScale = scaleX > scaleY ? scaleX : scaleY;

    final scaledVideoWidth = originalWidth * coverScale;
    final scaledVideoHeight = originalHeight * coverScale;

    final cropOffsetX = (size.width - scaledVideoWidth) / 2;
    final cropOffsetY = (size.height - scaledVideoHeight) / 2;

    final rect = Rect.fromLTWH(
      sourceX * coverScale + cropOffsetX,
      sourceY * coverScale + cropOffsetY,
      sourceW * coverScale,
      sourceH * coverScale,
    );

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(rect, paint);

    final labelTop = rect.top - 28 < 0 ? rect.top : rect.top - 28;

    canvas.drawRect(
      Rect.fromLTWH(rect.left, labelTop, 120, 28),
      labelPaint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'CAT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.left + 8, labelTop + 4),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LiveBoundingBoxPainter oldDelegate) {
    return oldDelegate.bbox != bbox ||
        oldDelegate.originalWidth != originalWidth ||
        oldDelegate.originalHeight != originalHeight;
  }
}