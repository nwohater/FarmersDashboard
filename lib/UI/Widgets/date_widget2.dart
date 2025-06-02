import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  final String Date;
  final String Time;

  const DateWidget({
    super.key,
    required this.Date,
    required this.Time,
  });

  String _formatTime(String time24h) {
    try {
      final parsedTime = DateFormat('HH:mm').parse(time24h);
      return DateFormat('h:mm a').format(parsedTime);
    } catch (e) {
      return time24h; // fallback in case of error
    }
  }

  String _addOrdinalSuffix(String dateStr) {
    // Assume format "Month Day" (e.g., "June 1" or "June 21")
    final parts = dateStr.split(' ');
    if (parts.length < 2) return dateStr;

    final dayStr = parts[1];
    final day = int.tryParse(dayStr) ?? 0;

    String suffix = 'th';
    if (day % 10 == 1 && day != 11) {
      suffix = 'st';
    } else if (day % 10 == 2 && day != 12) {
      suffix = 'nd';
    } else if (day % 10 == 3 && day != 13) {
      suffix = 'rd';
    }

    return '${parts[0]} $day$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTime = _formatTime(Time);
    final String dateWithSuffix = _addOrdinalSuffix(Date);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green[400],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateWithSuffix,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
