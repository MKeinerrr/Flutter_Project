import '../models/mi_reserva_view_model.dart';
import '../models/reservation_history.dart';
import '../models/salon_view_model.dart';
import 'historial_api_service.dart';
import 'salones_api_service.dart';

class MiReservaService {
  const MiReservaService({
    required HistorialApiService historialApiService,
    required SalonesApiService salonesApiService,
  })
    : _historialApiService = historialApiService,
      _salonesApiService = salonesApiService;

  final HistorialApiService _historialApiService;
  final SalonesApiService _salonesApiService;

  Future<ReservationHistoryItem?> fetchActiveReservation({
    required String token,
    DateTime? now,
  }) async {
    final List<ReservationHistoryItem> active =
        await fetchActiveReservations(token: token, now: now);
    if (active.isEmpty) {
      return null;
    }
    return active.first;
  }

  Future<List<ReservationHistoryItem>> fetchActiveReservations({
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
              (item.status == 'Confirmada' || item.status == 'Pendiente') &&
              !item.sortDate.isBefore(today),
        )
        .toList()
      ..sort((a, b) => a.sortDate.compareTo(b.sortDate));

    return active;
  }

  Future<MiReservaViewModel> buildViewModel({
    required ReservationHistoryItem reservation,
    String? token,
  }) async {
    final SalonViewModel salon = await _salonesApiService.fetchSalonById(
      salonId: reservation.salonId,
      token: token,
    );

    final List<String> gallery = salon.photos.isNotEmpty
        ? salon.photos
        : (salon.photoUrl != null && salon.photoUrl!.trim().isNotEmpty)
            ? [salon.photoUrl!.trim()]
            : const [];

    return MiReservaViewModel(
      reservation: reservation,
      salon: salon,
      gallery: gallery,
      amenities: const [
        'Baños privados',
        'Parqueadero',
        'Aire acondicionado',
        'Wifi de alta velocidad',
        'Planta electrica',
        'Zona de catering',
        'Sonido y microfonos',
      ],
    );
  }
}
