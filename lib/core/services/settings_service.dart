import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Сервис для управления настройками
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();

  factory SettingsService() => _instance;

  SettingsService._internal();

  late SharedPreferences _prefs;

  /// Инициализация сервиса
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Получить сохранённый IP сервера
  String? getServerIp() {
    return _prefs.getString(AppConstants.keyServerIp);
  }

  /// Сохранить IP сервера
  Future<void> saveServerIp(String ip) async {
    await _prefs.setString(AppConstants.keyServerIp, ip);
  }

  /// Получить пароль VLC
  String getVlcPassword() {
    return _prefs.getString(AppConstants.keyVlcPassword) ?? '';
  }

  /// Сохранить пароль VLC
  Future<void> saveVlcPassword(String password) async {
    await _prefs.setString(AppConstants.keyVlcPassword, password);
  }

  /// Получить режим автоопределения
  bool getAutoDetectMode() {
    return _prefs.getBool(AppConstants.keyAutoDetectMode) ?? true;
  }

  /// Сохранить режим автоопределения
  Future<void> saveAutoDetectMode(bool autoDetect) async {
    await _prefs.setBool(AppConstants.keyAutoDetectMode, autoDetect);
  }

  /// Получить чувствительность тачпада
  double getTouchpadSensitivity() {
    return _prefs.getDouble(AppConstants.keyTouchpadSensitivity) ?? 4.0;
  }

  /// Сохранить чувствительность тачпада
  Future<void> saveTouchpadSensitivity(double sensitivity) async {
    await _prefs.setDouble(AppConstants.keyTouchpadSensitivity, sensitivity);
  }
}