import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'cue_review_screen.dart';

class ImageScanScreen extends StatefulWidget {
  const ImageScanScreen({super.key});

  @override
  State<ImageScanScreen> createState() => _ImageScanScreenState();
}

class _ImageScanScreenState extends State<ImageScanScreen> {
  Uint8List? selectedImageBytes;
  final ImagePicker picker = ImagePicker();

  Future<void> pickFromGallery() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      selectedImageBytes = bytes;
    });
  }

  Future<void> takePhoto() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      selectedImageBytes = bytes;
    });
  }

  void continueToCueReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CueReviewScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            'For now, this stores the scan step in the flow. Next we will connect pretrained image detection.',
          ),
          const SizedBox(height: 24),

          if (selectedImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                selectedImageBytes!,
                height: 260,
                fit: BoxFit.cover,
              ),
            )
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

          const SizedBox(height: 24),

          FilledButton(
            onPressed:
                selectedImageBytes == null ? null : continueToCueReview,
            child: const Text('Continue to Cue Review'),
          ),
        ],
      ),
    );
  }
}