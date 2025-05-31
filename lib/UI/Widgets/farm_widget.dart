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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm name row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  farmName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _currencyFormatter.format(money),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: money < 0 ? Colors.red[700] : Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Loan row, if applicable
          if (loanAmount != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Debt:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blueGrey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  loanAmount! > 0
                      ? _currencyFormatter.format(loanAmount)
                      : 'Debt Free!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: loanAmount! > 0
                        ? Colors.red
                        : Colors.green[700],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
