import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<String> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    final loadedLogs = await LocalStorageService().getRawLogs();

    setState(() {
      logs = loadedLogs;
      isLoading = false;
    });
  }

  Future<void> clearLogs() async {
    await LocalStorageService().clearLogs();
    await loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Logs'),
        actions: [
          IconButton(
            onPressed: clearLogs,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? const Center(
                  child: Text('No logs saved yet.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(logs[index]),
                      ),
                    );
                  },
                ),
    );
  }
}