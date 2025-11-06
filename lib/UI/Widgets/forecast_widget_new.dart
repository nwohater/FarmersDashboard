import 'package:flutter/material.dart';
import '../../Models/gamedata_model.dart';

// Helper function
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
  }) {
    final String imagePath = _getWeatherImage(condition ?? "Unknown");
    final String displayCondition = condition ?? "N/A";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.teal.shade800.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.teal.shade900.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.cloud_outlined,
                  size: 24,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayCondition,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (temperature != null) ...[
            const SizedBox(height: 4),
            Text(
              '${temperature.toStringAsFixed(0)}°F',
              style: TextStyle(
                fontSize: 13,
                color: Colors.teal.shade300,
                fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          );
        },
      ),
    );
  }
}

