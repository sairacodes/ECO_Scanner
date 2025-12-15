// // lib/services/ml_service.dart

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';

// class MLService {
//   Interpreter? _interpreter;
//   bool _isModelLoaded = false;

//   // Packaging material labels (trained on common materials)
//   final List<String> _labels = [
//     'Plastic',
//     'Cardboard',
//     'Glass',
//     'Metal',
//     'Paper',
//     'Wood',
//     'Mixed',
//   ];

//   /// Initialize the ML model
//   Future<void> initializeModel() async {
//     try {
//       // Load model from assets
//       _interpreter = await Interpreter.fromAsset('assets/ml_models/packaging_classifier.tflite');
//       _isModelLoaded = true;
//       print('✅ ML Model loaded successfully');
//     } catch (e) {
//       print('❌ Error loading ML model: $e');
//       _isModelLoaded = false;
//     }
//   }

//   /// Check if model is loaded
//   bool get isModelLoaded => _isModelLoaded;

//   /// Classify packaging material from image
//   Future<Map<String, dynamic>> classifyPackaging(File imageFile) async {
//     if (!_isModelLoaded) {
//       return {
//         'error': 'Model not loaded',
//         'material': 'Unknown',
//         'confidence': 0.0,
//       };
//     }

//     try {
//       // Read and preprocess image
//       final imageBytes = await imageFile.readAsBytes();
//       final image = img.decodeImage(imageBytes);
      
//       if (image == null) {
//         return {
//           'error': 'Failed to decode image',
//           'material': 'Unknown',
//           'confidence': 0.0,
//         };
//       }

//       // Resize image to model input size (224x224 for MobileNet)
//       final resizedImage = img.copyResize(image, width: 224, height: 224);

//       // Convert to Float32List normalized [0, 1]
//       final input = _imageToByteListFloat32(resizedImage);

//       // Prepare output tensor
//       final output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

//       // Run inference
//       _interpreter!.run(input, output);

//       // Get predictions
//       final predictions = output[0] as List<double>;
      
//       // Find highest confidence
//       double maxConfidence = 0.0;
//       int maxIndex = 0;
      
//       for (int i = 0; i < predictions.length; i++) {
//         if (predictions[i] > maxConfidence) {
//           maxConfidence = predictions[i];
//           maxIndex = i;
//         }
//       }

//       return {
//         'material': _labels[maxIndex],
//         'confidence': maxConfidence,
//         'allPredictions': Map.fromIterables(_labels, predictions),
//       };
//     } catch (e) {
//       print('Error in classification: $e');
//       return {
//         'error': e.toString(),
//         'material': 'Unknown',
//         'confidence': 0.0,
//       };
//     }
//   }

//   /// Classify packaging from image and get eco-score impact
//   Future<Map<String, dynamic>> analyzePackagingImpact(File imageFile) async {
//     final classification = await classifyPackaging(imageFile);
    
//     if (classification['error'] != null) {
//       return classification;
//     }

//     final material = classification['material'] as String;
//     final confidence = classification['confidence'] as double;

//     // Calculate impact based on material
//     final impactScore = _calculateMaterialImpact(material);
//     final isRecyclable = _isRecyclableMaterial(material);
//     final tips = _getRecyclingTips(material);

//     return {
//       'material': material,
//       'confidence': confidence,
//       'impactScore': impactScore,
//       'isRecyclable': isRecyclable,
//       'recyclingTips': tips,
//       'ecoRating': _getEcoRating(impactScore),
//     };
//   }

//   /// Convert image to Float32List for model input
//   Float32List _imageToByteListFloat32(img.Image image) {
//     final convertedBytes = Float32List(1 * 224 * 224 * 3);
//     final buffer = Float32List.view(convertedBytes.buffer);
//     int pixelIndex = 0;

//     for (int y = 0; y < 224; y++) {
//       for (int x = 0; x < 224; x++) {
//         final pixel = image.getPixel(x, y);
        
//         // Normalize RGB values to [0, 1]
//         buffer[pixelIndex++] = pixel.r / 255.0;
//         buffer[pixelIndex++] = pixel.g / 255.0;
//         buffer[pixelIndex++] = pixel.b / 255.0;
//       }
//     }

