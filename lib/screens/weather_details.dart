import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class WeatherDetailsPage extends StatefulWidget {
  final Weather weather;
  final String apiKey;

  const WeatherDetailsPage({
    Key? key,
    required this.weather,
    required this.apiKey,
  }) : super(key: key);

  @override
  _WeatherDetailsPageState createState() => _WeatherDetailsPageState();
}

class _WeatherDetailsPageState extends State<WeatherDetailsPage>
    with SingleTickerProviderStateMixin {
  late WeatherFactory _weatherFactory;
  List<Weather>? _forecast;
  bool _isLoadingForecast = false;
  String _forecastError = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _weatherFactory = WeatherFactory(widget.apiKey);

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
    _fetchForecast();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchForecast() async {
    if (widget.weather.latitude == null || widget.weather.longitude == null) {
      setState(() {
        _forecastError = 'Invalid location coordinates';
        _isLoadingForecast = false;
      });
      return;
    }

    setState(() {
      _isLoadingForecast = true;
      _forecastError = '';
    });

    try {
      final forecast = await _weatherFactory.fiveDayForecastByLocation(
        widget.weather.latitude!,
        widget.weather.longitude!,
      );

      setState(() {
        _forecast = forecast;
      });
    } catch (e) {
      setState(() {
        _forecastError = 'Failed to load forecast. Please try again.';
      });
    } finally {
      setState(() {
        _isLoadingForecast = false;
      });
    }
  }

  Future<void> _searchCity(String cityName) async {
    if (cityName.isEmpty) return;

    setState(() {
      _isLoadingForecast = true;
      _forecastError = '';
    });

    try {
      final weather = await _weatherFactory.currentWeatherByCityName(cityName);
      final forecast = await _weatherFactory.fiveDayForecastByCityName(cityName);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherDetailsPage(
            weather: weather,
            apiKey: widget.apiKey,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _forecastError = 'City not found. Please try another location.';
        _isLoadingForecast = false;
      });
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return DateFormat('h:mm a').format(dateTime);
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '--/--/----';
    return DateFormat('EEE, MMM d').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.weather;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0095C9), Color(0xFF0079AD), Color(0xFF025E91)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar (appears when search icon is pressed)
                    if (_showSearch)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Search city...',
                                      hintStyle: TextStyle(color: Colors.white70),
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (value) => _searchCity(value),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.search, color: Colors.white),
                                  onPressed: () => _searchCity(_searchController.text),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // App bar with back button, title and search
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            weather.areaName ?? "Weather Details",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _showSearch = !_showSearch;
                                  if (!_showSearch) {
                                    _searchController.clear();
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              onPressed: () {
                                _animationController.reset();
                                _animationController.forward();
                                _fetchForecast();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Current weather summary with hero animation
                    Hero(
                      tag: 'weather_${weather.areaName}',
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'https://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png',
                                      width: 80,
                                      height: 80,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.wb_sunny,
                                        size: 60,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '${weather.temperature?.celsius?.round()}°C',
                                      style: theme.textTheme.displaySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  weather.weatherMain ?? '',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  weather.weatherDescription ?? '',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Weather details with expandable card
                    _buildExpandableCard(
                      title: 'Details',
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        children: [
                          _buildTableRow(
                            'Feels Like',
                            '${weather.tempFeelsLike?.celsius?.round()}°C',
                          ),
                          _buildTableRow('Humidity', '${weather.humidity}%'),
                          _buildTableRow('Pressure', '${weather.pressure} hPa'),
                          _buildTableRow(
                            'Wind Speed',
                            '${weather.windSpeed} m/s',
                          ),
                          _buildTableRow(
                            'Wind Direction',
                            '${weather.windDegree}°',
                          ),
                          _buildTableRow(
                            'Cloudiness',
                            '${weather.cloudiness}%',
                          ),
                          _buildTableRow(
                            'Sunrise',
                            _formatTime(weather.sunrise),
                          ),
                          _buildTableRow('Sunset', _formatTime(weather.sunset)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 5-day forecast with animated list
                    _buildExpandableCard(
                      title: '5-Day Forecast',
                      child: _buildForecastSection(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(value, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildExpandableCard({required String title, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white.withOpacity(0.15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ExpansionTile(
            title: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            initiallyExpanded: true,
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            children: [
              Padding(padding: const EdgeInsets.all(16), child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastSection() {
    if (_isLoadingForecast) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_forecastError.isNotEmpty) {
      return Column(
        children: [
          Text(_forecastError, style: TextStyle(color: Colors.orange[200])),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _fetchForecast,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    if (_forecast == null || _forecast!.isEmpty) {
      return Column(
        children: [
          Text(
            'No forecast data available',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          if (_forecast != null && _forecast!.isEmpty)
            Text(
              'The API returned an empty forecast',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
        ],
      );
    }

    // Group forecasts by day
    final dailyForecasts = <DateTime, List<Weather>>{};
    for (var forecast in _forecast!) {
      final date = DateTime(
        forecast.date!.year,
        forecast.date!.month,
        forecast.date!.day,
      );
      dailyForecasts.putIfAbsent(date, () => []).add(forecast);
    }

    // Sort the days
    final sortedDates = dailyForecasts.keys.toList()..sort();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedDates.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.white.withOpacity(0.2),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayForecasts = dailyForecasts[date]!;
        final middayForecast = dayForecasts.firstWhere(
          (f) => f.date!.hour == 12,
          orElse: () => dayForecasts.first,
        );

        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Show detailed forecast for the day
              _showDailyForecastDialog(context, date, dayForecasts);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Image.network(
                    'https://openweathermap.org/img/wn/${middayForecast.weatherIcon}@2x.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.wb_sunny,
                      size: 40,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(middayForecast.date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          middayForecast.weatherDescription ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${middayForecast.temperature?.celsius?.round()}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dayForecasts.length > 1)
                        Text(
                          '${dayForecasts.last.temperature?.celsius?.round()}°C',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDailyForecastDialog(
    BuildContext context,
    DateTime date,
    List<Weather> forecasts,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0083B0), Color(0xFF0079AD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...forecasts.map(
                (forecast) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        _formatTime(forecast.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.network(
                        'https://openweathermap.org/img/wn/${forecast.weatherIcon}@2x.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.wb_sunny,
                          size: 40,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          forecast.weatherDescription ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        '${forecast.temperature?.celsius?.round()}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}