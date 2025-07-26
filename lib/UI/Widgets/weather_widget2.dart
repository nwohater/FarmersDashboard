import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  final String condition;
  final double temperature;

  const WeatherWidget({
    super.key,
    required this.condition,
    required this.temperature,
  });

  String getWeatherImage(String condition) {
    final Map<String, String> conditionToImage = {
      'Cloudy': 'assets/images/Cloudy.png',
      'Partly Cloudy': 'assets/images/PartlyCloudy.png',
      'Sunny': 'assets/images/Sunny.png',
      'Snow': 'assets/images/Snow.png',
      'Storm': 'assets/images/Storm.png',
    };

    return conditionToImage[condition] ?? 'assets/images/Sunny.png';
  }

  @override
  Widget build(BuildContext context) {
    final String weatherImage = getWeatherImage(condition);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      width: isSmallScreen ? 80 : (isMediumScreen ? 90 : 100),
      height: isSmallScreen ? 120 : (isMediumScreen ? 130 : 140),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.lightGreen, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(color: Colors.teal, width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Weather image
          Container(
            width: isSmallScreen ? 40 : (isMediumScreen ? 45 : 50),
            height: isSmallScreen ? 40 : (isMediumScreen ? 45 : 50),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(weatherImage, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          // Condition
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              condition,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : (isMediumScreen ? 13 : 14),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          // Temperature
          Text(
            '${temperature.toStringAsFixed(1)}°F',
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : (isMediumScreen ? 11 : 12),
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
