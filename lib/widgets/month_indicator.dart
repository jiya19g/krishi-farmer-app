import 'package:farmer_app/models/crop_model_cal.dart';
import 'package:flutter/material.dart';
import '../models/crop_model.dart';

class MonthIndicator extends StatelessWidget {
  final Map<String, MonthData> timeline;
  
  static const monthAbbreviations = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
  static const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 
                           'July', 'August', 'September', 'October', 'November', 'December'];

  const MonthIndicator({
    Key? key,
    required this.timeline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(12, (index) {
            final monthKey = _getMonthKey(index);
            final monthData = timeline[monthKey];
            final isActive = monthData != null && monthData.color.isNotEmpty;
            
            return Tooltip(
              message: '${monthNames[index]}: ${isActive ? _getActivityMessage(monthData!) : 'No activity'}',
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive 
                      ? _parseColor(monthData!.color)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive 
                        ? _parseColor(monthData!.color).withOpacity(0.5)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    monthAbbreviations[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? _getContrastColor(_parseColor(monthData!.color))
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Sowing', Colors.blue),
            SizedBox(width: 16),
            _buildLegendItem('Harvest', Colors.green),
          ],
        ),
      ],
    );
  }

  String _getActivityMessage(MonthData data) {
    final activityType = data.color.toLowerCase().contains('3187b9') ? 'Sowing' : 'Harvest';
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

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getMonthKey(int index) {
    return ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 
            'jul', 'aug', 'sep', 'oct', 'nov', 'dec'][index];
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}