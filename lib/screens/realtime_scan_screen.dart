// Web-only camera surface. The rest of CatTalk stays platform-neutral.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../models/cat_detection_result.dart';
import '../services/backend_api_service.dart';
import '../services/frame_quality_service.dart';
import '../services/web_cat_detection_service.dart';
import '../ui/cattalk_theme.dart';
import 'automatic_cue_analysis_screen.dart';

class RealtimeScanScreen extends StatefulWidget {
  const RealtimeScanScreen({super.key});

  @override
  State<RealtimeScanScreen> createState() => _RealtimeScanScreenState();
}

class _RealtimeScanScreenState extends State<RealtimeScanScreen> {
  static const String videoElementId = 'cat-live-video';
  static const String videoViewType = 'cat-live-video-view';
  static const Duration bestFrameLifetime = Duration(seconds: 15);

  html.VideoElement? videoElement;
  html.MediaStream? mediaStream;

  CatDetectionResult? detectionResult;
  _CapturedCatFrame? bestFrame;
  Timer? detectionTimer;

  bool isCheckingBackend = true;
  bool isBackendReady = false;
  bool isCameraStarting = false;
  bool isDetecting = false;
  bool isLiveDetectionRunning = false;
  String? errorMessage;
  String? readinessError;

  double videoOriginalWidth = 640;
  double videoOriginalHeight = 480;

  @override
  void initState() {
    super.initState();
    setupVideoElement();
    unawaited(prepareLiveExperience());
  }

  Future<void> prepareLiveExperience() async {
    stopCameraTracks();
    if (mounted) {
      setState(() {
        isCheckingBackend = true;
        isBackendReady = false;
        isCameraStarting = false;
        readinessError = null;
        errorMessage = null;
      });
    }

    final ready = await BackendApiService().isReady();
    if (!mounted) return;

    if (!ready) {
      setState(() {
        isCheckingBackend = false;
        readinessError =
            'The analysis service is not ready. Start the backend, wait for the model to load, then retry.';
      });
      return;
    }

    setState(() {
      isCheckingBackend = false;
      isBackendReady = true;
      isCameraStarting = true;
    });
    await startCamera();
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
      final usePortraitFrame = MediaQuery.sizeOf(context).width < 600;
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          // Prefer the outward-facing camera on phones. `ideal` keeps the
          // experience working on laptops and devices with only one camera.
          'facingMode': {'ideal': 'environment'},
          'width': {'ideal': usePortraitFrame ? 720 : 960},
          'height': {'ideal': usePortraitFrame ? 1280 : 720},
          'aspectRatio': {'ideal': usePortraitFrame ? 9 / 16 : 4 / 3},
        },
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

      // The live experience should work without asking the user to discover a
      // second start button below the camera.
      startLiveDetection();
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

