import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/training_sample.dart';

class TrainingMemoryService {
  static const String storageKey = 'training_samples';

  Future<void> saveSample(
    TrainingSample sample,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = await loadSamples();

    existing.add(sample);

    final encoded = existing
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    await prefs.setStringList(
      storageKey,
      encoded,
    );
  }

  Future<List<TrainingSample>> loadSamples() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(storageKey);

    if (data == null) {
      return [];
    }

    return data
        .map(
          (e) => TrainingSample.fromJson(
            jsonDecode(e),
          ),
        )
        .toList();
  }

  Future<void> clearSamples() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(storageKey);
  }
}