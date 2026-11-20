import 'ffi/user32_bindings.dart';

/// Сервис для управления мышью и клавиатурой Windows через user32.dll (ffi)
class WindowsMouseService {
  static final User32Bindings _user32 = User32Bindings();

  /// Перемещение курсора на относительное смещение (dx, dy) с коэффициентом чувствительности
  static void moveCursorRel(double dx, double dy, {double sensitivity = 1.2}) {
    final pos = _user32.getCursorPos();
    final newX = pos[0] + (dx * sensitivity).toInt();
    final newY = pos[1] + (dy * sensitivity).toInt();
    _user32.setCursorPos(newX, newY);
  }

  /// Левый клик (нажатие + отпускание)
  static void leftClick() {
    _user32.mouseEvent(User32Bindings.mouseeventfLeftdown, 0, 0, 0, 0);
    _user32.mouseEvent(User32Bindings.mouseeventfLeftup, 0, 0, 0, 0);
  }

  /// Двойной левый клик
  static void doubleLeftClick() {
    leftClick();
    leftClick();
  }

  /// Правый клик (нажатие + отпускание)
  static void rightClick() {
    _user32.mouseEvent(User32Bindings.mouseeventfRightdown, 0, 0, 0, 0);
    _user32.mouseEvent(User32Bindings.mouseeventfRightup, 0, 0, 0, 0);
  }

  /// Прокрутка колёсиком мыши
  static void mouseWheel(int delta) {
    _user32.mouseEvent(User32Bindings.mouseeventfWheel, 0, 0, delta, 0);
  }

  /// Ввод текста с полной поддержкой кириллицы через буфер обмена + Ctrl+V
  static void sendText(String text) {
    if (text.isEmpty) return;
    _user32.setClipboardText(text);
    // Эмуляция Ctrl+V
    // VK_CONTROL = 0x11, 'V' = 0x56
    _user32.keybdEvent(0x11, 0, 0, 0); // Ctrl down
    _user32.keybdEvent(0x56, 0, 0, 0); // V down
    _user32.keybdEvent(0x56, 0, 2, 0); // V up (KEYEVENTF_KEYUP = 2)
    _user32.keybdEvent(0x11, 0, 2, 0); // Ctrl up
  }

  /// Отправка конкретной клавиши (например, Backspace = 0x08, Enter = 0x0D)
  static void sendKey(int vkCode) {
    _user32.keybdEvent(vkCode, 0, 0, 0);
    _user32.keybdEvent(vkCode, 0, 2, 0);
  }
}
