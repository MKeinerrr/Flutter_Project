import 'package:flutter/material.dart';

import '../../models/mi_reserva_view_model.dart';

class MiReservaDetail extends StatelessWidget {
  const MiReservaDetail({
    required this.data,
    required this.primaryDark,
    required this.accentIndigo,
    super.key,
  });

  final MiReservaViewModel data;
  final Color primaryDark;
  final Color accentIndigo;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        _ReservationHeader(
          data: data,
          primaryDark: primaryDark,
          accentIndigo: accentIndigo,
        ),
        const SizedBox(height: 16),
        const _SectionTitle(title: 'Fotos del salon'),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: data.gallery.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  data.gallery[index],
                  width: 250,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle(title: 'Comodidades incluidas'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: data.amenities
              .map(
                (item) => Chip(
                  avatar: const Icon(Icons.check_circle, size: 16),
                  label: Text(item),
                  side: BorderSide.none,
                  backgroundColor: const Color(0xFFF1EEFF),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        const _SectionTitle(title: 'Informacion adicional'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(icon: Icons.schedule, text: 'Acceso desde 8:00 AM'),
              SizedBox(height: 8),
              _DetailRow(icon: Icons.receipt_long, text: 'Factura disponible en recepcion'),
              SizedBox(height: 8),
              _DetailRow(icon: Icons.support_agent, text: 'Soporte del evento 24/7'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle(title: 'Opiniones y calificaciones'),
        const SizedBox(height: 10),
        ...data.reviews.map(
          (review) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OpinionCard(
              user: review.user,
              score: review.score,
              text: review.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReservationHeader extends StatelessWidget {
  const _ReservationHeader({
    required this.data,
    required this.primaryDark,
    required this.accentIndigo,
  });

  final MiReservaViewModel data;
  final Color primaryDark;
  final Color accentIndigo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryDark, accentIndigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reserva en curso',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            data.reservation.salon,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.reservation.dateLabel}  |  ${data.reservation.guests} asistentes',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Codigo: ${data.reservation.id} · ${data.reservation.status}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A0A4C),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF3D3B8E)),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _OpinionCard extends StatelessWidget {
  const _OpinionCard({
    required this.user,
    required this.score,
    required this.text,
  });

  final String user;
  final int score;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(user, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              ...List.generate(
                5,
                (index) => Icon(
                  index < score ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(text),
        ],
      ),
    );
  }
}
