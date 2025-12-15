// lib/models/scan_history_model.dart

import 'product_model.dart';

class ScanHistoryItem {
  final String id;
  final String userId;
  final Product product;
  final DateTime scannedAt;
  final String? notes;

  ScanHistoryItem({
    required this.id,
    required this.userId,
    required this.product,
    required this.scannedAt,
    this.notes,
  });

  // Create from Firestore
  factory ScanHistoryItem.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ScanHistoryItem(
      id: id,
      userId: data['userId'] ?? '',
      product: Product.fromFirestore(data['product'] ?? {}),
      scannedAt: data['scannedAt'] != null
          ? DateTime.parse(data['scannedAt'])
          : DateTime.now(),
      notes: data['notes'],
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'product': product.toFirestore(),
      'scannedAt': scannedAt.toIso8601String(),
      'notes': notes,
    };
  }

  // Create from Product
  factory ScanHistoryItem.fromProduct(
    String userId,
    Product product, {
    String? notes,
  }) {
    return ScanHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      product: product,
      scannedAt: DateTime.now(),
      notes: notes,
    );
  }

  // Copy with
  ScanHistoryItem copyWith({
    String? id,
    String? userId,
    Product? product,
    DateTime? scannedAt,
    String? notes,
  }) {
    return ScanHistoryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      product: product ?? this.product,
      scannedAt: scannedAt ?? this.scannedAt,
      notes: notes ?? this.notes,
    );
  }

  // Get formatted date
  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(scannedAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${scannedAt.day}/${scannedAt.month}/${scannedAt.year}';
    }
  }
}

// Group history by date
class HistoryGroup {
  final String date;
  final List<ScanHistoryItem> items;

  HistoryGroup({
    required this.date,
    required this.items,
  });

  // Create groups from list of history items
  static List<HistoryGroup> groupByDate(List<ScanHistoryItem> items) {
    Map<String, List<ScanHistoryItem>> grouped = {};

    for (var item in items) {
      String dateKey = _getDateKey(item.scannedAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(item);
    }

    List<HistoryGroup> groups = [];
    grouped.forEach((date, items) {
      groups.add(HistoryGroup(date: date, items: items));
    });

    // Sort groups by date (newest first)
    groups.sort((a, b) => b.date.compareTo(a.date));

    return groups;
  }

  static String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final scanDate = DateTime(date.year, date.month, date.day);

    if (scanDate == today) {
      return 'Today';
    } else if (scanDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(scanDate).inDays < 7) {
      return _getDayOfWeek(date.weekday);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}