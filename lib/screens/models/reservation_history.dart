import 'package:flutter/material.dart';

class ReservationHistoryItem {
  const ReservationHistoryItem({
    required this.id,
    required this.salon,
    required this.initial,
    required this.color,
    required this.dateLabel,
    required this.month,
    required this.guests,
    required this.status,
    required this.payment,
    required this.amount,
    required this.notes,
    required this.sortDate,
  });

  final String id;
  final String salon;
  final String initial;
  final Color color;
  final String dateLabel;
  final String month;
  final int guests;
  final String status;
  final String payment;
  final int amount;
  final String notes;
  final DateTime sortDate;
}
