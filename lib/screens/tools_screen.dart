import 'package:flutter/material.dart';
import 'package:farmer_app/screens/cropCal.dart';
import 'package:farmer_app/screens/cropRec.dart';
import 'package:farmer_app/screens/pricePred.dart';
import 'package:farmer_app/screens/activityTracker.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF367838);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryGreen,
              secondary: primaryGreen.withOpacity(0.8),
            ),
        tabBarTheme: TabBarTheme(
          labelColor: primaryGreen,
          unselectedLabelColor: Colors.grey[600],
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: primaryGreen),
          ),
        ),
      ),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Farm Tools'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.bar_chart), text: 'Price'),
                Tab(icon: Icon(Icons.eco), text: 'Crops'),
                Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
                Tab(icon: Icon(Icons.list_alt), text: 'Activities'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              PricePredictionScreen(),
              CropRecommendationScreen(),
              CropCalendarScreen(),
              ActivityTrackerScreen(),
            ],
          ),
        ),
      ),
    );
  }
}