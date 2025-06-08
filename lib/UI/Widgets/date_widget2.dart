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
      return time24h;
    }
  }

  String _addOrdinalSuffix(String dateStr) {
    final parts = dateStr.split(' ');
    if (parts.length < 2) return dateStr;

    final day = int.tryParse(parts[1]) ?? 0;

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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            dateWithSuffix,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.access_time, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
