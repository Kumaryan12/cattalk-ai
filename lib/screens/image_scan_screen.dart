import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/backend_prediction.dart';
import '../models/cat_cues.dart';
import '../models/cat_detection_result.dart';
import '../models/vision_feature_prediction.dart';
import '../services/backend_api_service.dart';
import '../services/mood_fusion_engine.dart';
import '../services/web_cat_detection_service.dart';
import 'prediction_result_screen.dart';

class ImageScanScreen extends StatefulWidget {
  const ImageScanScreen({super.key});

  @override
  State<ImageScanScreen> createState() => _ImageScanScreenState();
}

class _ImageScanScreenState extends State<ImageScanScreen> {
  static const String imageElementId = 'cat-scan-image';

  Uint8List? selectedImageBytes;
  double? originalImageWidth;
  double? originalImageHeight;

  CatDetectionResult? detectionResult;
  BackendPrediction? backendPrediction;
  VisionFeaturePrediction? visionPrediction;

  bool isDetecting = false;
  bool isBackendPredicting = false;
  bool isVisionPredicting = false;

  final ImagePicker picker = ImagePicker();

  void updateHiddenHtmlImage(Uint8List imageBytes) {
    final base64Image = base64Encode(imageBytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Image';

    final existingElement = html.document.getElementById(imageElementId);

    if (existingElement is html.ImageElement) {
      existingElement.src = dataUrl;
      return;
    }

    final imageElement = html.ImageElement()
      ..id = imageElementId
      ..src = dataUrl
      ..style.display = 'none';

    html.document.body?.append(imageElement);
  }

  Future<void> updateOriginalImageDimensions(Uint8List imageBytes) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    originalImageWidth = image.width.toDouble();
    originalImageHeight = image.height.toDouble();
  }

  Future<void> runCatDetection() async {
    if (selectedImageBytes == null) return;

    setState(() {
      isDetecting = true;
      detectionResult = null;
    });

    try {
      updateHiddenHtmlImage(selectedImageBytes!);

      await Future.delayed(const Duration(milliseconds: 500));

      final result = await WebCatDetectionService().detectCatFromElementId(
        imageElementId,
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
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cat detection failed: $e')),
      );
    }
  }

  Future<void> runVisionFeaturePrediction() async {
    if (selectedImageBytes == null) return;

    setState(() {
      isVisionPredicting = true;
      visionPrediction = null;
    });

    try {
      final prediction = await BackendApiService().predictVisionFeatures(
        selectedImageBytes!,
      );

      if (!mounted) return;

      setState(() {
        visionPrediction = prediction;
        isVisionPredicting = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isVisionPredicting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vision feature prediction failed: $e')),
      );
    }
  }

  Future<void> runBackendMoodPrediction() async {
    if (selectedImageBytes == null) return;

    setState(() {
      isBackendPredicting = true;
      backendPrediction = null;
    });

    try {
      final prediction = await BackendApiService().predictCatState(
        selectedImageBytes!,
      );

      if (!mounted) return;

      setState(() {
        backendPrediction = prediction;
        isBackendPredicting = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isBackendPredicting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fallback CLIP prediction failed: $e')),
      );
    }
  }

  Future<void> handleSelectedImage(XFile image) async {
    final bytes = await image.readAsBytes();

    await updateOriginalImageDimensions(bytes);

    setState(() {
      selectedImageBytes = bytes;
      detectionResult = null;
      backendPrediction = null;
      visionPrediction = null;
    });

    await runCatDetection();
    await runVisionFeaturePrediction();
    await runBackendMoodPrediction();
  }

  Future<void> pickFromGallery() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    await handleSelectedImage(image);
  }

  Future<void> takePhoto() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    await handleSelectedImage(image);
  }

