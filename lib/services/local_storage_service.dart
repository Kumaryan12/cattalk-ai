import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/interaction_log.dart';

class LocalStorageService {
  static const String _logsKey = 'interaction_logs';

  Future<void> saveInteractionLog(InteractionLog log) async {
    final prefs = await SharedPreferences.getInstance();

    final existingLogs = prefs.getStringList(_logsKey) ?? [];

    existingLogs.add(jsonEncode(log.toJson()));

    await prefs.setStringList(_logsKey, existingLogs);
  }

  Future<List<String>> getRawLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_logsKey) ?? [];
  }

  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logsKey);
  }
}