import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/domain/usecases/auth/check_auth.dart';
import 'package:money_manager/injection_container.dart' as di;
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/pages/login_page.dart';
import 'package:money_manager/presentation/pages/main_page.dart';
import 'package:money_manager/presentation/pages/onboarding/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  final CheckAuthUseCase checkAuthUseCase;
  const SplashPage({super.key, required this.checkAuthUseCase});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _fadeIn = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scaleIn = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );
    _slideUp = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
    );

    _controller.forward();
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final prefs = di.sl<SharedPreferences>();
    final results = await Future.wait([
      widget.checkAuthUseCase.call(),
      Future.delayed(const Duration(milliseconds: 1600)),
    ]);
    if (!mounted) return;

    final onboardingDone = prefs.getBool('onboardingComplete') ?? false;
    if (!onboardingDone) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, _, _) => const OnboardingPage(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
      return;
    }

    final isLoggedIn = results[0] as bool;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => isLoggedIn ? const TripsPage() : const LoginPage(),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.secondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.scale(
                    scale: _scaleIn.value,
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.airplanemode_active, size: 52, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'TripPace',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: Text(
                      AppLocalizations.of(context)!.splashSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 15,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => Opacity(
                  opacity: _fadeIn.value,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.6)),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
