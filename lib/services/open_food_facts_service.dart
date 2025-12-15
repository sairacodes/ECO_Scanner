import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class OpenFoodFactsService {
  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v0/product';

  /// Fetch product using barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$_baseUrl/$barcode.json');
      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      final Map<String, dynamic> data = jsonDecode(response.body);

      // Product not found
      if (data['status'] != 1 || data['product'] == null) {
        return null;
      }

      // IMPORTANT: pass data['product'], not whole response
      return Product.fromOpenFoodFacts(data['product']);
    } catch (e) {
      print('OpenFoodFactsService error: $e');
      return null;
    }
  }

  Future<List<Product>> findAlternatives(Product originalProduct) async {
    try {
      // If no category, we can't search alternatives
      if (originalProduct.category == null ||
          originalProduct.category!.isEmpty) {
        return [];
      }

      // Open Food Facts category search API
      final url = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl'
        '?search_terms='
        '&search_simple=1'
        '&action=process'
        '&json=1'
        '&page_size=20'
        '&tagtype_0=categories'
        '&tag_contains_0=contains'
        '&tag_0=${Uri.encodeComponent(originalProduct.category!)}',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return [];

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List products = data['products'] ?? [];

      List<Product> alternatives = [];

      for (var item in products) {
        try {
          final product = Product.fromOpenFoodFacts(item);

          // Only include greener alternatives
          if (product.ecoScore.score > originalProduct.ecoScore.score) {
            alternatives.add(product);
          }
        } catch (_) {
          // Skip invalid products
        }
      }

      // Sort by eco-score (best first)
      alternatives.sort((a, b) => b.ecoScore.score.compareTo(a.ecoScore.score));

      return alternatives.take(10).toList();
    } catch (e) {
      print('findAlternatives error: $e');
      return [];
    }
  }
}
