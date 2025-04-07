import 'package:farmer_app/models/crop_model_cal.dart';
import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../widgets/month_indicator.dart';

class CropCard extends StatelessWidget {
  final Crop crop;
  final List<Crop> stateVariants;
  final VoidCallback onTap;

  const CropCard({
    Key? key,
    required this.crop,
    required this.stateVariants,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uniqueStates = stateVariants.map((c) => c.state).toSet().toList();
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    crop.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (crop.season != '-')
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSeasonColor(crop.season).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getSeasonColor(crop.season),
                        ),
                      ),
                      child: Text(
                        crop.season,
                        style: TextStyle(
                          color: _getSeasonColor(crop.season),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${crop.primaryCategory} • ${crop.secondaryCategory}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              if (uniqueStates.length > 1)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '${uniqueStates.length} states',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 12),
              MonthIndicator(timeline: crop.timeline),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeasonColor(String season) {
    switch (season.toLowerCase()) {
      case 'kharif': return Colors.orange;
      case 'rabi': return Colors.blue;
      case 'zaid': return Colors.green;
      default: return Colors.grey;
    }
  }
}