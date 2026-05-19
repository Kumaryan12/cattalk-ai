import 'package:flutter/material.dart';
import 'image_scan_screen.dart';
import 'cue_review_screen.dart';
import 'logs_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CatTalk AI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Personalized Cat Interaction MVP',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scan your cat, estimate its behavioral state, play a command sound, and collect feedback.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ImageScanScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.pets),
              label: const Text('Start Cat Scan'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LogsScreen(),
      ),
    );
  },
  icon: const Icon(Icons.history),
  label: const Text('View Feedback History'),
),
          ],
        ),
      ),
    );
  }
}