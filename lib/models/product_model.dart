// lib/models/product_model.dart

class Product {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final String? category;
  final EcoScore ecoScore;
  final RecyclabilityInfo recyclability;
  final String? packagingType;
  final List<String> ecoLabels;
  final DateTime scannedAt;

  Product({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.category,
    required this.ecoScore,
    required this.recyclability,
    this.packagingType,
    this.ecoLabels = const [],
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now();

  // Convert from Open Food Facts API response
  factory Product.fromOpenFoodFacts(Map<String, dynamic> product) {
  return Product(
    barcode: product['code'] ?? '',
    name: product['product_name'] ?? 'Unknown Product',
    brand: product['brands'],
    imageUrl: product['image_url'],
    category: product['categories'],
    ecoScore: EcoScore.fromOpenFoodFacts(product),
    recyclability: RecyclabilityInfo.fromOpenFoodFacts(product),
    packagingType: product['packaging'],
    ecoLabels: _extractEcoLabels(product),
  );
}


  // Convert from Firestore
  factory Product.fromFirestore(Map<String, dynamic> data) {
    return Product(
      barcode: data['barcode'] ?? '',
      name: data['name'] ?? 'Unknown Product',
      brand: data['brand'],
      imageUrl: data['imageUrl'],
      category: data['category'],
      ecoScore: EcoScore.fromMap(data['ecoScore'] ?? {}),
      recyclability: RecyclabilityInfo.fromMap(data['recyclability'] ?? {}),
      packagingType: data['packagingType'],
      ecoLabels: List<String>.from(data['ecoLabels'] ?? []),
      scannedAt: DateTime.parse(data['scannedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'category': category,
      'ecoScore': ecoScore.toMap(),
      'recyclability': recyclability.toMap(),
      'packagingType': packagingType,
      'ecoLabels': ecoLabels,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  static List<String> _extractEcoLabels(Map<String, dynamic> product) {
    List<String> labels = [];
    
    if (product['labels_tags'] != null) {
      List<dynamic> labelTags = product['labels_tags'];
      for (var tag in labelTags) {
        String tagStr = tag.toString();
        if (tagStr.contains('organic') || 
            tagStr.contains('fair-trade') || 
            tagStr.contains('sustainable')) {
          labels.add(tag);
        }
      }
    }
    
    return labels;
  }
}

class EcoScore {
  final String grade; // 'A', 'B', 'C', 'D', 'E' or 'Green', 'Moderate', 'Red'
  final int score; // 0-100
  final String rationale;
  final String color; // For UI display

  EcoScore({
    required this.grade,
    required this.score,
    required this.rationale,
    required this.color,
  });

  factory EcoScore.fromOpenFoodFacts(Map<String, dynamic> product) {
    // Open Food Facts provides ecoscore_grade
    String? apiGrade = product['ecoscore_grade']?.toString().toUpperCase();
    int? apiScore = product['ecoscore_score'];
    
    if (apiGrade != null && apiScore != null) {
      return EcoScore(
        grade: apiGrade,
        score: apiScore,
        rationale: _generateRationale(apiGrade, product),
        color: _getColorForGrade(apiGrade),
      );
    }
    
    // Fallback: calculate based on available data
    return _calculateEcoScore(product);
  }

  factory EcoScore.fromMap(Map<String, dynamic> map) {
    return EcoScore(
      grade: map['grade'] ?? 'Unknown',
      score: map['score'] ?? 0,
      rationale: map['rationale'] ?? '',
      color: map['color'] ?? 'grey',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'score': score,
      'rationale': rationale,
      'color': color,
    };
  }

  static EcoScore _calculateEcoScore(Map<String, dynamic> product) {
    int score = 50; // Start neutral
    List<String> reasons = [];

    // Check packaging
    String? packaging = product['packaging']?.toString().toLowerCase();
    if (packaging != null) {
      if (packaging.contains('plastic')) {
        score -= 15;
        reasons.add('Plastic packaging');
      }
      if (packaging.contains('recyclable') || packaging.contains('cardboard')) {
        score += 10;
        reasons.add('Recyclable packaging');
      }
    }

    // Check for eco labels
    List? labels = product['labels_tags'];
    if (labels != null && labels.isNotEmpty) {
      score += 15;
      reasons.add('Has eco-certifications');
    }

    // Ensure score is in range
    score = score.clamp(0, 100);

    String grade = score >= 80 ? 'A' : 
                   score >= 60 ? 'B' : 
                   score >= 40 ? 'C' : 
                   score >= 20 ? 'D' : 'E';

    return EcoScore(
      grade: grade,
      score: score,
      rationale: reasons.join(', '),
      color: _getColorForGrade(grade),
    );
  }

  static String _generateRationale(String grade, Map<String, dynamic> product) {
    if (grade == 'A' || grade == 'B') {
      return 'Excellent environmental impact with sustainable packaging and practices';
    } else if (grade == 'C') {
      return 'Moderate environmental impact, consider alternatives';
    } else {
      return 'High environmental impact, recyclable alternatives recommended';
    }
  }

  static String _getColorForGrade(String grade) {
    switch (grade.toUpperCase()) {
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
}

class RecyclabilityInfo {
  final bool isRecyclable;
  final String recyclingInstructions;
  final List<String> materials;

  RecyclabilityInfo({
    required this.isRecyclable,
    required this.recyclingInstructions,
    required this.materials,
  });

  factory RecyclabilityInfo.fromOpenFoodFacts(Map<String, dynamic> product) {
    String? packaging = product['packaging']?.toString().toLowerCase() ?? '';
    
    bool recyclable = packaging.contains('recyclable') || 
                      packaging.contains('cardboard') ||
                      packaging.contains('glass') ||
                      packaging.contains('metal');
    
    List<String> materials = [];
    if (packaging.contains('plastic')) materials.add('Plastic');
    if (packaging.contains('cardboard')) materials.add('Cardboard');
    if (packaging.contains('glass')) materials.add('Glass');
    if (packaging.contains('metal')) materials.add('Metal');
    
    String instructions = recyclable 
        ? 'Rinse and place in recycling bin' 
        : 'Check local recycling guidelines';
    
    return RecyclabilityInfo(
      isRecyclable: recyclable,
      recyclingInstructions: instructions,
      materials: materials,
    );
  }

  factory RecyclabilityInfo.fromMap(Map<String, dynamic> map) {
    return RecyclabilityInfo(
      isRecyclable: map['isRecyclable'] ?? false,
      recyclingInstructions: map['recyclingInstructions'] ?? '',
      materials: List<String>.from(map['materials'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isRecyclable': isRecyclable,
      'recyclingInstructions': recyclingInstructions,
      'materials': materials,
    };
  }
}