  void continueToPredictionResult() {
    final result = detectionResult;

    if (result == null || selectedImageBytes == null) return;

    final cues = CatCues(
      movement: result.suggestedMovement,
      ears: result.suggestedEars,
      tail: result.suggestedTail,
      body: result.suggestedBody,
      vocal: result.suggestedVocal,
    );

    final prediction = MoodFusionEngine().predict(
      cues: cues,
      backendPrediction: backendPrediction,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PredictionResultScreen(
          imageBytes: selectedImageBytes!,
          result: prediction,
          backendPrediction: backendPrediction,
        ),
      ),
    );
  }

  String confidenceText(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  Widget buildImageWithBoundingBox() {
    final bbox = detectionResult?.bbox;

    return LayoutBuilder(
      builder: (context, constraints) {
        const displayedHeight = 260.0;
        final displayedWidth = constraints.maxWidth;

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                selectedImageBytes!,
                height: displayedHeight,
                width: displayedWidth,
                fit: BoxFit.cover,
              ),
            ),
            if (bbox != null && bbox.length == 4)
              Positioned.fill(
                child: CustomPaint(
                  painter: BoundingBoxPainter(
                    bbox: bbox,
                    displayedWidth: displayedWidth,
                    displayedHeight: displayedHeight,
                    originalImageWidth: originalImageWidth,
                    originalImageHeight: originalImageHeight,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildVisionPredictionCard() {
    final prediction = visionPrediction;

    if (prediction == null) return const SizedBox.shrink();

    final featureEntries = prediction.features?.entries.toList() ?? [];
    final scoreEntries = prediction.scores.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vision Feature Prediction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Cat detected: ${prediction.catDetected ? "Yes" : "No"}'),
            Text('Cat confidence: ${confidenceText(prediction.catConfidence)}'),
            const SizedBox(height: 8),
            Text('Predicted state: ${prediction.predictedState}'),
            Text('State confidence: ${confidenceText(prediction.confidence)}'),
            const SizedBox(height: 12),
            const Text(
              'Extracted features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            if (featureEntries.isEmpty)
              const Text('No features available.')
            else
              ...featureEntries.map(
                (entry) {
                  final value = (entry.value as num).toDouble();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${entry.key}: ${confidenceText(value)}'),
                  );
                },
              ),
            const SizedBox(height: 12),
            const Text(
              'Mood scores:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...scoreEntries.map(
              (entry) {
                final value = (entry.value as num).toDouble();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${entry.key}: ${confidenceText(value)}'),
                );
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Reasoning:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...prediction.reasoning.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $reason'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBackendScores() {
    final prediction = backendPrediction;

    if (prediction == null) return const SizedBox.shrink();

    final entries = prediction.scores.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fallback Hugging Face Estimate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Top label: ${prediction.predictedLabel}'),
            Text('Confidence: ${confidenceText(prediction.confidence)}'),
            const SizedBox(height: 8),
            Text(
              prediction.warning,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            const Text(
              'All scores:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...entries.map(
              (entry) {
                final value = (entry.value as num).toDouble();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${entry.key}: ${confidenceText(value)}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue =
        selectedImageBytes != null && detectionResult?.catDetected == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Cat Image'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Capture or upload a cat image',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'The app now uses YOLO + visual feature extraction, with CLIP as a fallback estimate.',
          ),
          const SizedBox(height: 24),
          if (selectedImageBytes != null)
            buildImageWithBoundingBox()
          else
            Container(
              height: 260,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: const Text('No image selected'),
            ),
          const SizedBox(height: 20),
          if (isDetecting)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Running browser cat detection...'),
                  ],
                ),
              ),
            ),
          if (isVisionPredicting)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Running YOLO + feature prediction...'),
                  ],
                ),
              ),
            ),
          if (isBackendPredicting)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Running fallback CLIP prediction...'),
                  ],
                ),
              ),
            ),
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
                  'Confidence: ${confidenceText(detectionResult!.confidence)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          if (visionPrediction != null) buildVisionPredictionCard(),
          if (backendPrediction != null) buildBackendScores(),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: pickFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed:
                selectedImageBytes == null ? null : runVisionFeaturePrediction,
            icon: const Icon(Icons.psychology),
            label: const Text('Run Vision Feature Prediction Again'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: canContinue ? continueToPredictionResult : null,
            child: const Text('Generate AI Prediction'),
          ),
        ],
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<double> bbox;
  final double displayedWidth;
  final double displayedHeight;
  final double? originalImageWidth;
  final double? originalImageHeight;

  BoundingBoxPainter({
    required this.bbox,
    required this.displayedWidth,
    required this.displayedHeight,
    required this.originalImageWidth,
    required this.originalImageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.green;

    final labelPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green;

    final originalWidth = originalImageWidth;
    final originalHeight = originalImageHeight;

    if (originalWidth == null || originalHeight == null) return;
    if (originalWidth <= 0 || originalHeight <= 0) return;

    final sourceX = bbox[0];
    final sourceY = bbox[1];
    final sourceW = bbox[2];
    final sourceH = bbox[3];

    final scaleX = displayedWidth / originalWidth;
    final scaleY = displayedHeight / originalHeight;

    final coverScale = scaleX > scaleY ? scaleX : scaleY;
    final scaledImageWidth = originalWidth * coverScale;
    final scaledImageHeight = originalHeight * coverScale;
    final cropOffsetX = (displayedWidth - scaledImageWidth) / 2;
    final cropOffsetY = (displayedHeight - scaledImageHeight) / 2;

    final rect = Rect.fromLTWH(
      sourceX * coverScale + cropOffsetX,
      sourceY * coverScale + cropOffsetY,
      sourceW * coverScale,
      sourceH * coverScale,
    );

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, displayedWidth, displayedHeight));
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
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.bbox != bbox ||
        oldDelegate.originalImageWidth != originalImageWidth ||
        oldDelegate.originalImageHeight != originalImageHeight ||
        oldDelegate.displayedWidth != displayedWidth ||
        oldDelegate.displayedHeight != displayedHeight;
  }
}