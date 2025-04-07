import 'dart:convert';
import 'package:farmer_app/models/crop_model_cal.dart';
import 'package:flutter/services.dart';
import '../models/crop_model.dart';

class CropService {
  Future<List<Crop>> loadCrops() async {
    try {
      final jsonString = await rootBundle.loadString('assets/crop_data.json');
      final jsonData = json.decode(jsonString);
      
      if (jsonData['records'] is Map && jsonData['records']['records'] is List) {
        return (jsonData['records']['records'] as List)
            .map<Crop>((item) => Crop.fromJson(item))
            .toList();
      }
      throw Exception('Invalid data format');
    } catch (e) {
      print('Error loading crop data: $e');
      rethrow;
    }
  }

  Map<String, List<Crop>> groupCrops(List<Crop> crops) {
    final Map<String, List<Crop>> grouped = {};
    
    for (final crop in crops) {
      if (!grouped.containsKey(crop.name)) {
        grouped[crop.name] = [];
      }
      // Only add if state doesn't exist for this crop
      if (!grouped[crop.name]!.any((c) => c.state == crop.state)) {
        grouped[crop.name]!.add(crop);
      }
    }
    return grouped;
  }
}