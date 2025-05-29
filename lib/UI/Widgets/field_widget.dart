import 'package:flutter/material.dart';
import '../../Models/gamedata_model.dart';

class FieldWidget extends StatelessWidget {
  final Field field;

  const FieldWidget({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final acres = (field.fieldAreaHa * 2.47105).toStringAsFixed(2);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.green.shade200, width: 0.5),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        width: double.infinity, // Fill the parent width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Field ID (left), Crop (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Field ID: ${field.fieldId}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Crop: ${field.fruitType}",
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Bottom Row: Growth (left), Acres (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Growth: ${field.growthStateLabel}"),
                //(${field.growthState})
                Text("Area: $acres acres"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
