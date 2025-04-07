import 'package:farmer_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farmer_app/screens/home_screen.dart';
import 'package:farmer_app/screens/tools_screen.dart';
import 'package:farmer_app/screens/community_screen.dart';
import 'package:farmer_app/screens/profile_screen.dart';
import 'package:farmer_app/components/bottom_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // These are "sections" not routes
  final List<Widget> _sections = const [
    HomeScreen(),    // Your existing home content
    ToolsScreen(),   // Tools content
    CommunityScreen(), // Community content
    ProfileScreen(), // Profile content
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar here - let individual sections handle their own headers
      body: _sections[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
  @override
void initState() {
  super.initState();
  // Verify user is actually logged in
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    }
  });
}
}