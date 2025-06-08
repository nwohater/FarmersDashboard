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
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF388E3C), Color(0xFF81C784)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Brand and Bank of Debt
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (offer.brand.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.agriculture,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        offer.brand,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(blurRadius: 2, color: Colors.black45)
                          ],
                        ),
                      ),
                    ],
                  ),
                Text(
                  'BANK OF DEBT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 1.2,
                    shadows: const [Shadow(blurRadius: 1, color: Colors.black26)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Name and type
            Text(
              offer.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 2, color: Colors.black45)],
              ),
            ),
            if (offer.type != null && offer.type!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  offer.type!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Pricing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currencyFormatter.format(offer.price),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                  ),
                ),
                if (offer.originalPrice > 0 &&
                    offer.originalPrice != offer.price)
                  Text(
                    _currencyFormatter.format(offer.originalPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
            // Extra info row (Discount, Age)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (offer.percentOff > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Chip(
                      backgroundColor: Colors.deepOrange,
                      label: Text(
                        '${offer.percentOff}% OFF',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                    ),
                  ),
                if (offer.age > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          'Months: ${offer.age}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

