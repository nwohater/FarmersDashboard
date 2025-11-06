import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/gamedata_model.dart';

class SpecialOfferWidget extends StatelessWidget {
  final SpecialOffer offer;

  const SpecialOfferWidget({
    super.key,
    required this.offer,
  });

  static final _currencyFormatter =
  NumberFormat.currency(locale: 'en_US', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          color: Colors.amber.shade900.withOpacity(0.3),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (offer.brand.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.local_offer_outlined,
                        color: Colors.amber.shade300, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      offer.brand,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              if (offer.percentOff > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade700.withOpacity(0.5)),
                  ),
                  child: Text(
                    '${offer.percentOff}% OFF',
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            offer.name,
            style: TextStyle(
              color: Colors.grey.shade100,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          if (offer.type != null && offer.type!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              offer.type!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade800, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sale Price',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormatter.format(offer.price),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade300,
                    ),
                  ),
                ],
              ),
              if (offer.originalPrice > 0 && offer.originalPrice != offer.price)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Original',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormatter.format(offer.originalPrice),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (offer.age > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.history, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'Age: ${offer.age} months',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
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

