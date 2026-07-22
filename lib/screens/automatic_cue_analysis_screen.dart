import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/backend_api_service.dart';
import '../ui/cattalk_theme.dart';
import 'prediction_result_screen.dart';

class AutomaticCueAnalysisScreen extends StatefulWidget {
  final Uint8List catCrop;

  const AutomaticCueAnalysisScreen({super.key, required this.catCrop});

  @override
  State<AutomaticCueAnalysisScreen> createState() =>
      _AutomaticCueAnalysisScreenState();
}

class _AutomaticCueAnalysisScreenState
    extends State<AutomaticCueAnalysisScreen> {
  String? errorMessage;
  bool analyzing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => analyze());
  }

  Future<void> analyze() async {
    if (analyzing) return;
    setState(() {
      analyzing = true;
      errorMessage = null;
    });

    try {
      final analysis = await BackendApiService().classifyCatFrame(
        widget.catCrop,
      );
      final prediction = analysis.prediction;
      if (prediction == null) {
        throw const BackendApiException(
          'The captured frame did not contain enough visual information.',
        );
      }
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PredictionResultScreen(
            imageBytes: widget.catCrop,
            result: prediction,
            advisory: analysis.advisory,
            sourceLabel: 'Live camera snapshot',
            secondaryActionLabel: 'Return to live camera',
          ),
        ),
      );
    } on BackendApiException catch (error) {
      if (!mounted) return;
      setState(() {
        analyzing = false;
        errorMessage = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analyzing snapshot')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [CatTalkColors.lilac, CatTalkColors.peach],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Image.memory(
                          widget.catCrop,
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 14,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: CatTalkColors.green,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Frame secured',
                                style: TextStyle(
                                  fontSize: 12,
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
                const SizedBox(height: 26),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: analyzing
                      ? Column(
                          key: const ValueKey('analyzing'),
                          children: [
                            const LinearProgressIndicator(
                              borderRadius: BorderRadius.all(
                                Radius.circular(99),
                              ),
                              minHeight: 7,
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Your cat can move now.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'We saved the clearest moment and are comparing its broad visual patterns.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: CatTalkColors.mutedInk,
                                height: 1.5,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('error'),
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 42,
                              color: Color(0xFFB44949),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'The estimate could not finish',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 9),
                            Text(
                              errorMessage ?? 'Please try again.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(height: 1.45),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: analyze,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Try this frame again'),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: CatTalkColors.mint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 17,
                        color: CatTalkColors.green,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'This image is processed privately and is not saved.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CatTalkColors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
