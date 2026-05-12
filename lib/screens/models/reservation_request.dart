class ReservationRequest {
  const ReservationRequest({
    required this.fecha,
    required this.franjaHorariaId,
    required this.asistentes,
    this.notas,
    this.descuento,
    this.abono,
    this.motivo,
    this.garantia,
    this.metodoId,
    this.numTransaccion,
  });

  final DateTime fecha;
  final int franjaHorariaId;
  final int asistentes;
  final String? notas;
  final double? descuento;
  final double? abono;
  final String? motivo;
  final String? garantia;
  final int? metodoId;
  final String? numTransaccion;
}
