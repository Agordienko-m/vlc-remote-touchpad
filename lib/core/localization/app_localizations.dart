import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Простой сервис локализации без тяжёлых зависимостей (Русский и Английский)
class AppLocalizations {
  static final AppLocalizations _instance = AppLocalizations._internal();
  factory AppLocalizations() => _instance;
  AppLocalizations._internal();

  String _currentLang = 'en';

  String get currentLang => _currentLang;

  /// Инициализация локализации с автоопределением или из сохраненных настроек
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(AppConstants.keyLanguage);
    if (savedLang != null && (savedLang == 'ru' || savedLang == 'en')) {
      _currentLang = savedLang;
    } else {
      // Автоопределение языка системы при первом запуске
      final systemLocale = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      if (systemLocale == 'ru') {
        _currentLang = 'ru';
      } else {
        _currentLang = 'en';
      }
      await prefs.setString(AppConstants.keyLanguage, _currentLang);
    }
  }

  /// Переключить язык между ru и en и сохранить в SharedPreferences
  Future<void> toggleLanguage() async {
    _currentLang = (_currentLang == 'ru') ? 'en' : 'ru';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, _currentLang);
  }

  /// Установить конкретный язык
  Future<void> setLanguage(String lang) async {
    if (lang == 'ru' || lang == 'en') {
      _currentLang = lang;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyLanguage, _currentLang);
    }
  }

  /// Словарь переводов
  final Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      // Общие / Меню
      'appTitle': 'VLC Remote',
      'serverMode': 'Сервер',
      'serverModeDesc': 'Запуск локального сервера\nдля управления VLC',
      'remoteMode': 'Пульт',
      'remoteModeDesc': 'Управление VLC\nс другого устройства',
      'platform': 'Платформа',
      'exit': 'Выйти',
      'close': 'Закрыть',
      'cancel': 'Отмена',
      'send': 'Отправить',
      'save': 'Сохранить',

      // Экран Сервера (ServerScreen)
      'serverTitle': 'VLC Сервер',
      'serverStatus': 'Статус сервера',
      'localIp': 'Локальный IP',
      'port': 'Порт: 8085',
      'start': 'Запустить',
      'stop': 'Остановить',
      'getting': 'Получение...',
      'notFound': 'Не найден',
      'vlcPasswordTitle': 'Пароль VLC',
      'vlcPasswordHint': 'Пароль VLC HTTP',
      'windowsVolume': 'Громкость Windows',
      'volumeDown': 'Тише',
      'mute': 'Mute',
      'volumeUp': 'Громче',

      // Экран Пульта (RemoteScreen)
      'remoteTitle': 'Пульт VLC',
      'connected': 'Подключено',
      'disconnected': 'Отключено',
      'connect': 'Подключить',
      'disconnect': 'Отключить',
      'ipHint': 'IP-адрес сервера',
      'tabVlc': 'Пульт VLC',
      'tabTouchpad': 'Тачпад',
      'noPlaylist': 'Плейлист пуст',
      'unknownTrack': 'Неизвестный трек',
      'shutdownConfirmTitle': 'Выключение компьютера',
      'shutdownConfirmContent': 'Выключить компьютер через 5 секунд?',
      'shutdownBtn': 'Выключить',
      'keyboardTitle': 'Клавиатура / Ввод',
      'keyboardHint': 'Введите текст для отправки...',
      'settingsTitle': 'Настройки',
      'touchpadSensitivity': 'Чувствительность тачпада',
      'connectionSettings': 'Настройки подключения',
      'controlButtons': 'Управление',
      'shutdownTooltip': 'Выключить ПК',
      'keyboardTooltip': 'Ввод с клавиатуры',
      'settingsTooltip': 'Настройки',
    },
    'en': {
      // General / Menu
      'appTitle': 'VLC Remote',
      'serverMode': 'Server',
      'serverModeDesc': 'Start local server\nto control VLC',
      'remoteMode': 'Remote',
      'remoteModeDesc': 'Control VLC\nfrom another device',
      'platform': 'Platform',
      'exit': 'Exit',
      'close': 'Close',
      'cancel': 'Cancel',
      'send': 'Send',
      'save': 'Save',

      // Server Screen (ServerScreen)
      'serverTitle': 'VLC Server',
      'serverStatus': 'Server Status',
      'localIp': 'Local IP',
      'port': 'Port: 8085',
      'start': 'Start',
      'stop': 'Stop',
      'getting': 'Getting...',
      'notFound': 'Not found',
      'vlcPasswordTitle': 'VLC Password',
      'vlcPasswordHint': 'VLC HTTP Password',
      'windowsVolume': 'Windows Volume',
      'volumeDown': 'Volume Down',
      'mute': 'Mute',
      'volumeUp': 'Volume Up',

      // Remote Screen (RemoteScreen)
      'remoteTitle': 'VLC Remote',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'connect': 'Connect',
      'disconnect': 'Disconnect',
      'ipHint': 'Server IP Address',
      'tabVlc': 'VLC Remote',
      'tabTouchpad': 'Touchpad',
      'noPlaylist': 'Playlist is empty',
      'unknownTrack': 'Unknown Track',
      'shutdownConfirmTitle': 'Shutdown Computer',
      'shutdownConfirmContent': 'Shutdown computer in 5 seconds?',
      'shutdownBtn': 'Shutdown',
      'keyboardTitle': 'Keyboard / Input',
      'keyboardHint': 'Enter text to send...',
      'settingsTitle': 'Settings',
      'touchpadSensitivity': 'Touchpad Sensitivity',
      'connectionSettings': 'Connection Settings',
      'controlButtons': 'Controls',
      'shutdownTooltip': 'Shutdown PC',
      'keyboardTooltip': 'Keyboard Input',
      'settingsTooltip': 'Settings',
    },
  };

  /// Получить перевод по ключу
  String translate(String key) {
    return _localizedValues[_currentLang]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
