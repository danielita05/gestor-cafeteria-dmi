import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/core/http_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Crea un ApiClient que usa el MockClient en lugar de la red real.
ApiClient clienteCon(MockClient mock, {Duration? timeout}) => ApiClient(
  client: mock,
  baseUrl: 'http://prueba',
  timeout: timeout ?? const Duration(seconds: 10),
);

// Respuesta JSON con el Content-Type que manda mini_backend.
http.Response respuestaJson(Object cuerpo, int codigo) => http.Response(
  jsonEncode(cuerpo),
  codigo,
  headers: {'content-type': 'application/json'},
);

void main() {
  group('ApiClient con MockClient', () {
    test('1. GET exitoso (200) devuelve el JSON decodificado', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://prueba/orders');
        return respuestaJson([
          {'id': 1, 'customer': 'Ana', 'drink': 'latte', 'size': 'M'},
        ], 200);
      });
      final api = clienteCon(mock);

      final resultado = await api.get('/orders');

      expect(resultado, isA<List>());
      expect(resultado, [
        {'id': 1, 'customer': 'Ana', 'drink': 'latte', 'size': 'M'},
      ]);
    });

    test('2. respuesta 404 lanza NotFoundFailure con el mensaje de detail', () {
      final mock = MockClient((request) async {
        return respuestaJson({'detail': 'Order 9 not found'}, 404);
      });
      final api = clienteCon(mock);

      expect(
        api.get('/orders/9'),
        throwsA(
          isA<NotFoundFailure>().having(
            (f) => f.message,
            'message',
            'Order 9 not found',
          ),
        ),
      );
    });

    test('3. respuesta 409 lanza ConflictFailure con el mensaje de detail', () {
      final mock = MockClient((request) async {
        return respuestaJson({
          'detail': 'Cannot change status from pending to delivered',
        }, 409);
      });
      final api = clienteCon(mock);

      expect(
        api.patch('/orders/1', {'status': 'delivered'}),
        throwsA(
          isA<ConflictFailure>().having(
            (f) => f.message,
            'message',
            'Cannot change status from pending to delivered',
          ),
        ),
      );
    });

    test('4. respuesta 422 lanza ValidationFailure con el mapa de campos', () {
      final mock = MockClient((request) async {
        return respuestaJson({
          'detail': [
            {
              'loc': ['body', 'customer'],
              'msg': 'Must be 1-50 characters',
            },
          ],
        }, 422);
      });
      final api = clienteCon(mock);

      expect(
        api.post('/orders', {'customer': '', 'drink': 'latte', 'size': 'M'}),
        throwsA(
          isA<ValidationFailure>().having((f) => f.fields, 'fields', {
            'customer': 'Must be 1-50 characters',
          }),
        ),
      );
    });

    test('5. respuesta 503 lanza ServerFailure con statusCode 503', () {
      final mock = MockClient((request) async {
        return respuestaJson({'detail': 'Simulated failure'}, 503);
      });
      final api = clienteCon(mock);

      expect(
        api.get('/orders'),
        throwsA(
          isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 503),
        ),
      );
    });

    group('6. sin conexión o tiempo agotado', () {
      test('una ClientException (sin red) lanza NetworkFailure', () {
        final mock = MockClient((request) async {
          throw http.ClientException('sin red');
        });
        final api = clienteCon(mock);

        expect(api.get('/orders'), throwsA(isA<NetworkFailure>()));
      });

      test('una respuesta más lenta que el timeout lanza NetworkFailure', () {
        final mock = MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return respuestaJson([], 200);
        });
        final api = clienteCon(mock, timeout: const Duration(milliseconds: 50));

        expect(api.get('/orders'), throwsA(isA<NetworkFailure>()));
      });
    });

    test('7. respuesta 300 ya no es éxito y lanza UnexpectedFailure', () {
      final mock = MockClient((request) async {
        return http.Response('', 300);
      });
      final api = clienteCon(mock);

      expect(
        api.get('/orders'),
        throwsA(
          isA<UnexpectedFailure>().having(
            (f) => f.statusCode,
            'statusCode',
            300,
          ),
        ),
      );
    });
  });
}
