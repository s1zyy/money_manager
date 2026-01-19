class ServerException implements Exception {
  final String message;
  
  ServerException(this.message);
}

class UnauthorizedException implements Exception{}

class NetworkException implements Exception{}
