import 'package:farmer_app/models/crop_model_cal.dart';
import 'package:flutter/material.dart';
import '../models/crop_model.dart';

class CropDetailScreen extends StatefulWidget {
  final String cropName;
  final List<Crop> stateVariants;

  const CropDetailScreen({
    Key? key,
    required this.cropName,
    required this.stateVariants,
  }) : super(key: key);

  @override
  _CropDetailScreenState createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  String? _selectedState;
  late List<Crop> _uniqueStateVariants;

  @override
  void initState() {
    super.initState();
    // Remove duplicate states
    final seen = <String>{};
    _uniqueStateVariants = widget.stateVariants.where((crop) => seen.add(crop.state)).toList();
    _selectedState = _uniqueStateVariants.first.state;
  }

  @override
  Widget build(BuildContext context) {
    final currentCrop = _uniqueStateVariants.firstWhere(
      (c) => c.state == _selectedState,
      orElse: () => _uniqueStateVariants.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cropName),
      ),
      body: Column(
        children: [
          // State Selection
          Container(
            height: 60,
            color: Colors.grey[50],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _uniqueStateVariants.length,
              itemBuilder: (context, index) {
                final state = _uniqueStateVariants[index].state;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: ChoiceChip(
                    label: Text(state),
                    selected: _selectedState == state,
                    onSelected: (selected) {
                      setState(() {
                        _selectedState = state;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Crop Details
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crop Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildInfoRow('State', currentCrop.state),
                          _buildInfoRow('Season', currentCrop.season),
                          _buildInfoRow('Primary Category', currentCrop.primaryCategory),
                          _buildInfoRow('Secondary Category', currentCrop.secondaryCategory),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Monthly Activity
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildMonthlyActivity(currentCrop),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyActivity(Crop crop) {
    final months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 
                   'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];

    return Column(
      children: months.map((month) {
        final hasActivity = crop.hasActivityInMonth(month);
        final monthData = crop.timeline[month];
        
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  monthNames[months.indexOf(month)],
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: hasActivity 
                      ? _parseColor(monthData!.color)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: hasActivity
                    ? Center(
                        child: Text(
                          month[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getContrastColor(_parseColor(monthData!.color)),
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasActivity 
                      ? _getActivityDescription(monthData!)
                      : 'No activity',
                  style: TextStyle(
                    color: hasActivity ? Colors.grey[800] : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getActivityDescription(MonthData data) {
    final activityType = data.color.toLowerCase().contains('3187b9') 
        ? 'Sowing' 
        : 'Harvest';
    final phase = _getPhaseDescription(data.phase);
    
    return '$phase $activityType';
  }

  String _getPhaseDescription(String? phase) {
    if (phase == null) return '';
    return {
      'B': 'Beginning',
      'E': 'Early',
      'M': 'Mid',
      'L': 'Late',
      'B-M': 'Beginning-Mid',
    }[phase] ?? phase;
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}