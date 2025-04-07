class Crop {
  final int stateID;
  final String state;
  final int cropID;
  final String name;
  final String season;
  final String primaryCategory;
  final String secondaryCategory;
  final String tertiaryCategory;
  final Map<String, MonthData> timeline;

  const Crop({
    required this.stateID,
    required this.state,
    required this.cropID,
    required this.name,
    required this.season,
    required this.primaryCategory,
    required this.secondaryCategory,
    required this.tertiaryCategory,
    required this.timeline,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      stateID: json['stateID'] ?? 0,
      state: json['state'] ?? 'All India',
      cropID: json['cropID'] ?? 0,
      name: json['crops'] ?? '',
      season: json['season'] ?? '-',
      primaryCategory: json['primaryCategory'] ?? '',
      secondaryCategory: json['secondaryCategory'] ?? '',
      tertiaryCategory: json['tertiaryCategory'] ?? '',
      timeline: _parseTimeline(json),
    );
  }

  static Map<String, MonthData> _parseTimeline(Map<String, dynamic> json) {
    final months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 
                   'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    final timeline = <String, MonthData>{};
    
    for (final month in months) {
      final monthData = json[month];
      if (monthData is List && monthData.isNotEmpty) {
        timeline[month] = MonthData.fromDynamic(monthData);
      }
    }
    
    return timeline;
  }

  bool hasActivityInMonth(String month) {
    return timeline[month]?.color.isNotEmpty ?? false;
  }
}

class MonthData {
  final String? phase;
  final String color;

  const MonthData({this.phase, required this.color});

  factory MonthData.fromDynamic(dynamic data) {
    if (data is List) {
      if (data.length == 1 && data[0].toString().startsWith('#')) {
        return MonthData(phase: null, color: data[0]);
      } else if (data.length >= 2) {
        return MonthData(
          phase: data[0].toString(),
          color: data[1].toString(),
        );
      }
    }
    return MonthData(phase: null, color: '');
  }
}