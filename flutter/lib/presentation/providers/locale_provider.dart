import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'locale';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LocaleProvider(SharedPreferences prefs) {
    final saved = prefs.getString(_key);
    if (saved != null) _locale = Locale(saved);
  }

  Future<void> setLocale(Locale locale, SharedPreferences prefs) async {
    _locale = locale;
    await prefs.setString(_key, locale.languageCode);
    notifyListeners();
  }
}
