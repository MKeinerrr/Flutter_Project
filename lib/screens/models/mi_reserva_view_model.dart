import 'reservation_history.dart';

class MiReservaReview {
  const MiReservaReview({
    required this.user,
    required this.score,
    required this.text,
  });

  final String user;
  final int score;
  final String text;
}

class MiReservaViewModel {
  const MiReservaViewModel({
    required this.reservation,
    required this.gallery,
    required this.amenities,
    required this.reviews,
  });

  final ReservationHistoryItem reservation;
  final List<String> gallery;
  final List<String> amenities;
  final List<MiReservaReview> reviews;
}
