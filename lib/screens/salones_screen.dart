import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'historial_screen.dart';

/// SalonesScreen — Lists available salons with search & filter chips.
class SalonesScreen extends StatefulWidget {
  const SalonesScreen({super.key});

  @override
  State<SalonesScreen> createState() => _SalonesScreenState();
}

class _SalonesScreenState extends State<SalonesScreen> {
  // Palette
  static const Color _primaryDark = Color(0xFF1A0A4C);
  static const Color _accentIndigo = Color(0xFF3D3B8E);
  static const Color _lightBlue = Color(0xFFA8D8F0);

  // Currently selected filter chip index
  int _selectedChip = 0;

  // Filter chip labels — categorized by event type
  final List<String> _filters = ['Todos', 'Fiestas', 'Eventos', 'Reuniones', 'Conferencias'];

  // Hardcoded salon list for the mockup
  final List<Map<String, dynamic>> _salons = [
    {
      'name': 'Salón Caribe',
      'capacity': '80 personas',
      'price': r'Desde $500.000',
      'type': 'Fiestas',
      'available': true,
      'color': const Color(0xFF3D3B8E),
    },
    {
      'name': 'Salón Ejecutivo',
      'capacity': '50 personas',
      'price': r'Desde $350.000',
      'type': 'Reuniones',
      'available': true,
      'color': const Color(0xFFA8D8F0),
    },
    {
      'name': 'Salón Vista Mar',
      'capacity': '120 personas',
      'price': r'Desde $800.000',
      'type': 'Eventos',
      'available': false,
      'color': const Color(0xFF1A0A4C),
    },
    {
      'name': 'Salón Bolívar',
      'capacity': '60 personas',
      'price': r'Desde $450.000',
      'type': 'Conferencias',
      'available': true,
      'color': const Color(0xFF3D3B8E),
    },
    {
      'name': 'Salón Premier',
      'capacity': '200 personas',
      'price': r'Desde $1.200.000',
      'type': 'Fiestas · Eventos',
      'available': false,
      'color': const Color(0xFFA8D8F0),
    },
  ];

  /// Bottom-nav tap handler — mirrors HomeScreen logic.
  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HistorialScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(title: const Text('Salones Disponibles')),

      // --- Body ---
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar salón...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter chips row
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final selected = _selectedChip == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_filters[index]),
                    selected: selected,
                    selectedColor: _accentIndigo,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : _primaryDark,
                    ),
                    onSelected: (_) => setState(() => _selectedChip = index),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Salon list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _salons.length,
              itemBuilder: (context, index) => _salonCard(_salons[index]),
            ),
          ),
        ],
      ),

      // --- Bottom Navigation ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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

  /// Builds a single salon card with info, category type, availability chip,
  /// and a red left-border accent when the salon is unavailable.
  Widget _salonCard(Map<String, dynamic> salon) {
    final bool available = salon['available'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        // Red left-border accent for unavailable salons
        border: available
            ? null
            : const Border(
                left: BorderSide(color: Colors.red, width: 4),
              ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reserva en desarrollo 🚧')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Color image placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: salon['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),

                // Salon details column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        salon['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Event type category
                      Row(
                        children: [
                          const Icon(Icons.category, size: 14, color: _accentIndigo),
                          const SizedBox(width: 4),
                          Text(
                            salon['type'] as String,
                            style: const TextStyle(
                              color: _accentIndigo,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Capacity
                      Row(
                        children: [
                          const Icon(Icons.people, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            salon['capacity'] as String,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Price
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            salon['price'] as String,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Availability chip
                      Chip(
                        label: Text(
                          available ? 'Disponible' : 'No disponible',
                          style: TextStyle(
                            color: available ? Colors.green[800] : Colors.red[800],
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: available
                            ? Colors.green[50]
                            : Colors.red[50],
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
