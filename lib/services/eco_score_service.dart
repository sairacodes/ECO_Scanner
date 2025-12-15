// lib/services/eco_score_service.dart

import '../models/product_model.dart';

class EcoScoreService {
  /// Calculate eco-score from product data
  static EcoScore calculateEcoScore(Map<String, dynamic> productData) {
    int score = 50; // Start with neutral score
    List<String> reasons = [];

    // Check packaging materials
    score += _evaluatePackaging(productData, reasons);

    // Check eco-labels
    score += _evaluateEcoLabels(productData, reasons);

    // Check ingredients (if food product)
    score += _evaluateIngredients(productData, reasons);

    // Check manufacturing
    score += _evaluateManufacturing(productData, reasons);

    // Check transportation
    score += _evaluateTransportation(productData, reasons);

    // Ensure score is within bounds
    score = score.clamp(0, 100);

    String grade = _getGradeFromScore(score);
    String rationale = reasons.isNotEmpty
        ? reasons.join(', ')
        : 'Standard environmental impact';

    return EcoScore(
      grade: grade,
      score: score,
      rationale: rationale,
      color: _getColorForGrade(grade),
    );
  }

  /// Evaluate packaging impact
  static int _evaluatePackaging(
    Map<String, dynamic> data,
    List<String> reasons,
  ) {
    int points = 0;
    String? packaging = data['packaging']?.toString().toLowerCase();

    if (packaging == null) return 0;

    // Negative impacts
    if (packaging.contains('plastic')) {
      points -= 15;
      reasons.add('Plastic packaging');
    }
    if (packaging.contains('non-recyclable')) {
      points -= 10;
      reasons.add('Non-recyclable materials');
    }
    if (packaging.contains('styrofoam') || packaging.contains('polystyrene')) {
      points -= 20;
      reasons.add('Styrofoam packaging');
    }

    // Positive impacts
    if (packaging.contains('recyclable')) {
      points += 10;
      reasons.add('Recyclable packaging');
    }
    if (packaging.contains('cardboard') || packaging.contains('paper')) {
      points += 15;
      reasons.add('Biodegradable packaging');
    }
    if (packaging.contains('glass')) {
      points += 12;
      reasons.add('Glass packaging (reusable)');
    }
    if (packaging.contains('minimal') || packaging.contains('reduced')) {
      points += 8;
      reasons.add('Minimal packaging');
    }
    if (packaging.contains('compostable') ||
        packaging.contains('biodegradable')) {
      points += 20;
      reasons.add('Compostable packaging');
    }

    return points;
  }

  /// Evaluate eco-labels and certifications
  static int _evaluateEcoLabels(
    Map<String, dynamic> data,
    List<String> reasons,
  ) {
    int points = 0;
    List? labels = data['labels_tags'];

    if (labels == null || labels.isEmpty) return 0;

    for (var label in labels) {
      String labelStr = label.toString().toLowerCase();

      if (labelStr.contains('organic')) {
        points += 15;
        reasons.add('Organic certified');
        break;
      }
    }

    for (var label in labels) {
      String labelStr = label.toString().toLowerCase();

      if (labelStr.contains('fair-trade') || labelStr.contains('fairtrade')) {
        points += 10;
        reasons.add('Fair Trade certified');
        break;
      }
    }

    for (var label in labels) {
      String labelStr = label.toString().toLowerCase();

      if (labelStr.contains('sustainable') || labelStr.contains('eco')) {
        points += 12;
        reasons.add('Sustainability certification');
        break;
      }
    }

    for (var label in labels) {
      String labelStr = label.toString().toLowerCase();

      if (labelStr.contains('carbon-neutral') ||
          labelStr.contains('carbon neutral')) {
        points += 15;
        reasons.add('Carbon neutral');
        break;
      }
    }

    return points;
  }

  /// Evaluate ingredients (for food products)
  static int _evaluateIngredients(
    Map<String, dynamic> data,
    List<String> reasons,
  ) {
    int points = 0;
    String? ingredients = data['ingredients_text']?.toString().toLowerCase();

    if (ingredients == null) return 0;

    // Check for problematic ingredients
    if (ingredients.contains('palm oil')) {
      points -= 10;
      reasons.add('Contains palm oil');
    }

    // Check for natural ingredients
    if (ingredients.contains('natural') &&
        !ingredients.contains('artificial')) {
      points += 5;
      reasons.add('Natural ingredients');
    }

    // Check for additives
    int additiveCount = data['additives_n'] ?? 0;
    if (additiveCount > 10) {
      points -= 8;
      reasons.add('High number of additives');
    } else if (additiveCount == 0) {
      points += 8;
      reasons.add('No additives');
    }

    return points;
  }

  /// Evaluate manufacturing practices
  static int _evaluateManufacturing(
    Map<String, dynamic> data,
    List<String> reasons,
  ) {
    int points = 0;

    // Check for manufacturing codes that indicate sustainable practices
    List? labels = data['labels_tags'];
    if (labels != null) {
      for (var label in labels) {
        String labelStr = label.toString().toLowerCase();

        if (labelStr.contains('renewable-energy')) {
          points += 10;
          reasons.add('Renewable energy manufacturing');
          break;
        }
      }
    }

    // Check for local production
    String? origin = data['origins']?.toString().toLowerCase();
    String? manufacturingPlaces = data['manufacturing_places']
        ?.toString()
        .toLowerCase();

    if (manufacturingPlaces != null && manufacturingPlaces.isNotEmpty) {
      points += 5;
      reasons.add('Manufacturing location disclosed');
    }

    if (origin != null && origin.isNotEmpty) {
      points += 5;
      reasons.add('Origin disclosed');
    }

    return points;
  }

