import 'package:money_manager/data/datasources/auth_local_data_source.dart';
import 'package:money_manager/data/datasources/auth_remote_data_source.dart';
import 'package:money_manager/domain/entities/auth_result.dart';
import 'package:money_manager/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<AuthResult> login(String email, String password) async {
    final authModel = await remoteDataSource.login(email, password);
    await localDataSource.saveToken(authModel.token);
    return authModel;
  }

  @override
  Future<AuthResult> register(String email, String password, String name, {String? inviteToken}) async {
    final authModel = await remoteDataSource.register(email, password, name, inviteToken: inviteToken);
    await localDataSource.saveToken(authModel.token);
    return authModel;
  }

  @override
  Future<void> logout() async {
    await localDataSource.deleteToken();
  }

  @override
  Future<bool> hasToken() async {
    final token = await localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> validateInviteToken(String token) {
    return remoteDataSource.validateInviteToken(token);
  }

  @override
  Future<AuthResult> claimInviteWithLogin(String token, String password) async {
    final authModel = await remoteDataSource.claimInviteWithLogin(token, password);
    await localDataSource.saveToken(authModel.token);
    return authModel;
  }
}
