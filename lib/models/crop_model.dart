class CropPrediction {
  final String crop;
  final Map<String, dynamic> details;

  CropPrediction({
    required this.crop,
    required this.details,
  });

  factory CropPrediction.fromJson(Map<String, dynamic> json) {
    return CropPrediction(
      crop: json['recommended_crop'] ?? 'Unknown',
      details: json['crop_details'] ?? {},
    );
  }
}