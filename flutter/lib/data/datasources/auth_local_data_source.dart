import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();

}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> deleteToken() async {
    return await secureStorage.delete(key: 'jwt_token');
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'jwt_token');
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'jwt_token', value: token);
  }


}
