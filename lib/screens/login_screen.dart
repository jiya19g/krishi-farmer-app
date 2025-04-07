import 'package:farmer_app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farmer_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleView;
  const LoginScreen({required this.toggleView, Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  

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
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await _auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getErrorMessage(e.code);
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
    final colorScheme = theme.colorScheme;

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
                      'Welcome Back',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryGreen.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppColors.secondaryGreen.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen.withOpacity(0.6)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
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

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
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
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handlePasswordReset,
                          child: Text(
                            'Forgot Password?',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Error Message
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
                              color: AppColors.errorRed.withOpacity(0.1),
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
                                      color: colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                      // Sign In Button
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
      shadowColor: AppColors.primaryGreen.withOpacity(0.3),
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
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Sign In',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ),
    ),
  ),
),
const SizedBox(height: 24),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          TextButton(
                            onPressed: widget.toggleView,
                            child: Text(
                              'Register',
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

  Future<void> _handlePasswordReset() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email first'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: AppColors.tertiaryGreen.withOpacity(0.9),
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(_emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset email sent'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: AppColors.tertiaryGreen.withOpacity(0.9),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: AppColors.errorRed.withOpacity(0.9),
        ),
      );
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid email or password';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return 'Login failed. Please try again';
    }
  }
}