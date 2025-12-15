// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../scanner/scanner_screen.dart';
import '../history/history_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();

  String get _userId => _authService.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _HomeTab(userId: _userId),
      HistoryScreen(userId: _userId),
      FavoritesScreen(userId: _userId),
      ProfileScreen(userId: _userId),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScannerScreen(userId: _userId),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan'),
              backgroundColor: Colors.green,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _HomeTab extends StatefulWidget {
  final String userId;
  const _HomeTab({required this.userId});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _firestoreService = FirestoreService();
  Map<String, int>? _weeklyStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _firestoreService.getWeeklyAnalytics(widget.userId);
      if (mounted) {
        setState(() {
          _weeklyStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoScanner'),
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildQuickStats(),
              const SizedBox(height: 24),
              Text('How it Works', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildFeatureCard(Icons.qr_code_scanner, 'Scan Barcode', 'Scan any product barcode'),
              _buildFeatureCard(Icons.analytics, 'View Eco-Score', 'See environmental rating'),
              _buildFeatureCard(Icons.compare, 'Find Alternatives', 'Discover greener options'),
              _buildFeatureCard(Icons.recycling, 'Learn Recyclability', 'Get recycling info'),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.green[400]!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.eco, size: 60, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Make Sustainable Choices',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan products to get instant sustainability information',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_weeklyStats == null || _weeklyStats!['total'] == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.trending_up, size: 48, color: Colors.green[300]),
              const SizedBox(height: 12),
              const Text('Start Your Journey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Scan your first product!', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final total = _weeklyStats!['total'] ?? 0;
    final green = _weeklyStats!['green'] ?? 0;
    final percentage = total > 0 ? ((green / total) * 100).round() : 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('This Week\'s Impact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(total.toString(), 'Scans', Colors.blue),
                _buildStatColumn(green.toString(), 'Eco-Friendly', Colors.green),
                _buildStatColumn('$percentage%', 'Green Score', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}