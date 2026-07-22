import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/app_config.dart';
import '../models/cat_analysis_result.dart';

class BackendApiException implements Exception {
  final String message;

  const BackendApiException(this.message);

  @override
  String toString() => message;
}

class BackendApiService {
  static const String baseUrl = AppConfig.backendBaseUrl;

  Future<bool> isReady() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return false;

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      return payload['status'] == 'ok' && payload['model_ready'] != false;
    } catch (_) {
      return false;
    }
  }

  Future<CatAnalysisResult> analyzeCat(Uint8List imageBytes) {
    return _sendImage('/api/analyze-cat', imageBytes);
  }

  Future<CatAnalysisResult> classifyCatFrame(Uint8List imageBytes) {
    return _sendImage('/api/classify-cat-frame', imageBytes);
  }

  Future<CatAnalysisResult> _sendImage(
    String path,
    Uint8List imageBytes,
  ) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'))
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'cat.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    try {
      final streamed = await request.send().timeout(const Duration(minutes: 3));
      final response = await http.Response.fromStream(streamed);
      final payload = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw BackendApiException(
          payload['detail'] as String? ?? 'Analysis could not be completed.',
        );
      }

      return CatAnalysisResult.fromJson(payload);
    } on BackendApiException {
      rethrow;
    } on FormatException {
      throw const BackendApiException(
        'The analysis service returned an invalid response.',
      );
    } catch (_) {
      throw const BackendApiException(
        'The analysis service is unavailable. Check that the backend is running and try again.',
      );
    }
  }
}
