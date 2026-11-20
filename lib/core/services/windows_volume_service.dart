/// Сервис для управления системной громкостью Windows
class WindowsVolumeService {
  /// Увеличить громкость на N шагов
  static Future<void> volumeUp(int steps) async {
    for (int i = 0; i < steps; i++) {
      await _sendKeyPress(0xAF); // VK_VOLUME_UP
    }
  }

  /// Уменьшить громкость на N шагов
  static Future<void> volumeDown(int steps) async {
    for (int i = 0; i < steps; i++) {
      await _sendKeyPress(0xAE); // VK_VOLUME_DOWN
    }
  }

  /// Переключить звук
  static Future<void> mute() async {
    await _sendKeyPress(0xAD); // VK_VOLUME_MUTE
  }

  /// Отправить нажатие клавиши
  static Future<void> _sendKeyPress(int keyCode) async {
    // Симуляция нажатия мультимедийной клавиши громкости
  }
}