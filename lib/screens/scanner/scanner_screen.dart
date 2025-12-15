// lib/screens/scanner/scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/open_food_facts_service.dart';
import '../../services/firestore_service.dart';
import '../../models/product_model.dart';
import '../product/product_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  final String userId;

  const ScannerScreen({super.key, required this.userId});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  final OpenFoodFactsService _productService = OpenFoodFactsService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isProcessing = false;
  String? _lastScannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(
              cameraController.torchEnabled == TorchState.on
                  ? Icons.flash_on
                  : Icons.flash_off,
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          _buildOverlay(),
          if (_isProcessing) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner decorations
            Positioned(top: -2, left: -2, child: _buildCorner()),
            Positioned(
              top: -2,
              right: -2,
              child: Transform.rotate(angle: 1.5708, child: _buildCorner()),
            ),
            Positioned(
              bottom: -2,
              left: -2,
              child: Transform.rotate(angle: -1.5708, child: _buildCorner()),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Transform.rotate(angle: 3.14159, child: _buildCorner()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner() {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.green, width: 4),
          left: BorderSide(color: Colors.green, width: 4),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Fetching product info...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code == _lastScannedCode) return;

    _lastScannedCode = code;
    setState(() => _isProcessing = true);

    try {
      // Fetch product from Open Food Facts
      Product? product = await _productService.getProductByBarcode(code);

      product ??= await _firestoreService.getCustomProduct(code);

      if (product != null) {
        // Save to history
        await _firestoreService.addToHistory(widget.userId, product);

        // Navigate to product details
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailScreen(product: product!, userId: widget.userId),
            ),
          );
        }
      } else {
        // Product not found
        if (mounted) {
          _showProductNotFoundDialog(code);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
        _lastScannedCode = null;
      });
    }
  }

  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Text(
          'Barcode: $barcode\n\nThis product is not in our database yet. Would you like to add it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to add product screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add product feature coming soon!'),
                ),
              );
            },
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
