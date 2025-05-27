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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 160, // Slightly larger than the image size for padding
          height: 160,
          decoration: BoxDecoration(
            color: Colors.teal[700]!, // Black box background
            border: Border.all(
              color: Colors.teal[700]!, // Black border
              width: 1.0, // Border thickness
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0), // Padding inside the black box
            child: Image.asset(
              weatherImage,
              fit: BoxFit.contain, // Ensure the image fits neatly
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Weather Condition Text
        Text(
          condition,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),

        // Temperature Display
        Text(
          '${temperature.toStringAsFixed(1)}°F', // Format to 1 decimal place
          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
