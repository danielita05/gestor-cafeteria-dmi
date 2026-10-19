# gestor_cafeteria

Cliente Flutter para la API de pedidos de una cafetería ([mini_backend](https://github.com/DMI-2026/mini_backend)). Proyecto de ejemplo de la materia **Desarrollo Móvil Integral** (UTEZ), en el que trabajé:

- `ApiClient` (`lib/core/http_client.dart`): hace las peticiones HTTP y traduce cada respuesta de error al `Failure` correcto (`NotFoundFailure`, `ConflictFailure`, `ValidationFailure`, `ServerFailure`, `UnexpectedFailure`, `NetworkFailure`).
- Pruebas automatizadas del cliente con `MockClient`, sin depender del servidor.

Autora: Daniela Carrate Bahena · 10° C.

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) con Dart 3.13 (probado con Flutter 3.47.2 / Dart 3.13.2).
- [Node.js](https://nodejs.org/) **22.13 o superior** (para `mini_backend`; usa `node:sqlite`).
- Chrome, un emulador de Android o un celular para ejecutar la app.

## Servidor: mini_backend

`mini_backend` es **otro repositorio**; no está copiado dentro de este proyecto.

- Repositorio: https://github.com/DMI-2026/mini_backend (rama `master`)
- Versión con la que se probó: commit [`94d2533`](https://github.com/DMI-2026/mini_backend/commit/94d2533034134e4904dd38df8f2c60d56c2d1d6f) («feat: enable CORS for Flutter web clients»).

Cómo levantarlo (no necesita `npm install`):

```bash
git clone https://github.com/DMI-2026/mini_backend.git
cd mini_backend
node server.js            # Listening on http://0.0.0.0:8000
curl http://localhost:8000/health   # {"status":"ok"}
```

Variables opcionales: `PORT` (8000), `HOST` (0.0.0.0) y `DB_PATH` (app.db). Ejemplo: `PORT=8101 DB_PATH=pruebas.db node server.js`.

## Ejecutar la app

```bash
flutter pub get
flutter run -d chrome                     # usa http://localhost:8000
flutter run                               # emulador Android: usa http://10.0.2.2:8000
```

Para indicar otra dirección del servidor (por ejemplo, un celular físico en la misma red o otro puerto) se usa `API_URL` con `--dart-define`:

```bash
flutter run --dart-define=API_URL=http://192.168.1.50:8000
flutter run -d chrome --dart-define=API_URL=http://localhost:8101
```

## Pruebas

```bash
flutter analyze   # análisis estático, debe terminar sin problemas
flutter test      # pruebas unitarias (no requieren el servidor)
```

- `test/core/failure_test.dart`: jerarquía de `Failure`.
- `test/core/http_client_test.dart`: `ApiClient` con `MockClient` (200, 404, 409, 422, 503, sin conexión, tiempo agotado y 300).

## Estructura de carpetas

```
lib/
  main.dart               # pantalla de prueba que lista los pedidos
  core/
    failure.dart          # sealed class Failure y sus subtipos
    http_client.dart      # ApiClient: GET/POST/PATCH/DELETE y mapeo de errores
test/
  core/
    failure_test.dart
    http_client_test.dart
android/ web/             # plataformas generadas por Flutter
```
