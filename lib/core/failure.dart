//Clase Sellada para Gestionar los estados de Fallo

//Clase Principal
sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

//1. Sin Conexion, DNS, timeouts
final class NetworkFailure extends Failure {
  const NetworkFailure() : super("No se pudo conectar al servidor");
}

//2. 5xx Servidor no responde
final class ServerFailure extends Failure {
  const ServerFailure(this.statusCode) : super("Error del Servidor");
  final int statusCode;
}

//3. 404
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

//4. 409
final class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

//5. 422
final class ValidationFailure extends Failure {
  const ValidationFailure(this.fields) : super("Error de Validación");
  final Map<String,String> fields;
}

//Error Desconocido
final class UnexpectedFailure extends Failure{
  const UnexpectedFailure(this.statusCode,super.message);
  final int statusCode;
}






