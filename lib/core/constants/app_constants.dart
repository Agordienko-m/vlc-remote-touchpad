/// Константы приложения
class AppConstants {
  /// Порт WebSocket-сервера
  static const int serverPort = 8085;

  /// Префикс для WebSocket
  static const String wsPath = '/ws';

  /// Ключи для shared_preferences
  static const String keyServerIp = 'server_ip';
  static const String keyVlcPassword = 'vlc_password';
  static const String keyAutoDetectMode = 'auto_detect_mode';

  static const String keyTouchpadSensitivity = 'touchpad_sensitivity';
  /// Таймауты
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const Duration reconnectDelay = Duration(seconds: 3);
  static const Duration pingInterval = Duration(seconds: 10);

  /// VLC HTTP интерфейс
  static const String vlcHost = '127.0.0.1';
  static const int vlcPort = 8080;
  static const String vlcAuthUser = ''; // VLC использует только пароль
}