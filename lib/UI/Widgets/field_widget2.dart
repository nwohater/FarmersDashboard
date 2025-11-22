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

    // Special handling for grass - check if it's the second harvest stage
    final bool isGrass = field.fruitType.toLowerCase() == 'grass';
    final bool isSecondHarvest = isGrass && field.growthState == 3;
    final bool isFirstHarvest = isGrass && readyToHarvest && field.growthState != 3;

    // Dynamically parse total stages from the label
    final int totalStages = _parseTotalStages(field.growthStateLabel);

    // Only show expected harvest if not ready
    final String? expectedMonth = !readyToHarvest
        ? _expectedHarvestMonth(
            field.growthState,
            totalStages,
            currentMonth,
          )
        : null;

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    String displayLabel;

    if (harvested) {
      statusColor = Colors.brown.shade400;
      statusIcon = Icons.check_circle_outline;
      displayLabel = field.growthStateLabel;
    } else if (isSecondHarvest) {
      // Grass at growth state 3 - second harvest ready
      statusColor = Colors.orange.shade400;
      statusIcon = Icons.agriculture;
      displayLabel = 'Ready To Harvest (Stage 2)';
    } else if (isFirstHarvest) {
      // Grass at first harvest stage
      statusColor = Colors.amber.shade400;
      statusIcon = Icons.agriculture;
      displayLabel = 'Ready To Harvest (Stage 1)';
    } else if (readyToHarvest) {
      statusColor = Colors.amber.shade400;
      statusIcon = Icons.agriculture;
      displayLabel = field.growthStateLabel;
    } else {
      statusColor = Colors.green.shade400;
      statusIcon = Icons.spa_outlined;
      displayLabel = field.growthStateLabel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              const SizedBox(width: 8),
              Text(
                "Field ${field.fieldId}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.grey.shade300,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  field.fruitType,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(
                'Growth',
                displayLabel,
                Colors.grey.shade400,
              ),
              _buildInfoChip(
                'Area',
                '$acres ac',
                Colors.teal.shade300,
              ),
            ],
          ),
          if (expectedMonth != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade900.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.orange.shade300),
                  const SizedBox(width: 6),
                  Text(
                    "Est. Harvest: $expectedMonth",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
