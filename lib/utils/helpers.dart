import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';

class Helpers {
  // Format date for display
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Get color for eco-score
  static Color getEcoScoreColor(int score) {
    if (score >= AppConstants.excellentScoreThreshold) {
      return AppConstants.gradeAColor;
    } else if (score >= AppConstants.goodScoreThreshold) {
      return AppConstants.gradeBColor;
    } else if (score >= AppConstants.moderateScoreThreshold) {
      return AppConstants.gradeCColor;
    } else if (score >= AppConstants.poorScoreThreshold) {
      return AppConstants.gradeDColor;
    } else {
      return AppConstants.gradeEColor;
    }
  }

  // Get eco-score grade from score
  static String getEcoScoreGrade(int score) {
    if (score >= AppConstants.excellentScoreThreshold) {
      return 'A';
    } else if (score >= AppConstants.goodScoreThreshold) {
      return 'B';
    } else if (score >= AppConstants.moderateScoreThreshold) {
      return 'C';
    } else if (score >= AppConstants.poorScoreThreshold) {
      return 'D';
    } else {
      return 'E';
    }
  }

  // Get eco-score description
  static String getEcoScoreDescription(int score) {
    if (score >= AppConstants.excellentScoreThreshold) {
      return 'Excellent - Very low environmental impact';
    } else if (score >= AppConstants.goodScoreThreshold) {
      return 'Good - Low environmental impact';
    } else if (score >= AppConstants.moderateScoreThreshold) {
      return 'Moderate - Average environmental impact';
    } else if (score >= AppConstants.poorScoreThreshold) {
      return 'Poor - High environmental impact';
    } else {
      return 'Very Poor - Very high environmental impact';
    }
  }

  // Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validate password
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Validate name
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // Show success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show info snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Format barcode for display
  static String formatBarcode(String barcode) {
    if (barcode.length <= 4) return barcode;
    return '${barcode.substring(0, 4)}...${barcode.substring(barcode.length - 4)}';
  }

  // Check if string is barcode
  static bool isBarcode(String value) {
    return RegExp(r'^\d{8,14}$').hasMatch(value);
  }

  // Get recyclability icon
  static IconData getRecyclabilityIcon(bool isRecyclable) {
    return isRecyclable ? Icons.recycling : Icons.delete;
  }

  // Get recyclability color
  static Color getRecyclabilityColor(bool isRecyclable) {
    return isRecyclable ? Colors.green : Colors.orange;
  }

  // Calculate percentage
  static int calculatePercentage(int value, int total) {
    if (total == 0) return 0;
    return ((value / total) * 100).round();
  }

  // Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Get impact message based on weekly stats
  static String getWeeklyImpactMessage(Map<String, int> analytics) {
    final total = analytics['total'] ?? 0;
    final green = analytics['green'] ?? 0;

    if (total == 0) {
      return 'Start scanning products to track your environmental impact!';
    }

    final percentage = calculatePercentage(green, total);

    if (percentage >= 70) {
      return '🌟 Amazing! $percentage% of your choices are eco-friendly!';
    } else if (percentage >= 50) {
      return '👍 Good work! $percentage% of your choices are sustainable.';
    } else if (percentage >= 30) {
      return '💪 Keep going! Try to increase your eco-friendly choices.';
    } else {
      return '🌱 Every green choice matters! Let\'s aim higher together.';
    }
  }

  // Decode barcode type
  static String getBarcodeType(String barcode) {
    switch (barcode.length) {
      case 8:
        return 'EAN-8';
      case 12:
        return 'UPC-A';
      case 13:
        return 'EAN-13';
      case 14:
        return 'ITF-14';
      default:
        return 'Unknown';
    }
  }

  // Check network connectivity (placeholder - requires connectivity_plus package)
  static Future<bool> hasNetworkConnection() async {
    // In production, use connectivity_plus package
    // For now, return true
    return true;
  }

  // Log debug info (placeholder - in production use proper logging)
  static void log(String message, {String? tag}) {
    // In production, use logger package or Firebase Crashlytics
    print('[${tag ?? 'EcoScanner'}] $message');
  }
}