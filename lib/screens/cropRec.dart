import 'package:flutter/material.dart';
import 'package:farmer_app/services/crop_service.dart';
import 'package:farmer_app/models/crop_model.dart';
import 'package:farmer_app/widgets/crop_detail_card.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<CropRecommendationScreen> createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  CropPrediction? _prediction;

  final Map<String, TextEditingController> _controllers = {
    'N': TextEditingController(),
    'P': TextEditingController(),
    'K': TextEditingController(),
    'temperature': TextEditingController(),
    'humidity': TextEditingController(),
    'pH': TextEditingController(),
    'rainfall': TextEditingController(),
  };

  Future<void> _getRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prediction = await CropService.getRecommendation(
        nitrogen: double.parse(_controllers['N']!.text),
        phosphorus: double.parse(_controllers['P']!.text),
        potassium: double.parse(_controllers['K']!.text),
        temperature: double.parse(_controllers['temperature']!.text),
        humidity: double.parse(_controllers['humidity']!.text),
        ph: double.parse(_controllers['pH']!.text),
        rainfall: double.parse(_controllers['rainfall']!.text),
      );

      setState(() => _prediction = prediction);
      _showResultPopup(context, prediction);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResultPopup(BuildContext context, CropPrediction prediction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: CropDetailCard(cropName: prediction.crop),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Recommendation'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.green[800],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    _buildParameterCard(
                      icon: Icons.grass,
                      title: 'Soil Nutrients',
                      children: [
                        _buildInputField('N', 'Nitrogen (ppm)'),
                        _buildInputField('P', 'Phosphorus (ppm)'),
                        _buildInputField('K', 'Potassium (ppm)'),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildParameterCard(
                      icon: Icons.cloud,
                      title: 'Environmental Factors',
                      children: [
                        _buildInputField('temperature', 'Temperature (°C)'),
                        _buildInputField('humidity', 'Humidity (%)'),
                        _buildInputField('pH', 'Soil pH'),
                        _buildInputField('rainfall', 'Rainfall (mm)'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _getRecommendation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
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
                          'Get Recommendation',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green[600]),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Required';
          if (double.tryParse(value) == null) return 'Invalid number';
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}