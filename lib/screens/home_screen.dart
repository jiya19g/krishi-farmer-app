import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:farmer_app/widgets/weather_widget.dart';
import 'package:farmer_app/carousel/custom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_app/services/auth_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _weatherApiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  final Color primaryGreen = const Color(0xFF367838);
  String userName = "Loading...";
  final AuthService _auth = AuthService();
  List<Map<String, dynamic>> schemes = [];
  List<Map<String, dynamic>> upcomingActivities = [];
  bool _loadingActivities = true;

  final List<Map<String, dynamic>> quickLinks = [
    {'icon': Icons.attach_money, 'title': 'Price', 'route': '/price_prediction'},
    {'icon': Icons.spa, 'title': 'Crops', 'route': '/crop_recommendation'},
    {'icon': Icons.calendar_today, 'title': 'Calendar', 'route': '/crop_calendar'},
    {'icon': Icons.people, 'title': 'Community', 'route': '/community'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSchemes();
    _loadUpcomingActivities();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.getCurrentUser();
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'Farmer';
        });
      }
    }
  }

  Future<void> _loadSchemes() async {
    try {
      final String response = await rootBundle.loadString('assets/schemes.json');
      final List<dynamic> data = await json.decode(response);
      setState(() {
        schemes = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print("Error loading schemes: $e");
    }
  }

  Future<void> _loadUpcomingActivities() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final query = await FirebaseFirestore.instance
          .collection('activities')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThan: now)
          .orderBy('date', descending: false)
          .limit(3)
          .get();

      setState(() {
        upcomingActivities = query.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? 'Activity',
            'date': (data['date'] as Timestamp).toDate(),
            'tag': data['tag'] ?? 'General',
          };
        }).toList();
        _loadingActivities = false;
      });
    } catch (e) {
      print('Error loading activities: $e');
      setState(() {
        _loadingActivities = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Krishi',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context),
              const SizedBox(height: 30),
              WeatherWidget(apiKey: _weatherApiKey),
              const SizedBox(height: 30),
              _buildQuickAccessSection(context),
              const SizedBox(height: 30),
              _buildActivitiesSection(context),
              const SizedBox(height: 30),
              _buildSchemesSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.grey[800],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              quickLinks.map((link) => _buildQuickAccessButton(link)).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(Map<String, dynamic> link) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Icon(link['icon'], size: 28, color: primaryGreen),
            onPressed: () => Navigator.pushNamed(context, link['route']),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          link['title'],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/activities'),
              child: Text(
                'View All',
                style: TextStyle(color: primaryGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingActivities)
          const Center(child: CircularProgressIndicator()),
        if (!_loadingActivities && upcomingActivities.isEmpty)
          _buildNoActivitiesCard(),
        if (!_loadingActivities && upcomingActivities.isNotEmpty)
          ...upcomingActivities.map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildNoActivitiesCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      color: Colors.grey[50],
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No upcoming activities'),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    IconData getIconForTag(String tag) {
      switch (tag.toLowerCase()) {
        case 'harvest':
          return Icons.grass;
        case 'planting':
          return Icons.spa;
        case 'fertilizing':
          return Icons.water_drop;
        case 'irrigation':
          return Icons.opacity;
        case 'market':
          return Icons.shopping_cart;
        default:
          return Icons.calendar_today;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      color: Colors.grey[50],
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            getIconForTag(activity['tag']),
            color: primaryGreen,
          ),
        ),
        title: Text(
          activity['title'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('MMM d, hh:mm a').format(activity['date']),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: primaryGreen,
        ),
      ),
    );
  }

  Widget _buildSchemesSection(BuildContext context) {
    if (schemes.isEmpty) {
      return const SizedBox();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schemes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
        ),
        const SizedBox(height: 16),
        SchemesCarousel(
          schemes: schemes,
          primaryColor: primaryGreen,
        ),
      ],
    );
  }
}