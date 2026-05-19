import 'reservation_history.dart';
import 'salon_view_model.dart';

class MiReservaViewModel {
  const MiReservaViewModel({
    required this.reservation,
    required this.salon,
    required this.gallery,
    required this.amenities,
  });

  final ReservationHistoryItem reservation;
  final SalonViewModel salon;
  final List<String> gallery;
  final List<String> amenities;
}