  void startLiveDetection() {
    if (isLiveDetectionRunning || isCameraStarting || !mounted) return;
    setState(() {
      isLiveDetectionRunning = true;
    });

    unawaited(runDetectionOnce());

    detectionTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(runDetectionOnce()),
    );
  }

  void stopLiveDetection() {
    detectionTimer?.cancel();
    detectionTimer = null;
    if (!mounted) return;
    setState(() => isLiveDetectionRunning = false);
  }

  void toggleLiveDetection() {
    if (isLiveDetectionRunning) {
      stopLiveDetection();
    } else {
      startLiveDetection();
    }
  }

  Future<void> runDetectionOnce() async {
    if (!isBackendReady ||
        isDetecting ||
        videoElement == null ||
        isCameraStarting) {
      return;
    }

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

      _CapturedCatFrame? candidate;
      if (result.catDetected && result.bbox != null) {
        candidate = captureCatFrame(result);
      }

      if (!mounted) return;

      setState(() {
        detectionResult = result;
        if (candidate != null && shouldKeepCandidate(candidate)) {
          bestFrame = candidate;
        }
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

  _CapturedCatFrame captureCatFrame(CatDetectionResult result) {
    final video = videoElement;
    final bbox = result.bbox;
    if (video == null ||
        bbox == null ||
        bbox.length != 4 ||
        video.videoWidth <= 0 ||
        video.videoHeight <= 0) {
      throw StateError('The camera frame is not ready yet.');
    }

    final marginX = bbox[2] * 0.14;
    final marginY = bbox[3] * 0.14;
    final sourceX = (bbox[0] - marginX).clamp(0, video.videoWidth.toDouble());
    final sourceY = (bbox[1] - marginY).clamp(0, video.videoHeight.toDouble());
    final sourceWidth = (bbox[2] + marginX * 2).clamp(
      1,
      video.videoWidth - sourceX,
    );
    final sourceHeight = (bbox[3] + marginY * 2).clamp(
      1,
      video.videoHeight - sourceY,
    );
    final outputScale = sourceWidth > 640 ? 640 / sourceWidth : 1.0;
    final outputWidth = (sourceWidth * outputScale).round();
    final outputHeight = (sourceHeight * outputScale).round();

    final canvas = html.CanvasElement(width: outputWidth, height: outputHeight);
    canvas.context2D.drawImageScaledFromSource(
      video,
      sourceX,
      sourceY,
      sourceWidth,
      sourceHeight,
      0,
      0,
      outputWidth,
      outputHeight,
    );

    final imageData = canvas.context2D.getImageData(
      0,
      0,
      outputWidth,
      outputHeight,
    );
    final pixels = imageData.data;
    final sampleStep = math.max(
      1,
      (math.max(outputWidth, outputHeight) / 120).floor(),
    );
    var brightnessTotal = 0.0;
    var gradientTotal = 0.0;
    var samples = 0;

    double luminanceAt(int x, int y) {
      final index = (y * outputWidth + x) * 4;
      return (pixels[index] * 0.2126 +
              pixels[index + 1] * 0.7152 +
              pixels[index + 2] * 0.0722) /
          255;
    }

    for (var y = 0; y < outputHeight; y += sampleStep) {
      for (var x = 0; x < outputWidth; x += sampleStep) {
        final value = luminanceAt(x, y);
        brightnessTotal += value;
        if (x + sampleStep < outputWidth) {
          gradientTotal += (value - luminanceAt(x + sampleStep, y)).abs();
        }
        if (y + sampleStep < outputHeight) {
          gradientTotal += (value - luminanceAt(x, y + sampleStep)).abs();
        }
        samples++;
      }
    }

    final brightness = samples == 0 ? 0.0 : brightnessTotal / samples;
    final sharpness = samples == 0 ? 0.0 : gradientTotal / (samples * 2);
    final areaRatio =
        (bbox[2] * bbox[3]) / (video.videoWidth * video.videoHeight);
    final quality = FrameQualityService.calculate(
      detectionConfidence: result.confidence,
      brightness: brightness,
      sharpness: sharpness,
      areaRatio: areaRatio,
    );
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.82);
    return _CapturedCatFrame(
      bytes: base64Decode(dataUrl.substring(dataUrl.indexOf(',') + 1)),
      quality: quality,
      brightness: brightness,
      sharpness: sharpness,
      capturedAt: DateTime.now(),
    );
  }

  bool shouldKeepCandidate(_CapturedCatFrame candidate) {
    final current = freshBestFrame;
    if (current == null) return true;

    final agePenalty =
        DateTime.now().difference(current.capturedAt).inMilliseconds / 40000;
    return candidate.quality >= current.quality - agePenalty;
  }

  _CapturedCatFrame? get freshBestFrame {
    final frame = bestFrame;
    if (frame == null ||
        DateTime.now().difference(frame.capturedAt) > bestFrameLifetime) {
      return null;
    }
    return frame;
  }

  Future<void> openAutomaticCueAnalysis() async {
    final savedFrame = freshBestFrame;
    if (savedFrame == null) return;
    try {
      stopLiveDetection();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AutomaticCueAnalysisScreen(catCrop: savedFrame.bytes),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          errorMessage =
              'The saved frame could not be analyzed. Please capture another.';
        });
      }
    } finally {
      if (mounted) startLiveDetection();
    }
  }

  String get statusText {
    if (isCheckingBackend) return 'Preparing analysis service…';
    if (!isBackendReady) return 'Analysis service unavailable';
    if (isCameraStarting) return 'Starting camera…';
    if (isDetecting) return 'Looking for a cat…';
    if (detectionResult?.catDetected == true) {
      return 'Cat found · best frame saved';
    }
    if (freshBestFrame != null) return 'Saved frame ready';
    if (!isLiveDetectionRunning) return 'Detection paused';
    return 'Keep your cat in the frame';
  }

  Color get statusColor {
    if (freshBestFrame != null) return CatTalkColors.positive;
    if (errorMessage != null || readinessError != null) {
      return CatTalkColors.danger;
    }
    return CatTalkColors.accent;
  }

  void stopCameraTracks() {
    detectionTimer?.cancel();
    detectionTimer = null;
    for (final track in mediaStream?.getTracks() ?? <html.MediaStreamTrack>[]) {
      track.stop();
    }
    mediaStream = null;
    videoElement?.srcObject = null;
  }

  @override
  void dispose() {
    stopCameraTracks();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedFrame = freshBestFrame;
    final canContinue = savedFrame != null;
    final usePortraitFrame = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Live observation')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Text(
                'Find your cat — we’ll save the best view',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The app watches for a clear, well-lit frame and keeps it ready, so your cat does not need to stay still.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: usePortraitFrame ? 9 / 16 : 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: Colors.black,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const HtmlElementView(viewType: videoViewType),
                        if (detectionResult?.bbox != null)
                          CustomPaint(
                            painter: LiveBoundingBoxPainter(
                              bbox: detectionResult!.bbox!,
                              originalWidth: videoOriginalWidth,
                              originalHeight: videoOriginalHeight,
                            ),
                          ),
                        Positioned(
                          left: 14,
                          top: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isDetecting ||
                                    isCameraStarting ||
                                    isCheckingBackend)
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  Icon(
                                    canContinue
                                        ? Icons.check_circle_rounded
                                        : Icons.videocam_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                const SizedBox(width: 7),
                                Text(
                                  statusText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
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
              ),
              if (readinessError != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CatTalkColors.dangerSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CatTalkColors.danger.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: CatTalkColors.danger,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(readinessError!)),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: prepareLiveExperience,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CatTalkColors.dangerSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CatTalkColors.danger.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: CatTalkColors.danger,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (savedFrame != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CatTalkColors.positiveSoft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: CatTalkColors.positive.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          savedFrame.bytes,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Best frame ready',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Quality ${(savedFrame.quality * 100).round()}% · saved automatically',
                              style: const TextStyle(
                                color: CatTalkColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: CatTalkColors.positive,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: !isBackendReady || isCameraStarting
                        ? null
                        : toggleLiveDetection,
                    icon: Icon(
                      isLiveDetectionRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      isLiveDetectionRunning
                          ? 'Pause detection'
                          : 'Resume detection',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        !isBackendReady || isCameraStarting || isDetecting
                        ? null
                        : runDetectionOnce,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Check now'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: canContinue ? openAutomaticCueAnalysis : null,
                  icon: const Icon(Icons.camera_rounded),
                  label: Text(
                    canContinue
                        ? 'Analyze the best saved frame'
                        : 'Waiting to find a cat',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Visual estimates are automated and may be wrong. They are not veterinary advice. Give your cat space if they appear distressed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: CatTalkColors.muted, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapturedCatFrame {
  final Uint8List bytes;
  final double quality;
  final double brightness;
  final double sharpness;
  final DateTime capturedAt;

  const _CapturedCatFrame({
    required this.bytes,
    required this.quality,
    required this.brightness,
    required this.sharpness,
    required this.capturedAt,
  });
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
      ..color = CatTalkColors.accent;

    final labelPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = CatTalkColors.accent;

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

    canvas.drawRect(Rect.fromLTWH(rect.left, labelTop, 120, 28), labelPaint);

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
    textPainter.paint(canvas, Offset(rect.left + 8, labelTop + 4));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LiveBoundingBoxPainter oldDelegate) {
    return oldDelegate.bbox != bbox ||
        oldDelegate.originalWidth != originalWidth ||
        oldDelegate.originalHeight != originalHeight;
  }
}
