import 'package:flutter/material.dart';
import '../../Models/gamedata_model.dart';

class FieldWidget extends StatelessWidget {
  final Field field;
  final int currentMonth;

  const FieldWidget({super.key, required this.field, required this.currentMonth});

  /// Parse total stages from the growthStateLabel (e.g., "6/7" -> 7)
  int _parseTotalStages(String label) {
    final regex = RegExp(r'\((\d+)\/(\d+)\)');
    final match = regex.firstMatch(label);
    if (match != null && match.groupCount == 2) {
      final parsed = int.tryParse(match.group(2)!);
      return parsed ?? 5;
    }
    return 5; // fallback
  }

  /// Calculate expected harvest month if still growing
  String? _expectedHarvestMonth(int growthState, int totalStages, int currentMonth) {
    if (growthState > 0 && growthState < totalStages) {
      final monthsToHarvest = (totalStages - growthState) + 1;
      int harvestMonth = currentMonth + monthsToHarvest;
      if (harvestMonth > 12) harvestMonth -= 12;

      final monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return monthNames[harvestMonth - 1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final acres = (field.fieldAreaHa * 2.47105).toStringAsFixed(2);
    final bool harvested = field.growthStateLabel.toLowerCase() == 'harvested';
    final bool readyToHarvest = field.growthStateLabel.toLowerCase() == 'ready to harvest';
    final Color bgColor = harvested
        ? Colors.brown.shade100
        : readyToHarvest
        ? Colors.yellow.shade100
        : Colors.green.shade50;

    // Dynamically parse total stages from the label
    final int totalStages = _parseTotalStages(field.growthStateLabel);

    // Only show expected harvest if not ready
    final String? expectedMonth = !readyToHarvest
        ? _expectedHarvestMonth(
      field.growthState,
      totalStages,
      currentMonth, // +1 to adjust for 0-indexed month
    )
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal, width: 1), // 🟩 Thin teal border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                Text("Area: $acres acres"),
              ],
            ),
            if (expectedMonth != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "Expected Harvest: $expectedMonth",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
