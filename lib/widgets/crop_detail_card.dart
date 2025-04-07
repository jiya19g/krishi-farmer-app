import 'package:flutter/material.dart';
import 'package:farmer_app/utils/json_loader.dart';

class CropDetailCard extends StatefulWidget {
  final String cropName;

  const CropDetailCard({
    Key? key,
    required this.cropName,
  }) : super(key: key);

  @override
  State<CropDetailCard> createState() => _CropDetailCardState();
}

class _CropDetailCardState extends State<CropDetailCard> {
  late Future<Map<String, dynamic>> _cropDetails;

  @override
  void initState() {
    super.initState();
    _cropDetails = _loadCropDetails();
  }

  Future<Map<String, dynamic>> _loadCropDetails() async {
    try {
      print("Loading details for: ${widget.cropName.toLowerCase()}");
      final allCrops = await JsonLoader.loadCropData();
      print("Loaded crops: ${allCrops.keys}");
      
      final cropKey = widget.cropName.toLowerCase();
      final details = allCrops[cropKey] ?? {
        'info': 'No details available for this crop',
        'season': 'Not specified',
        'soil': 'Not specified',
        'water_requirement': 'Not specified',
        'temperature': 'Not specified',
        'growing_period': 'Not specified',
      };
      
      print("Found details: $details");
      return details;
    } catch (e) {
      print("Error loading crop details: $e");
      return {
        'error': 'Failed to load details: $e',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _cropDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }

        final details = snapshot.data!;
        if (details.containsKey('error')) {
          return _buildErrorCard(details['error']);
        }

        return _buildDetailCard(details);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(height: 8),
            Text(
              'Error loading details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() {
                _cropDetails = _loadCropDetails();
              }),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(Map<String, dynamic> details) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(12),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.eco, color: Colors.green),
            title: Text(
              widget.cropName.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text('Crop Details'),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('Season', details['season']),
                _buildDetailRow('Soil Type', details['soil']),
                _buildDetailRow('Water Needs', details['water_requirement']),
                _buildDetailRow('Temperature', details['temperature']),
                _buildDetailRow('Growing Period', details['growing_period']),
              ],
            ),
          ),
          _buildTipsSection(details),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'Not specified',
              style: TextStyle(
                color: Colors.green[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(Map<String, dynamic> details) {
    final tips = _generateTips(details);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GROWING TIPS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 8),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, size: 8, color: Colors.green),
                SizedBox(width: 8),
                Expanded(child: Text(tip)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _generateTips(Map<String, dynamic> details) {
    final season = details['season']?.toString().toLowerCase() ?? '';
    final waterReq = details['water_requirement']?.toString().toLowerCase() ?? '';
    final soilType = details['soil']?.toString().toLowerCase() ?? '';

    return [
      if (waterReq.contains('high')) 'Water deeply 3-4 times per week',
      if (waterReq.contains('moderate')) 'Water 2-3 times per week',
      if (waterReq.contains('low')) 'Water only when soil is dry',
      if (season.contains('kharif')) 'Best planted during monsoon season',
      if (season.contains('rabi')) 'Best planted after monsoon season',
      'Prefers ${soilType.isNotEmpty ? soilType : 'well-drained'} soil',
      'Test soil pH before planting',
      'Rotate crops to maintain soil health',
    ];
  }
}