import 'package:flutter/material.dart';
import 'package:money_manager/domain/usecases/auth/check_auth.dart';
import 'package:money_manager/presentation/pages/login_page.dart';
import 'package:money_manager/presentation/pages/main_page.dart';

class SplashPage extends StatefulWidget {
  final CheckAuthUseCase checkAuthUseCase;

  const SplashPage({super.key, required this.checkAuthUseCase});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final results = await Future.wait([
      widget.checkAuthUseCase.call(),
      Future.delayed(const Duration(milliseconds: 800)),
    ]);
    if (!mounted) return;

    final isLoggedIn = results[0] as bool;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const TripsPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Money Manager',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
