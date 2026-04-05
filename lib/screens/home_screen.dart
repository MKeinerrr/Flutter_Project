import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import 'historial_screen.dart';
import 'perfil_screen.dart';
import 'salones_screen.dart';

/// HomeScreen — Airbnb-inspired landing with discovery sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.username = 'Invitado'});

  final String username;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primaryDark = Color(0xFF1A0A4C);
  static const Color _accentIndigo = Color(0xFF3D3B8E);

  int _currentIndex = 0;

  static const List<Map<String, dynamic>> _featuredSalons = [
    {
      'name': 'Salón Caribe',
      'type': 'Fiestas',
      'capacity': '80',
      'price': r'$500.000',
      'rating': '4.9',
      'colorA': Color(0xFF3146B8),
      'colorB': Color(0xFF5E77FF),
    },
    {
      'name': 'Salón Ejecutivo',
      'type': 'Corporativo',
      'capacity': '50',
      'price': r'$350.000',
      'rating': '4.7',
      'colorA': Color(0xFF3B8AA3),
      'colorB': Color(0xFF7EC8E3),
    },
    {
      'name': 'Vista Mar Rooftop',
      'type': 'Eventos',
      'capacity': '120',
      'price': r'$800.000',
      'rating': '5.0',
      'colorA': Color(0xFF111C62),
      'colorB': Color(0xFF3D3B8E),
    },
  ];

  void _onBottomNavTap(int index) {
    if (index == 0) {
      setState(() => _currentIndex = 0);
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SalonesScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HistorialScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PerfilScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Hola, ${AuthController.instance.session?.username ?? widget.username}',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroSection()),
            SliverToBoxAdapter(child: _buildNextReservationSection()),
            SliverToBoxAdapter(child: _buildFeaturedHeader()),
            SliverToBoxAdapter(child: _buildFeaturedSalons()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: _primaryDark,
          unselectedItemColor: Colors.grey,
          onTap: _onBottomNavTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Salones'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      );
    }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryDark, _accentIndigo, Color(0xFF4D45AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text('Cartagena', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(28),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tune, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Encuentra el salón perfecto\npara tu próximo evento\nsin salir de casa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextReservationSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.event_available, color: _accentIndigo, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tu proxima reserva',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F5FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No tienes reservas activas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _primaryDark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Cuando hagas una reserva, aqui podras ver fecha, hora y estado.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SalonesScreen()),
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text('Buscar salones disponibles'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accentIndigo,
                  side: const BorderSide(color: _accentIndigo),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Icon(Icons.star, color: _accentIndigo),
          Text(
            ' Salones recomendados ',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSalons() {
    return SizedBox(
      height: 272,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _featuredSalons.length,
        itemBuilder: (context, index) {
          final salon = _featuredSalons[index];
          return _featuredCard(
            name: salon['name'] as String,
            type: salon['type'] as String,
            capacity: salon['capacity'] as String,
            price: salon['price'] as String,
            rating: salon['rating'] as String,
            colorA: salon['colorA'] as Color,
            colorB: salon['colorB'] as Color,
          );
        },
      ),
    );
  }

  Widget _featuredCard({
    required String name,
    required String type,
    required String capacity,
    required String price,
    required String rating,
    required Color colorA,
    required Color colorB,
  }) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 14),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorA, colorB],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(36),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$capacity personas',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Desde $price',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _accentIndigo,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
