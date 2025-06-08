import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FarmWidget extends StatelessWidget {
  final String farmName;
  final double money;
  final double? loanAmount;

  static final NumberFormat _currencyFormatter =
  NumberFormat.currency(locale: 'en_US', symbol: '\$');

  const FarmWidget({
    super.key,
    required this.farmName,
    required this.money,
    this.loanAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.yellow, Colors.white], // Teal gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Farm icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.agriculture,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Farm details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Farm name
                Text(
                  farmName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Money & Debt
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currencyFormatter.format(money),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: money < 0 ? Colors.red[700] : Colors.green[800],
                      ),
                    ),
                    if (loanAmount != null)
                      Text(
                        loanAmount! > 0
                            ? 'Debt: ${_currencyFormatter.format(loanAmount)}'
                            : 'Debt Free!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: loanAmount! > 0
                              ? Colors.red
                              : Colors.green[700],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
