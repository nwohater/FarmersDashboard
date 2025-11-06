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
    final netWorth = loanAmount != null ? money - loanAmount! : money;
    final isPositive = netWorth >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.agriculture_outlined,
                  color: Colors.teal.shade300,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  farmName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade100,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade800, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStatColumn(
                  'Balance',
                  _currencyFormatter.format(money),
                  Colors.teal.shade300,
                  Icons.account_balance_wallet_outlined,
                ),
              ),
              if (loanAmount != null && loanAmount! > 0) ...[
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade800,
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Loan',
                    _currencyFormatter.format(loanAmount),
                    Colors.red.shade300,
                    Icons.trending_down,
                  ),
                ),
              ],
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade800,
              ),
              Expanded(
                child: _buildStatColumn(
                  'Net Worth',
                  _currencyFormatter.format(netWorth),
                  isPositive ? Colors.green.shade300 : Colors.red.shade300,
                  isPositive ? Icons.trending_up : Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
