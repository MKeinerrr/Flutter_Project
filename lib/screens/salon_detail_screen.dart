import 'dart:convert';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'models/salon_view_model.dart';
import 'utils/screen_formatters.dart';

class SalonDetailScreen extends StatelessWidget {
  const SalonDetailScreen({super.key, required this.salon, this.onReserve});

  final SalonViewModel salon;
  final VoidCallback? onReserve;

  @override
  Widget build(BuildContext context) {
    final String price = ScreenFormatters.formatCurrency(salon.price);

    return Scaffold(
      appBar: AppBar(title: Text(salon.name)),
      bottomNavigationBar: _buildReserveCta(price),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderImage(),
          const SizedBox(height: 16),
          _buildSummaryRow(price),
          const SizedBox(height: 14),
          _buildBadges(),
          const SizedBox(height: 16),
          _buildGallerySection(),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Descripcion',
            content: salon.description?.trim().isNotEmpty == true
                ? salon.description!.trim()
                : 'Sin descripcion disponible.',
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: 'Politicas',
            content: salon.policies?.trim().isNotEmpty == true
                ? salon.policies!.trim()
                : 'Sin politicas registradas.',
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    final String? photoUrl = salon.photoUrl;
    final Widget fallback = Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [salon.colorA, salon.colorB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.photo,
          size: 48,
          color: AppColors.text1.withAlpha(180),
        ),
      ),
    );

    if (photoUrl == null || photoUrl.trim().isEmpty) {
      return fallback;
    }

    if (photoUrl.startsWith('data:image')) {
      final int commaIndex = photoUrl.indexOf(',');
      if (commaIndex != -1) {
        final String dataPart = photoUrl.substring(commaIndex + 1);
        try {
          final bytes = base64Decode(dataPart);
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              bytes,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        } catch (_) {
          return fallback;
        }
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        photoUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }

  Widget _buildSummaryRow(String price) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(Icons.location_on_outlined, salon.zone),
        _buildChip(Icons.people_outline, '${salon.capacity} personas'),
        _buildChip(Icons.sell_outlined, salon.category),
        _buildChip(Icons.payments_outlined, '\$$price'),
        _buildChip(Icons.star_border, salon.rating.toStringAsFixed(1)),
      ],
    );
  }
  Widget _buildBadges() {
    if (salon.badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: salon.badges
          .map(
            (badge) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bg3,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGallerySection() {
    final List<String> gallery = salon.photos.isNotEmpty
        ? salon.photos
        : (salon.photoUrl != null && salon.photoUrl!.trim().isNotEmpty)
            ? [salon.photoUrl!.trim()]
            : const [];

    if (gallery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Galeria',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SizedBox(
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
                  width: 240,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 240,
                    color: AppColors.bg2,
                    child: const Center(child: Icon(Icons.photo)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReserveCta(String price) {
    if (onReserve == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: salon.available ? onReserve : null,
          icon: const Icon(Icons.bolt),
          label: Text(salon.available ? 'Reservar por \$$price' : 'No disponible'),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(color: AppColors.text2, height: 1.4),
        ),
      ],
    );
  }
}
