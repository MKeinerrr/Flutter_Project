class WalletMethod {
  const WalletMethod({
    required this.id,
    required this.metodoId,
    required this.metodo,
    required this.estado,
    this.alias,
    this.numero,
  });

  final int id;
  final int metodoId;
  final String metodo;
  final bool estado;
  final String? alias;
  final String? numero;

  factory WalletMethod.fromApi(Map<String, dynamic> raw) {
    final dynamic idRaw = raw['id'];
    final int id = idRaw is num ? idRaw.toInt() : int.tryParse('$idRaw') ?? 0;
    final dynamic metodoIdRaw = raw['metodo_id'] ?? raw['id_metodo'];
    final int metodoId = metodoIdRaw is num
        ? metodoIdRaw.toInt()
        : int.tryParse('$metodoIdRaw') ?? 0;
    return WalletMethod(
      id: id,
      metodoId: metodoId,
      metodo: (raw['metodo'] as String?) ?? (raw['nombre'] as String?) ?? '',
      alias: raw['alias'] as String?,
      numero: raw['numero'] as String?,
      estado: raw['estado'] == true || raw['estado'] == 1,
    );
  }
}
