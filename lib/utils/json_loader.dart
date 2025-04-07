import 'package:flutter/services.dart';
import 'dart:convert';

class JsonLoader {
  static Future<Map<String, dynamic>> loadCropData() async {
    try {
      final String response = await rootBundle.loadString('assets/crop_details.json');
      final data = await json.decode(response);
      return data is Map<String, dynamic> ? data : {};
    } catch (e) {
      print("Error loading JSON: $e");
      return {};
    }
  }
}