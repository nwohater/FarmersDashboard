import 'package:flutter/material.dart';
import '../../Models/gamedata_model.dart';

// Helper function (ensure this is available or defined within the widget)
String _getWeatherImage(String? condition) { // Make condition nullable
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
  if (condition == null) return 'assets/images/Sunny.png'; // Default for null condition
  return conditionToImage[condition.toLowerCase()] ?? 'assets/images/Sunny.png';
}

class ForecastWidget extends StatelessWidget {
  final Weather currentWeatherData; // From GameData.weather
  final List<dynamic> forecastDynamicItems; // From GameData.weather.forecast

  const ForecastWidget({
    super.key,
    required this.currentWeatherData,
    required this.forecastDynamicItems,
  });

  Widget _buildWeatherItem({
    required String label,
    String? condition, // Condition can now be null if data is missing/malformed
    double? temperature,
    bool isCurrent = false,
  }) {
    final String imagePath = _getWeatherImage(condition ?? "Unknown"); // Provide default
    final String displayCondition = condition ?? "N/A";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      margin: EdgeInsets.only(right: isCurrent ? 0 : 8.0),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.blueGrey[50]?.withOpacity(0.7) : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent ? Colors.blueAccent : Colors.teal[700]!,
          width: isCurrent ? 1.5 : 1.0,
        ),
      ),
      constraints: BoxConstraints(minWidth: isCurrent ? 100 : 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isCurrent ? 16 : 14,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isCurrent ? 8 : 4),
          Image.asset(
            imagePath,
            width: isCurrent ? 60 : 40,
            height: isCurrent ? 60 : 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.broken_image, size: isCurrent ? 60 : 40, color: Colors.white70),
          ),
          SizedBox(height: isCurrent ? 8 : 4),
          Text(
            displayCondition,
            style: TextStyle(
              fontSize: isCurrent ? 14 : 12,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          if (temperature != null) ...[
            SizedBox(height: 4),
            Text(
              '${temperature.toStringAsFixed(0)}°F',
              style: TextStyle(
                fontSize: isCurrent ? 14 : 12,
                color: Colors.white70,
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
    // Widget currentWeatherDisplay = _buildWeatherItem(
    //   label: "Now",
    //   condition: currentWeatherData.condition,
    //   temperature: currentWeatherData.temperatureF,
    //   isCurrent: true,
    // );

    // if (forecastDynamicItems.isEmpty) {
    //   return Row(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [currentWeatherDisplay],
    //   );
    // }

// The Container provides padding and a fixed height for the horizontal list
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding for top/bottom
      height: 155, // Overall height for the forecast section
      child: Center(     // <--- Center the ListView
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: forecastDynamicItems.length,
          shrinkWrap: true, // Allow ListView to size itself to its content horizontally
          physics: const ClampingScrollPhysics(), // Good for contained lists
          // Optional: Add padding around the list itself if needed,
          // for instance, if you don't want it to touch the edges when centered.
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
              print('Warning: Forecast item at index $index is not a Map: $itemDynamic');
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
      ),
    );
  }
}