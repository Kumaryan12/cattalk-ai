import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/backend_prediction.dart';
import '../models/vision_feature_prediction.dart';

class BackendApiService {
  static const String baseUrl = AppConfig.backendBaseUrl;

  Future<BackendPrediction> predictCatState(
    Uint8List imageBytes,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/predict-cat-state'),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'cat.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        'Backend cat-state prediction failed: ${response.statusCode}',
      );
    }

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    return BackendPrediction.fromJson(jsonData);
  }

  Future<VisionFeaturePrediction> predictVisionFeatures(
    Uint8List imageBytes,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/vision-feature-prediction'),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'cat.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        'Vision feature prediction failed: ${response.statusCode}',
      );
    }

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    return VisionFeaturePrediction.fromJson(jsonData);
  }
}