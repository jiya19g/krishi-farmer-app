import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farmer_app/models/user_model.dart';
import 'package:farmer_app/services/auth_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _smsAlertsEnabled = false;
  bool _isEditing = false;
  final AuthService _auth = AuthService();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _stateController;
  late final TextEditingController _cityController;
  late final TextEditingController _farmSizeController;
  late final TextEditingController _feedbackController;
  int _predictionTabIndex = 0;
  bool _isSubmittingFeedback = false;

  Map<String, dynamic> _locations = {};
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
    _farmSizeController = TextEditingController();
    _feedbackController = TextEditingController();
    _loadLocations();
    _loadUserData();
  }

  Future<void> _loadLocations() async {
    try {
      final String response = await rootBundle.loadString('assets/location.json');
      setState(() {
        _locations = json.decode(response);
      });
    } catch (e) {
      print("Error loading locations: $e");
    }
  }

  Future<void> _loadUserData() async {
    User? user = _auth.getCurrentUser();
    if (user != null) {
      UserModel? userData = await _auth.getUserData(user.uid);
      if (userData != null) {
        setState(() {
          _nameController.text = userData.name;
          _phoneController.text = userData.phone;
          _stateController.text = userData.state;
          _cityController.text = userData.city;
          _farmSizeController.text = userData.farmSize;
          _cities = List<String>.from(_locations[userData.state] ?? []);
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    User? user = _auth.getCurrentUser();
    if (user != null) {
      await _auth.updateUserData(
        user.uid,
        _nameController.text,
        _phoneController.text,
        _stateController.text,
        _cityController.text,
        _farmSizeController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _showFeedbackDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Feedback'),
          content: TextField(
            controller: _feedbackController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter your feedback here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _submitFeedback,
              child: _isSubmittingFeedback
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.isEmpty) return;

    setState(() => _isSubmittingFeedback = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('feedback').add({
          'userId': user.uid,
          'feedback': _feedbackController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'userName': _nameController.text,
          'userPhone': _phoneController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback submitted successfully!')),
          );
          Navigator.pop(context);
          _feedbackController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingFeedback = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryGreen = const Color(0xFF367838);
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showFeedbackDialog,
        child: const Icon(Icons.feedback),
        backgroundColor: primaryGreen,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(theme, primaryGreen),
              const SizedBox(height: 24),
              _buildProfileForm(theme, primaryGreen),
              const SizedBox(height: 24),
              _buildAlertSettings(theme, primaryGreen),
              const SizedBox(height: 24),
              _buildPastPredictions(theme, primaryGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, Color primaryColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.person,
            size: 40,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nameController.text,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_cityController.text}, ${_stateController.text}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            _isEditing ? Icons.check : Icons.edit,
            color: primaryColor,
          ),
          onPressed: () async {
            if (_isEditing) {
              await _updateUserData();
            } else {
              setState(() {
                _isEditing = !_isEditing;
              });
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          color: Colors.red,
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  Widget _buildProfileForm(ThemeData theme, Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEditableField(
              label: 'Full Name',
              controller: _nameController,
              icon: Icons.person_outline,
            ),
            const Divider(height: 24),
            _buildEditableField(
              label: 'Phone Number',
              controller: _phoneController,
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
            ),
            const Divider(height: 24),
            _buildLocationFields(),
            const Divider(height: 24),
            _buildEditableField(
              label: 'Farm Size',
              controller: _farmSizeController,
              icon: Icons.agriculture_outlined,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: _isEditing
              ? TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: label,
                    border: InputBorder.none,
                  ),
                  keyboardType: keyboardType,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.text.isEmpty ? 'Not set' : controller.text,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        _buildDropdownField(
          label: 'State',
          controller: _stateController,
          icon: Icons.location_on_outlined,
          items: _locations.keys.toList(),
          onChanged: (value) {
            setState(() {
              _stateController.text = value ?? '';
              _cityController.text = '';
              _cities = List<String>.from(_locations[value] ?? []);
            });
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'City',
          controller: _cityController,
          icon: Icons.location_city_outlined,
          items: _cities,
          onChanged: (value) {
            setState(() {
              _cityController.text = value ?? '';
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: _isEditing
              ? DropdownButtonFormField<String>(
                  value: controller.text.isEmpty ? null : controller.text,
                  decoration: InputDecoration(
                    labelText: label,
                    border: InputBorder.none,
                  ),
                  items: items.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: onChanged,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.text.isEmpty ? 'Not set' : controller.text,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildAlertSettings(ThemeData theme, Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.notifications_active_outlined, color: primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'SMS Alerts',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Switch(
              value: _smsAlertsEnabled,
              onChanged: (value) => setState(() => _smsAlertsEnabled = value),
              activeColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastPredictions(ThemeData theme, Color primaryColor) {
    final List<Map<String, dynamic>> _pastPredictions = [
      {'type': 'Price', 'crop': 'Wheat', 'date': '15 Jun 2023', 'prediction': '₹2,150/qtl'},
      {'type': 'Recommendation', 'crop': 'Rice', 'date': '10 May 2023', 'prediction': 'Sow in 1st week of July'},
      {'type': 'Price', 'crop': 'Cotton', 'date': '22 Apr 2023', 'prediction': '₹6,800/qtl'},
    ];

    final filteredPredictions = _pastPredictions.where((pred) => 
      _predictionTabIndex == 0 ? pred['type'] == 'Price' : pred['type'] == 'Recommendation'
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Past Predictions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _predictionTabIndex = 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _predictionTabIndex == 0 ? primaryColor : Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Price',
                  style: TextStyle(
                    color: _predictionTabIndex == 0 ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _predictionTabIndex = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _predictionTabIndex == 1 ? primaryColor : Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Recommendation',
                  style: TextStyle(
                    color: _predictionTabIndex == 1 ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: filteredPredictions.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey[300],
          ),
          itemBuilder: (context, index) {
            final prediction = filteredPredictions[index];
            final isPrice = prediction['type'] == 'Price';
            
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPrice
                      ? primaryColor.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPrice ? Icons.attach_money : Icons.lightbulb_outline,
                  color: isPrice ? primaryColor : Colors.orange,
                ),
              ),
              title: Text(
                prediction['crop'],
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                prediction['date'],
                style: theme.textTheme.bodySmall,
              ),
              trailing: Text(
                prediction['prediction'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _farmSizeController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }
}