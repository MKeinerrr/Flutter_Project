class ReservationRequest {
  const ReservationRequest({
    required this.fecha,
    required this.hora,
    required this.asistentes,
    this.notas,
  });

  final DateTime fecha;
  final String hora;
  final int asistentes;
  final String? notas;
}
