import 'package:flutter/material.dart';


class DateWidget extends StatelessWidget {
  final String Date;
  final String Time;

  const DateWidget({
    super.key,
    required this.Date,
    required this.Time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Date, // Display the current date
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        Text(
          Time, // Display the current time
          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
