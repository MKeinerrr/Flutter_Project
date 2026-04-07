# flutter_proyecto

App Flutter para búsqueda de salones, reservas, historial, perfil y vista de "Mi reserva".

## Características principales

- Autenticación: login, registro y recuperación de contraseña.
- Catálogo de salones con filtros y ordenamiento.
- Creación de reservas autenticadas.
- Historial de reservas por usuario.
- Pantalla dedicada de "Mi reserva" con detalle visual.
- Navegación inferior persistente entre pantallas.

## Requisitos

- Flutter SDK 3.22+ (Dart 3.10+)
- Android Studio o VS Code + emulador/dispositivo
- Backend en ejecución (carpeta `backend_auth`)

## Instalación y ejecución

```bash
cd flutter_proyecto
flutter pub get
flutter run
```

## Configuración de API

La app toma la URL base desde `lib/config/api_config.dart`.

Comportamiento por defecto:
- Web: `http://localhost:8000`
- Android emulador: `http://10.0.2.2:8000`
- Otras plataformas: `http://localhost:8000`

También puedes sobreescribir con define:

```bash
flutter run --dart-define=API_BASE_URL=http://TU_IP:8000
```

## Flujo recomendado de desarrollo local

1. Levantar backend:

```bash
cd ../backend_auth
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

2. Levantar Flutter:

```bash
cd ../flutter_proyecto
flutter run
```

## Arquitectura (resumen)

```text
lib/
	auth/
		auth_controller.dart              # Sesión y llamadas auth
	config/
		api_config.dart                   # URL base API por plataforma
	screens/
		home_screen.dart
		salones_screen.dart
		mi_reserva_screen.dart
		historial_screen.dart
		perfil_screen.dart
		auth_screen.dart
		models/                           # Modelos de UI y requests
		services/                         # Capa de llamadas/API y lógica de datos
		utils/                            # Helpers de formato y filtrado
		widgets/                          # Widgets por módulo (home, salones, auth, etc.)
```

## Pantallas

- Inicio: resumen y acceso rápido.
- Salones: búsqueda, filtros, orden y reserva.
- Mi reserva: detalle de la reserva activa.
- Historial: reservas previas del usuario.
- Perfil: sesión y accesos de cuenta.
- Auth: login/registro/olvidé contraseña.

## Dependencias clave

- `http`: consumo de API REST.

## Comandos útiles

```bash
flutter analyze
flutter test
flutter clean
```

## Problemas comunes

- La app no conecta con backend:
	- Verifica que FastAPI esté en puerto 8000.
	- En Android emulador usa `10.0.2.2`, no `localhost`.

- Cambiaste backend y no refleja en app:
	- Ejecuta hot restart.

- Error por dependencias:
	- Ejecuta `flutter pub get` nuevamente.