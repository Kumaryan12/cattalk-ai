import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/backend_prediction.dart';

class BackendApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

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

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Backend error: ${response.statusCode}',
      );
    }

    final jsonData = jsonDecode(response.body);

    return BackendPrediction.fromJson(jsonData);
  }
}