class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([super.message = 'Pas de connexion internet']);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([
    super.message = 'Non autorisé - Veuillez vous reconnecter',
  ]) : super(statusCode: 401);
}

class ServerException extends AppException {
  ServerException([
    super.message = 'Erreur serveur - Veuillez réessayer plus tard',
  ]) : super(statusCode: 500);
}

class ValidationException extends AppException {
  ValidationException([super.message = 'Données invalides'])
    : super(statusCode: 400);
}

class NotFoundException extends AppException {
  NotFoundException([super.message = 'Ressource non trouvée'])
    : super(statusCode: 404);
}

class ForbiddenException extends AppException {
  ForbiddenException([super.message = 'Accès interdit'])
    : super(statusCode: 403);
}
