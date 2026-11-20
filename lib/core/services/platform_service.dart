import 'dart:io';

/// Утилиты для определения платформы
class PlatformUtils {
  static bool get isWindows => Platform.isWindows;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isDesktop => isWindows;
  static bool get isMobile => isAndroid;
}