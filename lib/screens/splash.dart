
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'dart:async';
import 'package:farmer_app/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize controller with 2 second duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Configure animations
    _configureAnimations();
    
    // Start animations
    _controller.forward();
    
    // Set up navigation transition
    _setupNavigation();
  }

  void _configureAnimations() {
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const ElasticOutCurve(0.8),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _rotateAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _setupNavigation() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF026433),
                  Color(0xFF367838),
                  Color(0xFF5B8C3D),
                  Color(0xFF7F9F43),
                  Color(0xFFA6B24B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.3, 0.6, 0.8, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated background elements
                _buildAnimatedBackground(),
                // Main content
                _buildMainContent(),
                // Footer
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 30,
          child: RotationTransition(
            turns: _rotateAnimation,
            child: Icon(
              Icons.eco,
              color: Colors.white.withOpacity(0.1),
              size: 80,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 40,
          child: RotationTransition(
            turns: _rotateAnimation,
            child: Icon(
              Icons.eco,
              color: Colors.white.withOpacity(0.1),
              size: 60,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 30),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Krishi',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Empowering Farmers, Growing Futures!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 40),
          if (_controller.value > 0.5)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          'Cultivating Innovation Since 2025',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}