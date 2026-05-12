class CatalogItem {
  const CatalogItem({required this.id, required this.name});

  final int id;
  final String name;

  factory CatalogItem.fromApi(Map<String, dynamic> raw) {
    final dynamic idRaw = raw['id'] ?? raw['id_categoria'] ?? raw['id_metodo'];
    final int id = idRaw is num ? idRaw.toInt() : int.tryParse('$idRaw') ?? 0;
    return CatalogItem(id: id, name: (raw['nombre'] as String?) ?? '');
  }
}

class FranjaHorariaItem {
  const FranjaHorariaItem({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
  });

  final int id;
  final String name;
  final String start;
  final String end;

  String get label => '$name ($start - $end)';

  factory FranjaHorariaItem.fromApi(Map<String, dynamic> raw) {
    final dynamic idRaw = raw['id'] ?? raw['id_franja_horaria'];
    final int id = idRaw is num ? idRaw.toInt() : int.tryParse('$idRaw') ?? 0;
    return FranjaHorariaItem(
      id: id,
      name: (raw['nombre'] as String?) ?? '',
      start: (raw['hora_inicio'] as String?) ?? '',
      end: (raw['hora_fin'] as String?) ?? '',
    );
  }
}

class MetodoPagoItem {
  const MetodoPagoItem({required this.id, required this.name});

  final int id;
  final String name;

  factory MetodoPagoItem.fromApi(Map<String, dynamic> raw) {
    final dynamic idRaw = raw['id'] ?? raw['id_metodo'];
    final int id = idRaw is num ? idRaw.toInt() : int.tryParse('$idRaw') ?? 0;
    return MetodoPagoItem(id: id, name: (raw['nombre'] as String?) ?? '');
  }
}
