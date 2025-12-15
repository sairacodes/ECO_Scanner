import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== SCAN HISTORY ====================

  Future<void> addToHistory(String userId, Product product) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scan_history')
          .add({
        ...product.toFirestore(),
        'scannedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save to history: $e');
    }
  }

  Stream<List<Product>> getHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_history')
        .orderBy('scannedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return Product.fromFirestore(doc.data());
              } catch (_) {
                return null;
              }
            })
            .whereType<Product>()
            .toList());
  }

  Future<void> clearHistory(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_history')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ==================== FAVORITES ====================

  Future<void> addToFavorites(String userId, Product product) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(product.barcode)
        .set(product.toFirestore());
  }

  Future<void> removeFromFavorites(String userId, String barcode) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(barcode)
        .delete();
  }

  Future<bool> isFavorite(String userId, String barcode) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(barcode)
        .get();

    return doc.exists;
  }

  Stream<List<Product>> getFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return Product.fromFirestore(doc.data());
              } catch (_) {
                return null;
              }
            })
            .whereType<Product>()
            .toList());
  }

  // ==================== ANALYTICS ====================

  Future<Map<String, int>> getWeeklyAnalytics(String userId) async {
    final weekAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 7)),
    );

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_history')
        .where('scannedAt', isGreaterThan: weekAgo)
        .get();

    int green = 0, moderate = 0, red = 0;

    for (var doc in snapshot.docs) {
      try {
        final product = Product.fromFirestore(doc.data());
        final score = product.ecoScore.score;

        if (score >= 70) {
          green++;
        } else if (score >= 40) {
          moderate++;
        } else {
          red++;
        }
      } catch (_) {}
    }

    return {
      'green': green,
      'moderate': moderate,
      'red': red,
      'total': snapshot.docs.length,
    };
  }

  // ==================== CUSTOM PRODUCTS ====================

  Future<void> addCustomProduct(Product product) async {
    await _firestore
        .collection('custom_products')
        .doc(product.barcode)
        .set(product.toFirestore());
  }

  Future<Product?> getCustomProduct(String barcode) async {
    final doc = await _firestore
        .collection('custom_products')
        .doc(barcode)
        .get();

    if (doc.exists && doc.data() != null) {
      return Product.fromFirestore(doc.data()!);
    }
    return null;
  }

  // ==================== USER PROFILE ====================

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }
}
