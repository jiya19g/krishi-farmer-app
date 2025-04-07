import '../models/crop_model_cal.dart';

class FilterService {
  static List<Crop> filterCrops({
    required List<Crop> allCrops,
    String searchQuery = '',
    List<String> selectedSeasons = const [],
    List<String> selectedCategories = const [],
    List<String> selectedStates = const [],
  }) {
    return allCrops.where((crop) {
      // Search filter
      final matchesSearch = searchQuery.isEmpty || 
          crop.name.toLowerCase().contains(searchQuery.toLowerCase());
      
      // Season filter
      final matchesSeason = selectedSeasons.isEmpty || 
          selectedSeasons.contains(crop.season);
      
      // Category filter
      final matchesCategory = selectedCategories.isEmpty ||
          selectedCategories.contains(crop.primaryCategory) ||
          selectedCategories.contains(crop.secondaryCategory) ||
          selectedCategories.contains(crop.tertiaryCategory);
      
      // State filter
      final matchesState = selectedStates.isEmpty ||
          selectedStates.contains(crop.state);
      
      return matchesSearch && matchesSeason && matchesCategory && matchesState;
    }).toList();
  }

  static Map<String, List<String>> getAvailableFilters(List<Crop> crops) {
    final seasons = crops.map((c) => c.season).where((s) => s != '-').toSet().toList();
    final primaryCategories = crops.map((c) => c.primaryCategory).toSet().toList();
    final secondaryCategories = crops.map((c) => c.secondaryCategory).toSet().toList();
    final tertiaryCategories = crops.map((c) => c.tertiaryCategory).toSet().toList();
    final states = crops.map((c) => c.state).toSet().toList();

    return {
      'seasons': seasons,
      'primaryCategories': primaryCategories,
      'secondaryCategories': secondaryCategories,
      'tertiaryCategories': tertiaryCategories,
      'states': states,
    };
  }
}