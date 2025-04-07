import 'package:farmer_app/models/crop_model_cal.dart';
import 'package:flutter/material.dart';
import '../services/crop_service_cal.dart';
import '../models/crop_model.dart';
import '../widgets/crop_card.dart';
import '../screens/crop_detail_screen.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({Key? key}) : super(key: key);

  @override
  _CropCalendarScreenState createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  final CropService _cropService = CropService();
  List<Crop> _allCrops = [];
  Map<String, List<Crop>> _groupedCrops = {};
  String _searchQuery = '';
  final List<String> _selectedSeasons = [];
  final List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCropData();
  }

  Future<void> _loadCropData() async {
    try {
      final crops = await _cropService.loadCrops();
      setState(() {
        _allCrops = crops;
        _groupedCrops = _cropService.groupCrops(crops);
      });
    } catch (e) {
      print('Error loading crop data: $e');
    }
  }

  List<Crop> _getFilteredCrops() {
    return _allCrops.where((crop) {
      final matchesSearch = _searchQuery.isEmpty || 
          crop.name.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesSeason = _selectedSeasons.isEmpty || 
          _selectedSeasons.contains(crop.season);
      
      final matchesCategory = _selectedCategories.isEmpty ||
          _selectedCategories.contains(crop.primaryCategory) ||
          _selectedCategories.contains(crop.secondaryCategory);
      
      return matchesSearch && matchesSeason && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCrops = _getFilteredCrops();
    final filteredGroups = _cropService.groupCrops(filteredCrops);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Calendar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search crops...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _allCrops.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final cropName = filteredGroups.keys.elementAt(index);
                      final variants = filteredGroups[cropName]!;
                      
                      return CropCard(
                        crop: variants.first,
                        stateVariants: variants,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CropDetailScreen(
                                cropName: cropName,
                                stateVariants: variants,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}