import 'dart:io';
import 'package:tray_manager/legacy.dart';
import 'package:window_manager/window_manager.dart';
import 'vlc_server_service.dart';

class TrayService with TrayListener, WindowListener {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  Future<void> init() async {
    if (!Platform.isWindows) return;

    // Установка иконки и тултипа для системного трея
    await trayManager.setIcon('windows/runner/resources/app_icon.ico');
    await trayManager.setToolTip('VLC Remote');

    // Создание контекстного меню трея
    final Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Открыть окно',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Выход',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);

    trayManager.addListener(this);
    windowManager.addListener(this);

    // Предотвращаем закрытие окна по крестику, сворачиваем в трей
    await windowManager.setPreventClose(true);
  }

  @override
  void onTrayIconMouseDown() async {
    // Левый клик по иконке в трее: разворачиваем и выводим на передний план
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show_window':
        await windowManager.show();
        await windowManager.focus();
        break;
      case 'exit_app':
        await windowManager.setPreventClose(false);
        await VlcServerService().stopServer();
        await windowManager.destroy();
        exit(0);
    }
  }

  @override
  void onWindowMinimize() async {
    await windowManager.hide();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
      exit(0);
    }
  }
}
