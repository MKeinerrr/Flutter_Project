import 'package:flutter/material.dart';

/// HistorialScreen — Shows reservation history with summary stats
/// and a detailed list of past/pending/cancelled bookings.
class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  // Palette
  static const Color _primaryDark = Color(0xFF1A0A4C);
  static const Color _accentIndigo = Color(0xFF3D3B8E);

  // Hardcoded reservation data
  static final List<Map<String, dynamic>> _reservations = [
    {
      'salon': 'Salón Caribe',
      'initial': 'C',
      'color': _accentIndigo,
      'date': '15 Mar 2026 · 10:00 AM',
      'guests': '45 asistentes',
      'status': 'Completada',
    },
    {
      'salon': 'Salón Ejecutivo',
      'initial': 'E',
      'color': const Color(0xFFA8D8F0),
      'date': '20 Mar 2026 · 2:00 PM',
      'guests': '30 asistentes',
      'status': 'Completada',
    },
    {
      'salon': 'Salón Vista Mar',
      'initial': 'V',
      'color': _primaryDark,
      'date': '28 Mar 2026 · 9:00 AM',
      'guests': '100 asistentes',
      'status': 'Pendiente',
    },
    {
      'salon': 'Salón Bolívar',
      'initial': 'B',
      'color': _accentIndigo,
      'date': '02 Abr 2026 · 11:00 AM',
      'guests': '55 asistentes',
      'status': 'Completada',
    },
    {
      'salon': 'Salón Premier',
      'initial': 'P',
      'color': const Color(0xFFA8D8F0),
      'date': '10 Abr 2026 · 4:00 PM',
      'guests': '180 asistentes',
      'status': 'Cancelada',
    },
  ];

  /// Returns the status color (green, orange or red).
  static Color _statusColor(String status) {
    switch (status) {
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

  /// Returns the icon for a given status.
  static IconData _statusIcon(String status) {
    switch (status) {
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
    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(title: const Text('Historial de Reservas')),

      // --- Body ---
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Summary stats row
          _buildSummaryRow(),
          const SizedBox(height: 20),

          // Section title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Mis Reservas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Reservation list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _reservations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _reservationCard(_reservations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────── Widgets ─────────────────────────────

  /// Top summary row with count cards for each status.
  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _summaryCard('3', 'Completadas', Colors.green, Icons.check_circle),
          const SizedBox(width: 10),
          _summaryCard('1', 'Pendiente', Colors.orange, Icons.schedule),
          const SizedBox(width: 10),
          _summaryCard('1', 'Cancelada', Colors.red, Icons.cancel),
        ],
      ),
    );
  }

  /// A small stat card used in the summary row.
  Widget _summaryCard(
    String count,
    String label,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                '$count $label',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single reservation card with a colored left-border accent.
  Widget _reservationCard(Map<String, dynamic> reservation) {
    final String status = reservation['status'] as String;
    final Color color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Subtle left-border accent
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        // Leading avatar with salon initial
        leading: CircleAvatar(
          backgroundColor: reservation['color'] as Color,
          child: Text(
            reservation['initial'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Salon name
        title: Text(
          reservation['salon'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: _primaryDark,
          ),
        ),

        // Date & guest info
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  reservation['date'] as String,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.people, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  reservation['guests'] as String,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),

        // Status chip
        trailing: Chip(
          label: Text(
            status,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          backgroundColor: color.withAlpha(25),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
