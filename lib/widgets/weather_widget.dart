import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import '../screens/weather_details.dart';

class WeatherWidget extends StatefulWidget {
  final String apiKey;

  const WeatherWidget({Key? key, required this.apiKey}) : super(key: key);

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  late WeatherFactory _weatherFactory;
  Weather? _currentWeather;
  bool _isLoading = true;
  String _error = '';
  String _locationName = 'Loading...';
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _weatherFactory = WeatherFactory(widget.apiKey);
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _showRetry = false;
    });

    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Please enable location services');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied. Please enable them in app settings.');
      }

      // Get position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10));

      // Fetch weather with timeout
      _currentWeather = await _weatherFactory.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _locationName = _currentWeather?.areaName ?? 'Current Location';
        _isLoading = false;
      });
    } on TimeoutException {
      setState(() {
        _error = 'Request timed out. Please check your internet connection.';
        _isLoading = false;
        _showRetry = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
        _showRetry = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_currentWeather != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeatherDetailsPage(weather: _currentWeather!, apiKey: dotenv.env['WEATHER_API_KEY'] ?? '',),
            ),
          );
        } else if (_showRetry) {
          _fetchWeather();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0095C9),
              Color(0xFF0079AD),
              Color(0xFF025E91),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isLoading
            ? _buildLoadingState()
            : _error.isNotEmpty
                ? _buildErrorState()
                : _buildWeatherContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        const SizedBox(width: 16),
        Text(
          'Fetching weather...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weather',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _error,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.yellow[100],
              ),
        ),
        if (_showRetry) ...[
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchWeather,
          ),
        ],
      ],
    );
  }

  Widget _buildWeatherContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _locationName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Image.network(
              'https://openweathermap.org/img/wn/${_currentWeather!.weatherIcon}@2x.png',
              width: 60,
              height: 60,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.wb_sunny,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${_currentWeather!.temperature?.celsius?.round()}°C',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentWeather!.weatherMain ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentWeather!.weatherDescription ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}