//     return convertedBytes.reshape([1, 224, 224, 3]);
//   }

//   /// Calculate environmental impact score (0-100)
//   int _calculateMaterialImpact(String material) {
//     switch (material.toLowerCase()) {
//       case 'cardboard':
//       case 'paper':
//         return 85; // Very eco-friendly
//       case 'glass':
//         return 75; // Good, but heavy
//       case 'metal':
//         return 70; // Recyclable but energy-intensive
//       case 'wood':
//         return 80; // Natural but deforestation concerns
//       case 'plastic':
//         return 30; // Poor environmental impact
//       case 'mixed':
//         return 40; // Hard to recycle
//       default:
//         // return 50; // Unknown/neutral
//     }
//   }

//   /// Check if material is recyclable
//   bool _isRecyclableMaterial(String material) {
//     return [
//       'cardboard',
//       'paper',
//       'glass',
//       'metal',
//       'plastic', // Some plastics
//     ].contains(material.toLowerCase());
//   }

//   /// Get recycling tips for material
//   List<String> _getRecyclingTips(String material) {
//     switch (material.toLowerCase()) {
//       case 'plastic':
//         return [
//           'Check recycling code (1-7)',
//           'Rinse before recycling',
//           'Remove caps and labels',
//           'Avoid contaminating with food',
//         ];
//       case 'cardboard':
//       case 'paper':
//         return [
//           'Keep dry and clean',
//           'Flatten boxes',
//           'Remove tape and staples',
//           'No greasy or food-stained items',
//         ];
//       case 'glass':
//         return [
//           'Rinse thoroughly',
//           'Remove metal caps',
//           'Separate by color if required',
//           'Check local glass recycling rules',
//         ];
//       case 'metal':
//         return [
//           'Rinse cans and containers',
//           'Crush cans to save space',
//           'Check if aluminum or steel',
//           'Remove paper labels if possible',
//         ];
//       default:
//         return [
//           'Check local recycling guidelines',
//           'When in doubt, throw it out',
//           'Never contaminate recycling',
//         ];
//     }
//   }

//   /// Get eco-rating from impact score
//   String _getEcoRating(int impactScore) {
//     if (impactScore >= 80) return 'Excellent';
//     if (impactScore >= 60) return 'Good';
//     if (impactScore >= 40) return 'Moderate';
//     if (impactScore >= 20) return 'Poor';
//     return 'Very Poor';
//   }

//   /// Batch analyze multiple images
//   Future<List<Map<String, dynamic>>> batchAnalyze(List<File> images) async {
//     List<Map<String, dynamic>> results = [];
    
//     for (File image in images) {
//       final result = await analyzePackagingImpact(image);
//       results.add(result);
//     }
    
//     return results;
//   }

//   /// Get model info
//   Map<String, dynamic> getModelInfo() {
//     return {
//       'isLoaded': _isModelLoaded,
//       'inputShape': [1, 224, 224, 3],
//       'outputShape': [1, _labels.length],
//       'labels': _labels,
//       'modelType': 'MobileNetV2',
//     };
//   }

//   /// Dispose model
//   void dispose() {
//     _interpreter?.close();
//     _isModelLoaded = false;
//   }
// }

// // Extension for reshaping Float32List
// extension Float32ListReshape on Float32List {
//   List<List<List<List<double>>>> reshape(List<int> shape) {
//     if (shape.length != 4) {
//       throw ArgumentError('Shape must have 4 dimensions');
//     }

//     List<List<List<List<double>>>> result = [];
//     int index = 0;

//     for (int i = 0; i < shape[0]; i++) {
//       List<List<List<double>>> batch = [];
//       for (int j = 0; j < shape[1]; j++) {
//         List<List<double>> row = [];
//         for (int k = 0; k < shape[2]; k++) {
//           List<double> col = [];
//           for (int l = 0; l < shape[3]; l++) {
//             col.add(this[index++]);
//           }
//           row.add(col);
//         }
//         batch.add(row);
//       }
//       result.add(batch);
//     }

//     return result;
//   }
// }