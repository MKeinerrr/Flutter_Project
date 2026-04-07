import 'package:flutter/material.dart';
import '../../models/reservation_history.dart';
import '../../utils/screen_formatters.dart';

class HistoryReservationCard extends StatelessWidget {
  const HistoryReservationCard({
    super.key,
    required this.reservation,
    required this.primaryDark,
    required this.accentIndigo,
    required this.onReceiptTap,
    required this.onRepeatTap,
  });

  final ReservationHistoryItem reservation;
  final Color primaryDark;
  final Color accentIndigo;
  final VoidCallback onReceiptTap;
  final VoidCallback onRepeatTap;

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmada':
        return Colors.blue;
      case 'Completada':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Confirmada':
        return Icons.verified;
      case 'Completada':
        return Icons.check_circle;
      case 'Pendiente':
        return Icons.schedule;
      case 'Cancelada':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _statusColor(reservation.status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
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
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            reservation.salon,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryDark,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                reservation.dateLabel,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                '${reservation.guests} asistentes · ${reservation.id}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Chip(
            label: Text(
              reservation.status,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            avatar: Icon(_statusIcon(reservation.status), color: color, size: 14),
            backgroundColor: color.withAlpha(22),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
          children: [
            const Divider(height: 10),
            _detailRow('Pago', reservation.payment),
            _detailRow(
              'Valor',
              '\$${ScreenFormatters.formatCurrency(reservation.amount)}',
            ),
            _detailRow('Notas', reservation.notes),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReceiptTap,
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Comprobante'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRepeatTap,
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Repetir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentIndigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
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
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}
