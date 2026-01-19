import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localePrefKey = 'preferred_locale';

class LocaleController extends ChangeNotifier {
  Locale? _locale;
  bool _initialized = false;

  Locale? get locale => _locale;
  bool get initialized => _initialized;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCode = prefs.getString(_localePrefKey);
    final locale = _parseLocaleCode(storedCode);
    _locale = locale;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, locale.languageCode);
    _locale = locale;
    _initialized = true;
    notifyListeners();
  }

  Locale? _parseLocaleCode(String? code) {
    if (code == null) {
      return null;
    }
    if (code == 'en' || code == 'ar') {
      return Locale(code);
    }
    return null;
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found in widget tree.');
    return scope!.notifier!;
  }
}
