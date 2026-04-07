import '../models/mi_reserva_view_model.dart';
import '../models/reservation_history.dart';
import 'historial_api_service.dart';

class MiReservaService {
  const MiReservaService({required HistorialApiService historialApiService})
    : _historialApiService = historialApiService;

  final HistorialApiService _historialApiService;

  Future<ReservationHistoryItem?> fetchActiveReservation({
    required String token,
    DateTime? now,
  }) async {
    final List<ReservationHistoryItem> history = await _historialApiService
        .fetchHistory(token: token);

    final DateTime reference = now ?? DateTime.now();
    final DateTime today = DateTime(reference.year, reference.month, reference.day);

    final List<ReservationHistoryItem> active = history
        .where(
          (item) =>
              item.status == 'Confirmada' && !item.sortDate.isBefore(today),
        )
        .toList()
      ..sort((a, b) => a.sortDate.compareTo(b.sortDate));

    if (active.isEmpty) {
      return null;
    }
    return active.first;
  }

  MiReservaViewModel buildViewModel(ReservationHistoryItem reservation) {
    return MiReservaViewModel(
      reservation: reservation,
      gallery: const [
        'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1000&q=80',
      ],
      amenities: const [
        'Baños privados',
        'Parqueadero',
        'Aire acondicionado',
        'Wifi de alta velocidad',
        'Planta electrica',
        'Zona de catering',
        'Sonido y microfonos',
      ],
      reviews: const [
        MiReservaReview(
          user: 'Laura M.',
          score: 5,
          text: 'Excelente atencion y el salon impecable. Muy recomendado.',
        ),
        MiReservaReview(
          user: 'Carlos P.',
          score: 4,
          text: 'Buena ubicacion y servicios completos. Volveria a reservar.',
        ),
        MiReservaReview(
          user: 'Andrea R.',
          score: 5,
          text: 'El wifi y el aire acondicionado funcionaron perfecto todo el evento.',
        ),
      ],
    );
  }
}
