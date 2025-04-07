import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crop_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class CropService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<CropPrediction> getRecommendation({
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    required double temperature,
    required double humidity,
    required double ph,
    required double rainfall,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'N': nitrogen,
        'P': phosphorus,
        'K': potassium,
        'temperature': temperature,
        'humidity': humidity,
        'pH': ph,
        'rainfall': rainfall,
      }),
    );

    if (response.statusCode == 200) {
      return CropPrediction.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get recommendation: ${response.statusCode}');
    }
  }
}