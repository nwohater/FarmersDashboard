import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Make sure this import is present

class FarmWidget extends StatelessWidget {
  final String farmName;
  final double money;

  // Static formatter for efficiency, created only once
  static final NumberFormat _currencyFormatter =
  NumberFormat.currency(locale: 'en_US', symbol: '\$');
  // For other locales/symbols, you might not make it static if the widget
  // needs to adapt based on context passed to it. But for a fixed '$', static is good.

  const FarmWidget({
    super.key,
    required this.farmName,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Example styling - adjust as needed
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50], // A light background color for the card
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row( // Using a Row for better layout of name and money
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Puts space between name and money
        children: [
          Expanded( // Allows farmName to take available space and wrap if too long
            child: Text(
              farmName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
              overflow: TextOverflow.ellipsis, // Handle long farm names
            ),
          ),
          SizedBox(width: 16), // Some space between name and money
          Text(
            _currencyFormatter.format(money), // Use the formatter here
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: money < 0 ? Colors.red[700] : Colors.green[700], // Different color for negative
            ),
          ),
        ],
      ),
    );
  }
}