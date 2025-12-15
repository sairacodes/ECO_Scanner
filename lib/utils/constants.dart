import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'EcoScanner';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Scan products for sustainability info';

  // API URLs
  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org/api/v2';

  // Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF388E3C);
  static const Color lightGreen = Color(0xFF8BC34A);

  // Eco-Score Colors
  static const Color gradeAColor = Color(0xFF4CAF50); // Green
  static const Color gradeBColor = Color(0xFF8BC34A); // Light Green
  static const Color gradeCColor = Color(0xFFFFEB3B); // Yellow
  static const Color gradeDColor = Color(0xFFFF9800); // Orange
  static const Color gradeEColor = Color(0xFFF44336); // Red

  // Eco-Score Thresholds
  static const int excellentScoreThreshold = 80;
  static const int goodScoreThreshold = 60;
  static const int moderateScoreThreshold = 40;
  static const int poorScoreThreshold = 20;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Limits
  static const int maxHistoryItems = 50;
  static const int maxSearchResults = 20;
  static const int maxAlternatives = 5;

  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String productNotFoundMessage = 'Product not found in database.';
  static const String scanErrorMessage = 'Failed to scan barcode. Please try again.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
}
