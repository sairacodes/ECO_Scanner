import 'package:flutter/material.dart';
import '../models/product_model.dart';

class EcoScoreBadge extends StatelessWidget {
  final EcoScore ecoScore;
  final double size;

  const EcoScoreBadge({
    super.key,
    required this.ecoScore,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    Color color = _getColorFromString(ecoScore.color);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          ecoScore.grade,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'lightgreen':
        return Colors.lightGreen;
      case 'yellow':
        return Colors.yellow[700]!;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}