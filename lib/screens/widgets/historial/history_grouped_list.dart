import 'package:flutter/material.dart';
import '../../models/reservation_history.dart';
import 'history_reservation_card.dart';

class HistoryGroupedList extends StatelessWidget {
  const HistoryGroupedList({
    super.key,
    required this.grouped,
    required this.primaryDark,
    required this.accentIndigo,
    required this.onReceiptTap,
    required this.onRepeatTap,
  });

  final Map<String, List<ReservationHistoryItem>> grouped;
  final Color primaryDark;
  final Color accentIndigo;
  final ValueChanged<ReservationHistoryItem> onReceiptTap;
  final ValueChanged<ReservationHistoryItem> onRepeatTap;

  @override
  Widget build(BuildContext context) {
    final List<String> months = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: months.length,
      itemBuilder: (context, monthIndex) {
        final String month = months[monthIndex];
        final List<ReservationHistoryItem> reservations = grouped[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Text(
                month,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: primaryDark,
                ),
              ),
            ),
            ...reservations.map(
              (reservation) => HistoryReservationCard(
                reservation: reservation,
                primaryDark: primaryDark,
                accentIndigo: accentIndigo,
                onReceiptTap: () => onReceiptTap(reservation),
                onRepeatTap: () => onRepeatTap(reservation),
              ),
            ),
          ],
        );
      },
    );
  }
}
