import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../models/mi_reserva_view_model.dart';
import '../../models/rating_state.dart';

class MiReservaDetail extends StatelessWidget {
  const MiReservaDetail({
    required this.data,
    required this.primaryDark,
    required this.accentIndigo,
    required this.isSubmittingRating,
    required this.onSubmitRating,
    this.ratingState,
    super.key,
  });

  final MiReservaViewModel data;
  final Color primaryDark;
  final Color accentIndigo;
  final bool isSubmittingRating;
  final Future<void> Function(int score, String comment) onSubmitRating;
  final RatingState? ratingState;

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
        const _SectionTitle(title: 'Detalles del salon'),
        const SizedBox(height: 10),
        _SalonSummary(data: data),
        const SizedBox(height: 16),
        const _SectionTitle(title: 'Fotos del salon'),
        const SizedBox(height: 8),
        _GalleryStrip(gallery: data.gallery),
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
                  backgroundColor: AppColors.bg3,
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
            color: AppColors.bg2,
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
              _DetailRow(icon: Icons.schedule, text: 'Acceso desde 7:00 AM'),
              SizedBox(height: 8),
              _DetailRow(icon: Icons.receipt_long, text: 'Factura disponible en recepcion'),
              SizedBox(height: 8),
              _DetailRow(icon: Icons.support_agent, text: 'Soporte del evento 24/7'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle(title: 'Calificar'),
        const SizedBox(height: 10),
        _RatingSection(
          isSubmitting: isSubmittingRating,
          onSubmit: onSubmitRating,
          ratingState: ratingState,
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
          colors: [AppColors.bg1, AppColors.bg2, AppColors.bg4, AppColors.accentDim],
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
            style: TextStyle(color: AppColors.text2, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            data.reservation.salon,
            style: const TextStyle(
              color: AppColors.text1,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.reservation.dateLabel}  |  ${data.reservation.guests} asistentes',
            style: const TextStyle(color: AppColors.text1),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.text1.withAlpha(35),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Codigo: ${data.reservation.id} · ${data.reservation.status}',
              style: const TextStyle(color: AppColors.text1, fontWeight: FontWeight.w700),
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
        color: AppColors.text1,
      ),
    );
  }
}

class _SalonSummary extends StatelessWidget {
  const _SalonSummary({required this.data});

  final MiReservaViewModel data;

  @override
  Widget build(BuildContext context) {
    final salon = data.salon;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _InfoChip(icon: Icons.location_on_outlined, label: salon.zone),
        _InfoChip(
          icon: Icons.people_outline,
          label: '${salon.capacity} personas',
        ),
        _InfoChip(icon: Icons.sell_outlined, label: salon.category),
        _InfoChip(
          icon: Icons.payments_outlined,
          label: '\$${salon.price.toStringAsFixed(0)}',
        ),
        _InfoChip(
          icon: Icons.star_border,
          label: salon.rating.toStringAsFixed(1),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.text3),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.text1)),
        ],
      ),
    );
  }
}

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip({required this.gallery});

  final List<String> gallery;

  @override
  Widget build(BuildContext context) {
    if (gallery.isEmpty) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('Sin fotos disponibles'),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: gallery.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              gallery[index],
              width: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 250,
                color: AppColors.bg2,
                child: const Center(child: Icon(Icons.photo)),
              ),
            ),
          );
        },
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
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _RatingSection extends StatefulWidget {
  const _RatingSection({
    required this.isSubmitting,
    required this.onSubmit,
    this.ratingState,
  });

  final bool isSubmitting;
  final Future<void> Function(int score, String comment) onSubmit;
  final RatingState? ratingState;

  @override
  State<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<_RatingSection> {
  int _score = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    final RatingState? ratingState = widget.ratingState;
    if (ratingState != null) {
      _score = ratingState.score;
      _commentController.text = ratingState.comment;
      _locked = true;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Tu calificacion',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              ...List.generate(
                5,
                (index) => IconButton(
                  onPressed: widget.isSubmitting || _locked
                      ? null
                      : () => setState(() => _score = index + 1),
                  icon: Icon(
                    index < _score ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          TextField(
            controller: _commentController,
            maxLines: 3,
            readOnly: _locked,
            decoration: const InputDecoration(
              hintText: 'Comparte tu experiencia (opcional)',
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isSubmitting || _score == 0 || _locked
                  ? null
                  : () async {
                      await widget.onSubmit(
                        _score,
                        _commentController.text,
                      );
                    },
              child: Text(
                _locked
                    ? 'Enviado'
                    : widget.isSubmitting
                    ? 'Enviando...'
                    : 'Enviar',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
