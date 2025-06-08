import 'package:flutter/material.dart';
import '../../Models/gamedata_model.dart';

// Helper function (keep as is)
String _getWeatherImage(String? condition) {
  final Map<String, String> conditionToImage = {
    'cloudy': 'assets/images/Cloudy.png',
    'partly cloudy': 'assets/images/PartlyCloudy.png',
    'sunny': 'assets/images/Sunny.png',
    'snow': 'assets/images/Snow.png',
    'storm': 'assets/images/Storm.png',
    'rain': 'assets/images/Rain.png',
    'unknown': 'assets/images/Sunny.png',
    'invalid data': 'assets/images/Sunny.png',
  };
  if (condition == null) return 'assets/images/Sunny.png';
  return conditionToImage[condition.toLowerCase()] ?? 'assets/images/Sunny.png';
}

class ForecastWidget extends StatelessWidget {
  final Weather currentWeatherData;
  final List<dynamic> forecastDynamicItems;

  const ForecastWidget({
    super.key,
    required this.currentWeatherData,
    required this.forecastDynamicItems,
  });

  Widget _buildWeatherItem({
    required String label,
    String? condition,
    double? temperature,
    bool isCurrent = false, // We’ll still keep it to style some details if needed
  }) {
    final String imagePath = _getWeatherImage(condition ?? "Unknown");
    final String displayCondition = condition ?? "N/A";

    // 🔥 Use the same gradient for ALL forecasts
    final Gradient gradient = const LinearGradient(
      colors: [Colors.lightGreen, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(
          color: Colors.teal, // Consistent border color
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Deep teal
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Add a thin border around the weather icon
          Container(
            width: 34, // Slightly larger for border
            height: 34,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(
                  Icons.broken_image,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayCondition,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          if (temperature != null) ...[
            const SizedBox(height: 4),
            Text(
              '${temperature.toStringAsFixed(0)}°F',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastDynamicItems.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemBuilder: (context, index) {
          final dynamic itemDynamic = forecastDynamicItems[index];
          String forecastHour = "N/A";
          String forecastCondition = "Unknown";
          double? forecastTemp;

          if (itemDynamic is Map<String, dynamic>) {
            forecastHour = itemDynamic['hour'] as String? ?? "Hour ${index + 1}";
            forecastCondition = itemDynamic['condition'] as String? ?? "Unknown";
            final tempFromJson = itemDynamic['temperatureF'];
            if (tempFromJson is num) {
              forecastTemp = tempFromJson.toDouble();
            }
          } else {
            forecastHour = "Invalid";
            forecastCondition = "Data";
          }

          return _buildWeatherItem(
            label: forecastHour,
            condition: forecastCondition,
            temperature: forecastTemp,
            isCurrent: index == 0, // First item as current
          );
        },
      ),
    );
  }
}