  /// Evaluate transportation impact
  static int _evaluateTransportation(
    Map<String, dynamic> data,
    List<String> reasons,
  ) {
    int points = 0;

    // Check if product is imported vs local
    List? labels = data['labels_tags'];
    if (labels != null) {
      for (var label in labels) {
        String labelStr = label.toString().toLowerCase();

        if (labelStr.contains('local')) {
          points += 10;
          reasons.add('Locally sourced');
          break;
        }
      }
    }

    return points;
  }

  /// Get grade from score
  static String _getGradeFromScore(int score) {
    if (score >= 80) return 'A';
    if (score >= 60) return 'B';
    if (score >= 40) return 'C';
    if (score >= 20) return 'D';
    return 'E';
  }

  /// Get color for grade
  static String _getColorForGrade(String grade) {
    switch (grade) {
      case 'A':
        return 'green';
      case 'B':
        return 'lightgreen';
      case 'C':
        return 'yellow';
      case 'D':
        return 'orange';
      case 'E':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Get detailed explanation for score
  static String getScoreExplanation(int score) {
    if (score >= 80) {
      return 'Excellent environmental impact! This product has minimal environmental footprint with sustainable packaging, eco-certifications, and responsible sourcing.';
    } else if (score >= 60) {
      return 'Good environmental choice. This product has some sustainable features but there\'s room for improvement in packaging or sourcing.';
    } else if (score >= 40) {
      return 'Moderate environmental impact. Consider alternatives with better sustainability features.';
    } else if (score >= 20) {
      return 'High environmental impact. This product has several negative environmental factors. Look for greener alternatives.';
    } else {
      return 'Very high environmental impact. This product has significant environmental concerns. We strongly recommend choosing a more sustainable alternative.';
    }
  }

  /// Compare two products
  static Map<String, dynamic> compareProducts(
    Product product1,
    Product product2,
  ) {
    int scoreDiff = product2.ecoScore.score - product1.ecoScore.score;

    String improvement = scoreDiff > 0
        ? '$scoreDiff points better'
        : scoreDiff < 0
        ? '${-scoreDiff} points worse'
        : 'Same eco-score';

    List<String> advantages = [];

    // Compare packaging
    if (product2.recyclability.isRecyclable &&
        !product1.recyclability.isRecyclable) {
      advantages.add('Recyclable packaging');
    }

    // Compare score grades
    if (product2.ecoScore.grade.codeUnitAt(0) <
        product1.ecoScore.grade.codeUnitAt(0)) {
      advantages.add(
        'Better eco-grade (${product2.ecoScore.grade} vs ${product1.ecoScore.grade})',
      );
    }

    // Compare eco-labels
    if (product2.ecoLabels.length > product1.ecoLabels.length) {
      advantages.add(
        '${product2.ecoLabels.length - product1.ecoLabels.length} more eco-certifications',
      );
    }

    return {
      'scoreDifference': scoreDiff,
      'improvement': improvement,
      'advantages': advantages,
      'isBetter': scoreDiff > 0,
      'percentageImprovement': product1.ecoScore.score > 0
          ? ((scoreDiff / product1.ecoScore.score) * 100).round()
          : 0,
    };
  }

  /// Get recommendations based on score
  static List<String> getRecommendations(Product product) {
    List<String> recommendations = [];

    if (product.ecoScore.score < 70) {
      recommendations.add('Look for products with Grade A or B eco-scores');
    }

    if (!product.recyclability.isRecyclable) {
      recommendations.add('Choose products with recyclable packaging');
    }

    if (product.ecoLabels.isEmpty) {
      recommendations.add(
        'Consider products with eco-certifications (Organic, Fair Trade, etc.)',
      );
    }

    if (product.packagingType != null &&
        product.packagingType!.toLowerCase().contains('plastic')) {
      recommendations.add('Opt for products with paper or glass packaging');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Great choice! Keep scanning eco-friendly products.');
    }

    return recommendations;
  }

  /// Calculate category average score
  static Future<double> getCategoryAverageScore(
    List<Product> products,
    String category,
  ) async {
    final categoryProducts = products
        .where(
          (p) =>
              p.category?.toLowerCase().contains(category.toLowerCase()) ??
              false,
        )
        .toList();

    if (categoryProducts.isEmpty) return 0.0;

    int totalScore = categoryProducts.fold(
      0,
      (sum, p) => sum + p.ecoScore.score,
    );
    return totalScore / categoryProducts.length;
  }

  /// Get impact level
  static String getImpactLevel(int score) {
    if (score >= 80) return 'Very Low Impact';
    if (score >= 60) return 'Low Impact';
    if (score >= 40) return 'Moderate Impact';
    if (score >= 20) return 'High Impact';
    return 'Very High Impact';
  }

  /// Calculate sustainability percentage
  static int calculateSustainabilityPercentage(List<Product> products) {
    if (products.isEmpty) return 0;

    int greenCount = products.where((p) => p.ecoScore.score >= 70).length;
    return ((greenCount / products.length) * 100).round();
  }
}
