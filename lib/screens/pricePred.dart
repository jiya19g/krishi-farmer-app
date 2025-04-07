import 'package:flutter/material.dart';

class PricePredictionScreen extends StatelessWidget {
  const PricePredictionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Crop Price Prediction',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Select Crop',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Select Location',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Prediction logic
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Predict Price'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent Predictions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // Add list of recent predictions here
        ],
      ),
    );
  }
}