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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      width: 100, // Increased from 80
      height: 140, // Increased from 120
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
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
        border: Border.all(
          color: Colors.teal,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Weather image
          Container(
            width: 50, // Increased from 40
            height: 50, // Increased from 40
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                weatherImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8), // Slightly more spacing
          // Condition
          Text(
            condition,
            style: const TextStyle(
              fontSize: 14, // Increased from 12
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Temperature
          Text(
            '${temperature.toStringAsFixed(1)}°F',
            style: const TextStyle(
              fontSize: 12, // Increased from 10
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
