import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:money_manager/domain/entities/auth_result.dart';
import 'package:money_manager/domain/repositories/auth_repository.dart';

class AppleSignInUseCase {
  final AuthRepository repository;

  AppleSignInUseCase({required this.repository});

  Future<AuthResult> call() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );

    final identityToken = credential.identityToken;
    if (identityToken == null) throw Exception('Failed to get Apple identity token');

    final name = [credential.givenName, credential.familyName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');

    return await repository.appleSignIn(identityToken, name.isEmpty ? null : name);
  }
}
