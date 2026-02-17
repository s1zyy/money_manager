import 'package:money_manager/data/datasources/auth_local_data_source.dart';
import 'package:money_manager/data/datasources/auth_remote_data_source.dart';
import 'package:money_manager/domain/entities/auth_result.dart';
import 'package:money_manager/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository{
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource
    });


  @override
  Future<AuthResult> login(String email, String password) async {
    
    final authModel = await remoteDataSource.login(email, password);
    await localDataSource.saveToken(authModel.token);
    return authModel;
  }
  
  @override
  Future<AuthResult> register(String email, String password, String name) async {
    final authModel = await remoteDataSource.register(email, password, name);
    await localDataSource.saveToken(authModel.token);
    return authModel;
  }

}