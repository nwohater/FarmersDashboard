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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Colors.lightGreen, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 4)),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 5,
        alignment: WrapAlignment.center,
        children: [
          _stripItem('🗓', dateWithSuffix),
          _stripItem('⏰', formattedTime),
          _stripItem('🌤️', condition),
          _stripItem('🌡️', temp),
        ],
      ),
    );
  }

  Widget _stripItem(String emoji, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
