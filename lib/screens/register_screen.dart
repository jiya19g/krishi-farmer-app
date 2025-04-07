import 'package:farmer_app/themes/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farmer_app/services/auth_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  final VoidCallback toggleView;
  const RegisterScreen({required this.toggleView, Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final AuthService _auth = AuthService();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  

  Map<String, dynamic> _locations = {};
  String? _selectedState;
  String? _selectedCity;
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final String response = await rootBundle.loadString('assets/location.json');
      setState(() {
        _locations = json.decode(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load locations: ${e.toString()}')),
      );
      print("Error loading locations: $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _farmSizeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && 
        _selectedState != null && 
        _selectedCity != null) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await _auth.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
          _phoneController.text.trim(),
          _selectedState!,
          _selectedCity!,
          _farmSizeController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message ?? 'Registration failed';
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An unexpected error occurred';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 40),
                    Hero(
                      tag: 'app-logo',
                      child: Image.asset(
                        'assets/logo2.png',
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Create Account',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join our farming community',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryGreen.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppColors.secondaryGreen.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppColors.secondaryGreen.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outlined,
                              color: AppColors.secondaryGreen.withOpacity(0.6)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.secondaryGreen.withOpacity(0.4),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outlined,
                              color: AppColors.secondaryGreen.withOpacity(0.6)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.secondaryGreen.withOpacity(0.4),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_android_outlined,
                              color: AppColors.secondaryGreen.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedState,
                        decoration: InputDecoration(
                          labelText: 'State',
                          prefixIcon: Icon(Icons.location_on_outlined,
                              color: AppColors.secondaryGreen.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                        ),
                        items: _locations.keys.map((String state) {
                          return DropdownMenuItem<String>(
                            value: state,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(state),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedState = newValue;
                            _selectedCity = null;
                            _cities = List<String>.from(_locations[newValue] ?? []);
                          });
                        },
                        validator: (value) => value == null ? 'Please select a state' : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: InputDecoration(
                          labelText: 'City',
                          prefixIcon: Icon(Icons.location_city_outlined,
                              color: AppColors.secondaryGreen.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                        ),
                        items: _cities.map((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(city),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCity = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a city' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _farmSizeController,
                        decoration: InputDecoration(
                          labelText: 'Farm Size (acres)',
                          prefixIcon: Icon(Icons.agriculture_outlined,
                              color: AppColors.secondaryGreen.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your farm size';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      if (_errorMessage.isNotEmpty)
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: AppColors.errorRed, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:AppColors.errorRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                      SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: _isLoading ? null : _submit,
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.zero, // Remove default padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.background,
      elevation: 0,
      shadowColor: AppColors.secondaryGreen.withOpacity(0.3),
    ),
    child: Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.background,
                  ),
                )
              : const Text(
                  'Register',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ),
    ),
  ),
),
const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryGreen.withOpacity(0.6),
                            ),
                          ),
                          TextButton(
                            onPressed: widget.toggleView,
                            child: Text(
                              'Sign In',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}