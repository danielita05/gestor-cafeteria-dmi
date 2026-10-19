import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/core/failure.dart';

void main() {
  group('Failure hierarchy and implementations', () {
    group('NetworkFailure', () {
      test('should instantiate with default message and be a subtype of Failure and Exception', () {
        const failure = NetworkFailure();

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.message, 'No se pudo conectar al servidor');
      });
    });

    group('ServerFailure', () {
      test('should instantiate with status code, default message and be a subtype of Failure and Exception', () {
        const failure = ServerFailure(500);

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.statusCode, 500);
        expect(failure.message, 'Error del Servidor');
      });
    });

    group('NotFoundFailure', () {
      test('should instantiate with custom message and be a subtype of Failure and Exception', () {
        const failure = NotFoundFailure('Recurso no encontrado');

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.message, 'Recurso no encontrado');
      });
    });

    group('ConflictFailure', () {
      test('should instantiate with custom message and be a subtype of Failure and Exception', () {
        const failure = ConflictFailure('Conflicto con recurso existente');

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.message, 'Conflicto con recurso existente');
      });
    });

    group('ValidationFailure', () {
      test('should instantiate with field errors, default message and be a subtype of Failure and Exception', () {
        const fields = {'email': 'Email inválido', 'password': 'Muy corta'};
        const failure = ValidationFailure(fields);

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.message, 'Error de Validación');
        expect(failure.fields, fields);
        expect(failure.fields['email'], 'Email inválido');
        expect(failure.fields['password'], 'Muy corta');
      });
    });

    group('UnexpectedFailure', () {
      test('should instantiate with status code, custom message and be a subtype of Failure and Exception', () {
        const failure = UnexpectedFailure(418, 'Soy una tetera');

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.statusCode, 418);
        expect(failure.message, 'Soy una tetera');
      });
    });

    group('Pattern Matching / Exhaustiveness', () {
      test('should correctly match every Failure subtype in a switch expression', () {
        String describeFailure(Failure failure) {
          return switch (failure) {
            NetworkFailure() => 'network',
            ServerFailure(statusCode: final code) => 'server: $code',
            NotFoundFailure(message: final msg) => 'not_found: $msg',
            ConflictFailure(message: final msg) => 'conflict: $msg',
            ValidationFailure(fields: final f) => 'validation: ${f.length}',
            UnexpectedFailure(statusCode: final code, message: final msg) =>
              'unexpected: $code - $msg',
          };
        }

        expect(describeFailure(const NetworkFailure()), 'network');
        expect(describeFailure(const ServerFailure(503)), 'server: 503');
        expect(
          describeFailure(const NotFoundFailure('Item missing')),
          'not_found: Item missing',
        );
        expect(
          describeFailure(const ConflictFailure('Duplicate entry')),
          'conflict: Duplicate entry',
        );
        expect(
          describeFailure(const ValidationFailure({'field': 'error'})),
          'validation: 1',
        );
        expect(
          describeFailure(const UnexpectedFailure(520, 'Unknown')),
          'unexpected: 520 - Unknown',
        );
      });
    });
  });
}
