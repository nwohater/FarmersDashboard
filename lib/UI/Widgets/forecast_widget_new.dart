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

  Widget _buildForecastColumn(String hour, String condition) {
    final String imagePath = _getWeatherImage(condition);

    return Column(
      children: [
        Icon(Icons.access_time_outlined, color: Colors.blue.shade300, size: 22),
        const SizedBox(height: 8),
        Text(
          'Time',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hour,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Icon(Icons.wb_sunny_outlined, color: Colors.amber.shade300, size: 22),
        const SizedBox(height: 8),
        Text(
          'Weather',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          condition,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 120,
      color: Colors.grey.shade800,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse forecast items (limit to 4)
    List<Map<String, dynamic>> forecasts = [];
    for (int i = 0; i < forecastDynamicItems.length && i < 4; i++) {
      final dynamic itemDynamic = forecastDynamicItems[i];
      String forecastHour = "N/A";
      String forecastCondition = "Unknown";

      if (itemDynamic is Map<String, dynamic>) {
        forecastHour = itemDynamic['hour'] as String? ?? "Hour ${i + 1}";
        forecastCondition = itemDynamic['condition'] as String? ?? "Unknown";
      }

      forecasts.add({
        'hour': forecastHour,
        'condition': forecastCondition,
      });
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.teal.shade800.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildForecastColumn(
              forecasts.isNotEmpty ? forecasts[0]['hour'] as String : "N/A",
              forecasts.isNotEmpty ? forecasts[0]['condition'] as String : "Unknown",
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildForecastColumn(
              forecasts.length > 1 ? forecasts[1]['hour'] as String : "N/A",
              forecasts.length > 1 ? forecasts[1]['condition'] as String : "Unknown",
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildForecastColumn(
              forecasts.length > 2 ? forecasts[2]['hour'] as String : "N/A",
              forecasts.length > 2 ? forecasts[2]['condition'] as String : "Unknown",
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildForecastColumn(
              forecasts.length > 3 ? forecasts[3]['hour'] as String : "N/A",
              forecasts.length > 3 ? forecasts[3]['condition'] as String : "Unknown",
            ),
          ),
        ],
      ),
    );
  }
}

