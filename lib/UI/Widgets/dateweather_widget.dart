import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWeatherWidget extends StatelessWidget {
  final String date;
  final String time;
  final String condition;
  final double temperature;

  const DateWeatherWidget({
    super.key,
    required this.date,
    required this.time,
    required this.condition,
    required this.temperature,
  });

  String _formatTime(String time24h) {
    try {
      final parsedTime = DateFormat('HH:mm').parse(time24h);
      return DateFormat('h:mm a').format(parsedTime);
    } catch (e) {
      return time24h;
    }
  }

  String _addOrdinalSuffix(String dateStr) {
    final parts = dateStr.split(' ');
    if (parts.length < 2) return dateStr;

    final month = parts[0];
    final day = int.tryParse(parts[1]) ?? 0;

    // Abbreviate month names
    final Map<String, String> monthAbbreviations = {
      'January': 'Jan',
      'February': 'Feb',
      'March': 'Mar',
      'April': 'Apr',
      'May': 'May',
      'June': 'Jun',
      'July': 'Jul',
      'August': 'Aug',
      'September': 'Sep',
      'October': 'Oct',
      'November': 'Nov',
      'December': 'Dec',
    };

    final abbreviatedMonth = monthAbbreviations[month] ?? month;

    String suffix = 'th';
    if (day % 10 == 1 && day != 11) {
      suffix = 'st';
    } else if (day % 10 == 2 && day != 12) {
      suffix = 'nd';
    } else if (day % 10 == 3 && day != 13) {
      suffix = 'rd';
    }

    return '$abbreviatedMonth $day$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTime = _formatTime(time);
    final String dateWithSuffix = _addOrdinalSuffix(date);
    final String temp = '${temperature.toStringAsFixed(1)}°F';

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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoColumn(
            Icons.calendar_today_outlined,
            'Date',
            dateWithSuffix,
            Colors.teal.shade300,
          ),
          _buildDivider(),
          _buildInfoColumn(
            Icons.access_time_outlined,
            'Time',
            formattedTime,
            Colors.blue.shade300,
          ),
          _buildDivider(),
          _buildInfoColumn(
            Icons.wb_sunny_outlined,
            'Weather',
            condition,
            Colors.amber.shade300,
          ),
          _buildDivider(),
          _buildInfoColumn(
            Icons.thermostat_outlined,
            'Temp',
            temp,
            Colors.orange.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.shade800,
    );
  }
}
