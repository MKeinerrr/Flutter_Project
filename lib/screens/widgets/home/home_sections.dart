import 'package:flutter/material.dart';
import '../../mi_reserva_screen.dart';
import '../../salones_screen.dart';

class HomeNextReservationData {
  const HomeNextReservationData({
    required this.salonName,
    required this.dateLabel,
    required this.status,
  });

  final String salonName;
  final String dateLabel;
  final String status;
}

class HomeFeaturedSalon {
  const HomeFeaturedSalon({
    required this.name,
    required this.type,
    required this.capacity,
    required this.price,
    required this.rating,
    required this.colorA,
    required this.colorB,
  });

  final String name;
  final String type;
  final String capacity;
  final String price;
  final String rating;
  final Color colorA;
  final Color colorB;
}

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    required this.primaryDark,
    required this.accentIndigo,
  });

  final Color primaryDark;
  final Color accentIndigo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryDark, accentIndigo, const Color(0xFF4D45AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
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
}

class HomeNextReservationSection extends StatelessWidget {
  const HomeNextReservationSection({
    super.key,
    required this.primaryDark,
    required this.accentIndigo,
    required this.isLoading,
    required this.nextReservation,
  });

  final Color primaryDark;
  final Color accentIndigo;
  final bool isLoading;
  final HomeNextReservationData? nextReservation;

  @override
  Widget build(BuildContext context) {
    final bool hasActiveReservation = !isLoading && nextReservation != null;

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
            Row(
              children: [
                Icon(Icons.event_available, color: accentIndigo, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tu proxima reserva',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: primaryDark,
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
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : nextReservation == null
                  ? Text(
                      'No tienes reservas activas\n\nCuando hagas una reserva, aqui podras ver fecha, hora y estado.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextReservation!.salonName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: primaryDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nextReservation!.dateLabel,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Estado: ${nextReservation!.status}',
                          style: TextStyle(
                            color: accentIndigo,
                            fontWeight: FontWeight.w700,
                          ),
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
                    MaterialPageRoute(
                      builder: (_) => hasActiveReservation
                          ? const MiReservaScreen()
                          : const SalonesScreen(),
                    ),
                  );
                },
                icon: Icon(
                  hasActiveReservation ? Icons.event_available : Icons.search,
                ),
                label: Text(
                  hasActiveReservation
                      ? 'Ir a mi reserva'
                      : 'Buscar salones disponibles',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentIndigo,
                  side: BorderSide(color: accentIndigo),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeFeaturedHeader extends StatelessWidget {
  const HomeFeaturedHeader({
    super.key,
    required this.accentIndigo,
    required this.primaryDark,
    required this.onViewMore,
  });

  final Color accentIndigo;
  final Color primaryDark;
  final VoidCallback onViewMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Icon(Icons.star, color: accentIndigo),
          Text(
            ' Salones recomendados ',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: primaryDark,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onViewMore,
            child: Text(
              'Ver más',
              style: TextStyle(
                color: accentIndigo,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFeaturedSalons extends StatelessWidget {
  const HomeFeaturedSalons({
    super.key,
    required this.salons,
    required this.primaryDark,
    required this.accentIndigo,
  });

  final List<HomeFeaturedSalon> salons;
  final Color primaryDark;
  final Color accentIndigo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 272,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: salons.length,
        itemBuilder: (context, index) {
          final HomeFeaturedSalon salon = salons[index];
          return _HomeFeaturedCard(
            salon: salon,
            primaryDark: primaryDark,
            accentIndigo: accentIndigo,
          );
        },
      ),
    );
  }
}

class _HomeFeaturedCard extends StatelessWidget {
  const _HomeFeaturedCard({
    required this.salon,
    required this.primaryDark,
    required this.accentIndigo,
  });

  final HomeFeaturedSalon salon;
  final Color primaryDark;
  final Color accentIndigo;

  @override
  Widget build(BuildContext context) {
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
                    colors: [salon.colorA, salon.colorB],
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
                              salon.type,
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
                                  salon.rating,
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
                    salon.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: primaryDark,
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
                        '${salon.capacity} personas',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Desde ${salon.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: accentIndigo,
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
