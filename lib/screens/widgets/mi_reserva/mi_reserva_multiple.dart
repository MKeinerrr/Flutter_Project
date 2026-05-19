import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../models/reservation_history.dart';
import '../../utils/screen_formatters.dart';

class MiReservaMultipleList extends StatelessWidget {
  const MiReservaMultipleList({
    super.key,
    required this.reservations,
    required this.accentIndigo,
    required this.onOpenReservation,
  });

  final List<ReservationHistoryItem> reservations;
  final Color accentIndigo;
  final ValueChanged<ReservationHistoryItem> onOpenReservation;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        return _ActiveReservationCard(
          reservation: reservations[index],
          accentIndigo: accentIndigo,
          onOpen: () => onOpenReservation(reservations[index]),
        );
      },
    );
  }
}

class _ActiveReservationCard extends StatelessWidget {
  const _ActiveReservationCard({
    required this.reservation,
    required this.accentIndigo,
    required this.onOpen,
  });

  final ReservationHistoryItem reservation;
  final Color accentIndigo;
  final VoidCallback onOpen;

  Color _statusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return AppColors.warning;
      case 'Confirmada':
        return AppColors.success;
      default:
        return accentIndigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(reservation.status);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withAlpha(60),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: CircleAvatar(
            backgroundColor: reservation.color,
            child: Text(
              reservation.initial,
              style: const TextStyle(
                color: AppColors.text1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            reservation.salon,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.text1,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                reservation.dateLabel,
                style: const TextStyle(fontSize: 12, color: AppColors.text1),
              ),
              const SizedBox(height: 2),
              Text(
                '${reservation.guests} asistentes · ${reservation.id}',
                style: const TextStyle(fontSize: 12, color: AppColors.text3),
              ),
            ],
          ),
          trailing: TextButton(
            onPressed: onOpen,
            child: const Text(
              'Ir a mi reserva',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          children: [
            const Divider(height: 10),
            _detailRow('Pago', reservation.payment),
            _detailRow(
              'Valor',
              '\$${ScreenFormatters.formatCurrency(reservation.amount)}',
            ),
            _detailRow('Notas', reservation.notes),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.text3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.text1),
            ),
          ),
        ],
      ),
    );
  }
}
