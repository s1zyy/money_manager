import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:money_manager/domain/entities/auth_result.dart';
import 'package:money_manager/domain/repositories/auth_repository.dart';

const _webClientId =
    '19599645200-rsmfv5q66dqh37obbvbfrccnj2sr3vln.apps.googleusercontent.com';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase({required this.repository});

  Future<AuthResult> call() async {
    final googleSignIn = GoogleSignIn(serverClientId: _webClientId);
    try {
      final account = await googleSignIn.signIn();
      if (account == null) throw Exception('Google sign in cancelled');

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Failed to get Google ID token');

      return await repository.googleSignIn(idToken);
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed' || e.message?.contains('access_denied') == true) {
        throw Exception('Google sign in cancelled');
      }
      rethrow;
    }
  }
}
