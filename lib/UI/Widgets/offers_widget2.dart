import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/gamedata_model.dart';

class SpecialOfferWidget extends StatelessWidget {
  final SpecialOffer offer;

  const SpecialOfferWidget({
    super.key,
    required this.offer,
  });

  static final _currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.lightGreen, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Text(
              offer.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const Divider(height: 5, thickness: 1, color: Colors.grey),
            const SizedBox(height: 4),
            // Brand row
            if (offer.brand.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.agriculture, color: Colors.black, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      offer.brand,
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            // Price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Now: ${_currencyFormatter.format(offer.price)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2E7D32), // Vibrant green
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (offer.originalPrice > 0 && offer.originalPrice != offer.price)
                  Text(
                    'Was: ${_currencyFormatter.format(offer.originalPrice)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
            // Discount chip
            if (offer.percentOff > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.deepOrange, size: 20),
                    const SizedBox(width: 4),
                    Chip(
                      label: Text(
                        '${offer.percentOff}% OFF',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    ),
                  ],
                ),
              ),
            // Bottom row for months active & type
            if (offer.age > 0 || (offer.type != null && offer.type!.isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (offer.age > 0)
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            'Months: ${offer.age}',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    if (offer.type != null && offer.type!.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.lightGreenAccent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        child: Text(
                          offer.type!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
