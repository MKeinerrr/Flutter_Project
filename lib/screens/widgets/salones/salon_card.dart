import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../models/salon_view_model.dart';
import '../../utils/screen_formatters.dart';

class SalonCard extends StatelessWidget {
  const SalonCard({
    super.key,
    required this.salon,
    required this.onReserve,
    required this.onViewDetail,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.primaryDark,
    required this.accentIndigo,
  });

  final SalonViewModel salon;
  final VoidCallback onReserve;
  final VoidCallback onViewDetail;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final Color primaryDark;
  final Color accentIndigo;

  @override
  Widget build(BuildContext context) {
    final String price = ScreenFormatters.formatCurrency(salon.price);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      color: AppColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 116,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildHeaderImage(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.bg4.withAlpha(160),
                        AppColors.bg0.withAlpha(0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
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
                              color: AppColors.text1.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              salon.category,
                              style: const TextStyle(
                                color: AppColors.text1,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onToggleFavorite,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.bg3,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? AppColors.danger : accentIndigo,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bg3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Desde \$$price',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bg3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  salon.rating.toStringAsFixed(1),
                                  style: const TextStyle(color: AppColors.text1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: salon.available ? AppColors.success : AppColors.danger,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              salon.available
                                  ? 'Disponible hoy'
                                  : 'No disponible',
                              style: const TextStyle(
                                color: AppColors.text1,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salon.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.text3,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      salon.zone,
                      style: const TextStyle(color: AppColors.text2),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: AppColors.text3,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${salon.capacity} personas',
                      style: const TextStyle(color: AppColors.text2),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: salon.badges
                      .map(
                        (badge) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bg3,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: salon.available ? onReserve : null,
                        icon: const Icon(Icons.bolt),
                        label: const Text('Reservar ahora'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentDim,
                          foregroundColor: AppColors.bg0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onViewDetail,
                        child: const Text('Ver detalle'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    final String? photoUrl = salon.photoUrl;
    final Widget fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [salon.colorA, salon.colorB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.photo, size: 30, color: AppColors.text1),
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
          return Image.memory(bytes, fit: BoxFit.cover);
        } catch (_) {
          return fallback;
        }
      }
    }

    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
