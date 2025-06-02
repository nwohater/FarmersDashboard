import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/gamedata_model.dart'; // Or the correct relative path

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
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (offer.brand.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 6.0),
                child: Text(
                  'Brand: ${offer.brand}',
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Now: ${_currencyFormatter.format(offer.price)}',
                  style: TextStyle(fontSize: 18, color: Colors.green[700], fontWeight: FontWeight.w500),
                ),
                if (offer.originalPrice > 0 && offer.originalPrice != offer.price)
                  Text(
                    'Was: ${_currencyFormatter.format(offer.originalPrice)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[700],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
            if (offer.percentOff > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Chip(
                  label: Text('${offer.percentOff}% OFF',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.orange[700],
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                ),
              ),
            // Bottom row for Months Active and Type
            if (offer.age > 0 || (offer.type != null && offer.type!.isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (offer.age > 0)
                      Text(
                        'Months Active: ${offer.age}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    if (offer.type != null && offer.type!.isNotEmpty)
                      Text(
                        offer.type!,
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54),
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
