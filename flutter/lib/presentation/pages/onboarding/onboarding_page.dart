import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/injection_container.dart' as di;
import 'package:money_manager/presentation/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  late AnimationController _animController;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _fades = [
      _fade(0.00, 0.50),
      _fade(0.14, 0.64),
      _fade(0.28, 0.78),
      _fade(0.42, 0.92),
      _fade(0.56, 1.00),
    ];
    _slides = [
      _slide(0.00, 0.55),
      _slide(0.14, 0.69),
      _slide(0.28, 0.83),
      _slide(0.42, 0.97),
      _slide(0.56, 1.00),
    ];
    _animController.forward();
  }

  Animation<double> _fade(double start, double end) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Interval(start, end, curve: Curves.easeOut)),
      );

  Animation<Offset> _slide(double start, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
        CurvedAnimation(parent: _animController, curve: Interval(start, end, curve: Curves.easeOut)),
      );

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _animController.forward(from: 0);
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _complete() async {
    final prefs = di.sl<SharedPreferences>();
    await prefs.setBool('onboardingComplete', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const LoginPage(),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Widget _animated(int idx, Widget child) => FadeTransition(
        opacity: _fades[idx],
        child: SlideTransition(position: _slides[idx], child: child),
      );

  bool get _isDark => _currentPage == 0;
  bool get _isLast => _currentPage == _totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              _welcomePage(),
              _benefitsPage(),
              _supportPage(),
            ],
          ),
          _bottomNav(),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    final activeColor = _isDark ? Colors.white : AppTheme.primary;
    final inactiveColor =
        _isDark ? Colors.white30 : AppTheme.primary.withValues(alpha: 0.25);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 64,
                child: _isLast
                    ? null
                    : TextButton(
                        onPressed: _complete,
                        child: Text(
                          'Skip',
                          style: TextStyle(color: activeColor.withValues(alpha: 0.7)),
                        ),
                      ),
              ),
              Row(
                children: List.generate(_totalPages, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage ? activeColor : inactiveColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              SizedBox(
                width: 64,
                child: _isLast
                    ? null
                    : TextButton(
                        onPressed: _next,
                        child: Text(
                          'Next',
                          style:
                              TextStyle(color: activeColor, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Page 1: Welcome ────────────────────────────────────────────────────────

  Widget _welcomePage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.secondary],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _animated(
                0,
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.airplanemode_active, size: 64, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
              _animated(
                1,
                const Text(
                  'Welcome to CoTravel!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _animated(
                2,
                Text(
                  'The smart way to share trip expenses with friends — fair, fast, and hassle-free.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.55,
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Page 2: Benefits ───────────────────────────────────────────────────────

  Widget _benefitsPage() {
    return Container(
      color: AppTheme.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _animated(
                0,
                const Text(
                  'Why travelers\nlove CoTravel',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 44),
              _animated(
                1,
                _benefitRow(
                  icon: Icons.calculate_outlined,
                  title: 'Auto-split expenses',
                  desc: 'Add an expense and every person\'s share is calculated instantly — no mental math.',
                ),
              ),
              const SizedBox(height: 28),
              _animated(
                2,
                _benefitRow(
                  icon: Icons.shuffle_rounded,
                  title: 'Settle with fewer transfers',
                  desc: 'Our smart algorithm minimizes the number of payments at the end of the trip.',
                ),
              ),
              const SizedBox(height: 28),
              _animated(
                3,
                _benefitRow(
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'No sign-up required',
                  desc: 'Add friends as virtual participants right away — they can claim their account later.',
                ),
              ),
              const SizedBox(height: 28),
              _animated(
                4,
                _benefitRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Daily budget tracking',
                  desc: 'Set a budget per person. CoTravel calculates your daily limit and shows how much you\'ve spent today.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitRow({required IconData icon, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 5),
              Text(desc,
                  style:
                      const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.45)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Page 3: Get Started ────────────────────────────────────────────────────

  Widget _supportPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.secondary],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _animated(
                0,
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rocket_launch_outlined, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
              _animated(
                1,
                const Text(
                  'Ready to go!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _animated(
                2,
                Text(
                  'Create your first trip, add your friends,\nand start tracking expenses together.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.55,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              _animated(
                3,
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextButton(
                      onPressed: _complete,
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _animated(
                4,
                TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse('https://buymeacoffee.com/s1zy'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: Icon(Icons.coffee, size: 18, color: Colors.white.withValues(alpha: 0.7)),
                  label: Text(
                    'Buy me a coffee',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
