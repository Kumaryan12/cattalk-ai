import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
class DatasetScreen extends StatelessWidget {
  const DatasetScreen({super.key});

static const String baseUrl = AppConfig.backendBaseUrl;
  Future<void> openUrl(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    if (!await launchUrl(uri)) {
      throw Exception('Could not open $uri');
    }
  }

  Widget buildButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dataset Viewer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'CatTalk AI Dataset',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'View and export collected mood-training samples and interaction-feedback logs.',
            ),

            const SizedBox(height: 30),

            buildButton(
              title: 'View Mood Training Samples',
              icon: Icons.psychology,
              onPressed: () => openUrl('/training-samples'),
            ),

            buildButton(
              title: 'View Interaction Feedback',
              icon: Icons.feedback,
              onPressed: () => openUrl('/interaction-feedback'),
            ),

            const SizedBox(height: 20),

            buildButton(
              title: 'Export Mood Samples CSV',
              icon: Icons.download,
              onPressed: () => openUrl('/export/training-samples.csv'),
            ),

            buildButton(
              title: 'Export Interaction Feedback CSV',
              icon: Icons.download,
              onPressed: () => openUrl('/export/interaction-feedback.csv'),
            ),
          ],
        ),
      ),
    );
  }
}