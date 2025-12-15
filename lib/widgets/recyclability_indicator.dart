import 'package:flutter/material.dart';
import '../models/product_model.dart';

class RecyclabilityIndicator extends StatelessWidget {
  final RecyclabilityInfo recyclability;

  const RecyclabilityIndicator({
    super.key,
    required this.recyclability,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: recyclability.isRecyclable
            ? Colors.green[50]
            : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: recyclability.isRecyclable
              ? Colors.green[200]!
              : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            recyclability.isRecyclable ? Icons.recycling : Icons.warning,
            color: recyclability.isRecyclable ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recyclability.isRecyclable
                      ? 'Recyclable'
                      : 'Check Local Guidelines',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: recyclability.isRecyclable
                        ? Colors.green[900]
                        : Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recyclability.recyclingInstructions,
                  style: TextStyle(
                    fontSize: 12,
                    color: recyclability.isRecyclable
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}