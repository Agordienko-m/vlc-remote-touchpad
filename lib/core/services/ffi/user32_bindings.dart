import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:win32/win32.dart' as win32;

// FFI реализация для user32.dll
class User32Bindings {
  static final User32Bindings _instance = User32Bindings._internal();
  factory User32Bindings() => _instance;
  User32Bindings._internal();

  late final ffi.DynamicLibrary _user32 = ffi.DynamicLibrary.open('user32.dll');

  static const int mouseeventfLeftdown = 0x0002;
  static const int mouseeventfLeftup = 0x0004;
  static const int mouseeventfRightdown = 0x0008;
  static const int mouseeventfRightup = 0x0010;
  static const int mouseeventfWheel = 0x0800;

  late final int Function(ffi.Pointer<win32.POINT> lpPoint) _getCursorPos =
      _user32.lookupFunction<ffi.Int32 Function(ffi.Pointer<win32.POINT>), int Function(ffi.Pointer<win32.POINT>)>('GetCursorPos');

  late final int Function(int X, int Y) _setCursorPos =
      _user32.lookupFunction<ffi.Int32 Function(ffi.Int32, ffi.Int32), int Function(int, int)>('SetCursorPos');

  late final void Function(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo) _mouseEvent =
      _user32.lookupFunction<ffi.Void Function(ffi.Uint32, ffi.Uint32, ffi.Uint32, ffi.Uint32, ffi.IntPtr), void Function(int, int, int, int, int)>('mouse_event');

  late final void Function(int bVk, int bScan, int dwFlags, int dwExtraInfo) _keybdEvent =
      _user32.lookupFunction<ffi.Void Function(ffi.Uint8, ffi.Uint8, ffi.Uint32, ffi.IntPtr), void Function(int, int, int, int)>('keybd_event');

  List<int> getCursorPos() {
    final pt = pkg_ffi.calloc<win32.POINT>();
    try {
      _getCursorPos(pt);
      return [pt.ref.x, pt.ref.y];
    } finally {
      pkg_ffi.calloc.free(pt);
    }
  }

  void setCursorPos(int x, int y) {
    _setCursorPos(x, y);
  }

  void mouseEvent(int flags, int dx, int dy, int data, int extraInfo) {
    _mouseEvent(flags, dx, dy, data, extraInfo);
  }

  void keybdEvent(int bVk, int bScan, int dwFlags, int dwExtraInfo) {
    _keybdEvent(bVk, bScan, dwFlags, dwExtraInfo);
  }

  void setClipboardText(String text) {
    win32.OpenClipboard(0);
    win32.EmptyClipboard();
    final hMem = win32.GlobalAlloc(win32.GMEM_MOVEABLE, (text.codeUnits.length + 1) * 2);
    final pMem = win32.GlobalLock(hMem);
    pMem.cast<ffi.Uint16>().asTypedList(text.codeUnits.length + 1).setRange(0, text.codeUnits.length, text.codeUnits);
    pMem.cast<ffi.Uint16>()[text.codeUnits.length] = 0;
    win32.GlobalUnlock(hMem);
    win32.SetClipboardData(win32.CF_UNICODETEXT, hMem.address);
    win32.CloseClipboard();
  }
}


