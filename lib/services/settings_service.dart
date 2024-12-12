import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _darkModeKey = 'dark_mode';
  static const String _useBiometricsKey = 'use_biometrics';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _languageKey = 'language';

  late SharedPreferences _prefs;

  SettingsService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isDarkMode => _prefs.getBool(_darkModeKey) ?? false;
  bool get useBiometrics => _prefs.getBool(_useBiometricsKey) ?? false;
  bool get notificationsEnabled => _prefs.getBool(_notificationsEnabledKey) ?? true;
  String get language => _prefs.getString(_languageKey) ?? 'en';

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setUseBiometrics(bool value) async {
    await _prefs.setBool(_useBiometricsKey, value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_notificationsEnabledKey, value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    await _prefs.setString(_languageKey, value);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _prefs.remove(_darkModeKey);
    await _prefs.remove(_useBiometricsKey);
    await _prefs.remove(_notificationsEnabledKey);
    await _prefs.remove(_languageKey);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setDarkMode(!isDarkMode);
  }

  Future<void> toggleBiometrics() async {
    await setUseBiometrics(!useBiometrics);
  }

  Future<void> toggleNotifications() async {
    await setNotificationsEnabled(!notificationsEnabled);
  }
}
