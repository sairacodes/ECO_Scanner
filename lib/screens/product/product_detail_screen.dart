// lib/screens/product/product_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
// import '../../services/open_food_facts_service.dart';
import 'alternatives_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String userId;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.userId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final isFav = await _firestoreService.isFavorite(
      widget.userId,
      widget.product.barcode,
    );
    setState(() {
      _isFavorite = isFav;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await _firestoreService.removeFromFavorites(
          widget.userId,
          widget.product.barcode,
        );
      } else {
        await _firestoreService.addToFavorites(
          widget.userId,
          widget.product,
        );
      }
      setState(() => _isFavorite = !_isFavorite);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.green,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: _toggleFavorite,
              color: _isFavorite ? Colors.red : null,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),
                  const SizedBox(height: 20),
                  _buildEcoScoreCard(),
                  const SizedBox(height: 20),
                  _buildRecyclabilityCard(),
                  const SizedBox(height: 20),
                  _buildEcoLabels(),
                  const SizedBox(height: 20),
                  _buildRecommendations(),
                  const SizedBox(height: 20),
                  _buildAlternativesButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.grey[200],
      child: widget.product.imageUrl != null
          ? Image.network(
              widget.product.imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.product.brand != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.product.brand!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
        if (widget.product.category != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.product.category!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEcoScoreCard() {
    final ecoScore = widget.product.ecoScore;
    Color scoreColor = _getColorFromString(ecoScore.color);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Eco-Score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: scoreColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      ecoScore.grade,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score: ${ecoScore.score}/100',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ecoScore.rationale,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecyclabilityCard() {
    final recyclability = widget.product.recyclability;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  recyclability.isRecyclable ? Icons.recycling : Icons.delete,
                  color: recyclability.isRecyclable ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recyclability',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  recyclability.isRecyclable ? Icons.check_circle : Icons.warning,
                  color: recyclability.isRecyclable ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  recyclability.isRecyclable ? 'Recyclable' : 'Check Guidelines',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recyclability.recyclingInstructions,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (recyclability.materials.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: recyclability.materials.map((material) {
                  return Chip(
                    label: Text(material),
                    backgroundColor: Colors.green[100],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEcoLabels() {
    if (widget.product.ecoLabels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Eco-Certifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.product.ecoLabels.map((label) {
                return Chip(
                  label: Text(label),
                  backgroundColor: Colors.green[100],
                  avatar: const Icon(Icons.check, size: 16),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    String recommendation;
    IconData icon;
    Color color;

    if (widget.product.ecoScore.score >= 70) {
      recommendation = '✓ Great choice! This product has a low environmental impact.';
      icon = Icons.thumb_up;
      color = Colors.green;
    } else if (widget.product.ecoScore.score >= 40) {
      recommendation = 'Good product, but consider checking alternatives for better options.';
      icon = Icons.info;
      color = Colors.orange;
    } else {
      recommendation = 'Consider switching to a more sustainable alternative.';
      icon = Icons.warning;
      color = Colors.red;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                recommendation,
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativesButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlternativesScreen(
                originalProduct: widget.product,
                userId: widget.userId,
              ),
            ),
          );
        },
        icon: const Icon(Icons.compare_arrows),
        label: const Text('Find Greener Alternatives'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
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