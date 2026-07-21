
import 'package:money_manager/domain/entities/auth_result.dart';

class AuthModel extends AuthResult {
  AuthModel({required super.token, required super.name, required super.email});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}