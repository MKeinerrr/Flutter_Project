import 'package:flutter/material.dart';
import 'salones_screen.dart';
import 'historial_screen.dart';

/// HomeScreen — Landing page with quick access cards, featured salons,
/// and a bottom navigation bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Palette constants
  static const Color _primaryDark = Color(0xFF1A0A4C);
  static const Color _accentIndigo = Color(0xFF3D3B8E);
  static const Color _lightBlue = Color(0xFFA8D8F0);

  int _currentIndex = 0;

  /// Navigates to the appropriate screen based on bottom nav index.
  void _onBottomNavTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SalonesScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HistorialScreen()),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(
        title: const Text('Bienvenido 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),

      // --- Body ---
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero gradient header
            _buildGradientHeader(),
            const SizedBox(height: 20),

            // Quick access section
            _sectionTitle('Acceso Rápido'),
            const SizedBox(height: 10),
            _buildQuickAccessRow(),
            const SizedBox(height: 24),

            // Featured salons section
            _sectionTitle('Salones Destacados'),
            const SizedBox(height: 10),
            _buildFeaturedSalons(),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // --- Bottom Navigation ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: _primaryDark,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Salones'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
    );
  }

  // ───────────────────────────── Widgets ─────────────────────────────

  /// Gradient header with call-to-action text.
  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryDark, _accentIndigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué salón necesitas hoy?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Encuentra el espacio perfecto para tu evento',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Section title used across the screen.
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _primaryDark,
        ),
      ),
    );
  }

  /// Row of three quick-access cards: Salones, Historial, Perfil.
  Widget _buildQuickAccessRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _quickAccessCard(Icons.business, 'Salones', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalonesScreen()),
            );
          }),
          _quickAccessCard(Icons.history, 'Historial', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistorialScreen()),
            );
          }),
          _quickAccessCard(Icons.person, 'Perfil', () {}),
        ],
      ),
    );
  }

  /// A single quick-access card with icon and label.
  Widget _quickAccessCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 100,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: _accentIndigo),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Horizontal list of featured salon cards.
  Widget _buildFeaturedSalons() {
    // Hardcoded salon data for the mockup
    final salons = [
      {'name': 'Salón Caribe', 'capacity': '80', 'color': _accentIndigo},
      {'name': 'Salón Ejecutivo', 'capacity': '50', 'color': _lightBlue},
      {'name': 'Salón Vista Mar', 'capacity': '120', 'color': _primaryDark},
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: salons.length,
        itemBuilder: (context, index) {
          final salon = salons[index];
          return _featuredCard(
            name: salon['name'] as String,
            capacity: salon['capacity'] as String,
            color: salon['color'] as Color,
          );
        },
      ),
    );
  }

  /// A single featured-salon card with color placeholder, name & badge.
  Widget _featuredCard({
    required String name,
    required String capacity,
    required Color color,
  }) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(height: 110, color: color),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Capacity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _lightBlue.withAlpha(100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$capacity personas',
                      style: const TextStyle(fontSize: 11, color: _primaryDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
