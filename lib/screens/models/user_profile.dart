class UserProfile {
  const UserProfile({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.usuario,
    this.telefono,
    this.direccion,
    this.fotoUrl,
  });

  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String? usuario;
  final String? telefono;
  final String? direccion;
  final String? fotoUrl;

  factory UserProfile.fromApi(Map<String, dynamic> raw) {
    final dynamic idRaw = raw['id_usuario'] ?? raw['id'];
    final int id = idRaw is num ? idRaw.toInt() : int.tryParse('$idRaw') ?? 0;
    return UserProfile(
      id: id,
      nombre: (raw['nombre'] as String?) ?? '',
      apellido: (raw['apellido'] as String?) ?? '',
      correo: (raw['correo'] as String?) ?? '',
      usuario: raw['usuario'] as String?,
      telefono: raw['telefono'] as String?,
      direccion: raw['direccion'] as String?,
      fotoUrl: raw['foto_url'] as String?,
    );
  }
}

class UserProfileUpdate {
  const UserProfileUpdate({
    this.usuario,
    this.telefono,
    this.direccion,
  });

  final String? usuario;
  final String? telefono;
  final String? direccion;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = {};
    if (usuario != null) {
      payload['usuario'] = usuario;
    }
    if (telefono != null) {
      payload['telefono'] = telefono;
    }
    if (direccion != null) {
      payload['direccion'] = direccion;
    }
    return payload;
  }
}
