import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/domain/usecases/auth/check_auth.dart';
import 'package:money_manager/injection_container.dart' as di;
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/pages/splash_page.dart';
import 'package:money_manager/presentation/providers/auth_provider.dart';
import 'package:money_manager/presentation/providers/locale_provider.dart';
import 'package:money_manager/presentation/providers/profile_provider.dart';
import 'package:money_manager/presentation/providers/trips_provider.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  final navigatorKey = GlobalKey<NavigatorState>();

  

  await di.init(navigatorKey: navigatorKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<TripsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<LocaleProvider>()),
      ],
      child: MoneyManagerApp(navigatorKey: navigatorKey),
    ),
  );
}

class MoneyManagerApp extends StatelessWidget {
  
  
  final GlobalKey<NavigatorState> navigatorKey;
  const MoneyManagerApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'TripPace',
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      home: SplashPage(checkAuthUseCase: di.sl<CheckAuthUseCase>()),
    );
  }
}