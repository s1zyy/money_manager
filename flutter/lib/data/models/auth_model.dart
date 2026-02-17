
import 'package:money_manager/domain/entities/auth_result.dart';

class AuthModel extends AuthResult {
  AuthModel({required  super.token});


  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(token: json['token'] as String);
  }
}