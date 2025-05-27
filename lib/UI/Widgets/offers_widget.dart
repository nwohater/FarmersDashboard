import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/gamedata_model.dart'; // Or the correct relative path

class SpecialOfferWidget extends StatelessWidget {
  final SpecialOffer offer;

  const SpecialOfferWidget({
    super.key,
    required this.offer,
  });

  // Using a static formatter for currency can be efficient
  static final _currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Added horizontal margin
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.name, // From your SpecialOffer model
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (offer.brand.isNotEmpty) // From your SpecialOffer model
              Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 6.0),
                child: Text(
                  'Brand: ${offer.brand}', // From your SpecialOffer model
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Now: ${_currencyFormatter.format(offer.price)}', // From your SpecialOffer model
                  style: TextStyle(fontSize: 18, color: Colors.green[700], fontWeight: FontWeight.w500),
                ),
                if (offer.originalPrice > 0 && offer.originalPrice != offer.price)
                  Text(
                    'Was: ${_currencyFormatter.format(offer.originalPrice)}', // From your SpecialOffer model
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[700],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
            if (offer.percentOff > 0) // From your SpecialOffer model
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Chip( // Using a Chip for the discount percentage
                  label: Text('${offer.percentOff}% OFF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.orange[700],
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                ),
              ),
            if (offer.age > 0) // Assuming 'age' is meaningful to display, e.g., days old
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Months Active: ${offer.age}', // Adjust based on what 'age' represents
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}