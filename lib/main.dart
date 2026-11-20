import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/services/platform_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/vlc_server_service.dart';
import 'core/services/tray_service.dart';
import 'screens/server_screen.dart';
import 'screens/remote_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация window_manager только для Windows
  if (PlatformUtils.isWindows) {
    // Проверка на запуск второго экземпляра программы
    try {
      final lockFile = File('${Directory.systemTemp.path}\\vlc_remote_single_instance.lock');
      if (!await lockFile.exists()) {
        await lockFile.create(recursive: true);
      }
      final raf = await lockFile.open(mode: FileMode.write);
      try {
        raf.lockSync(FileLock.exclusive);
        raf.writeStringSync(pid.toString());
      } catch (_) {
        // Другой экземпляр уже запущен, выходим
        await raf.close();
        exit(0);
      }
    } catch (_) {}

    try {
      await windowManager.ensureInitialized();
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      
      Future.delayed(const Duration(milliseconds: 200), () async {
        try {
          await windowManager.show();
          await windowManager.focus();
        } catch (_) {}

        try {
          await TrayService().init();
        } catch (_) {}
      });
    } catch (_) {}

    // Автоматический запуск локального сервера в фоне на Windows
    try {
      final settingsService = SettingsService();
      await settingsService.init();
      final password = settingsService.getVlcPassword();
      VlcServerService().configureVlc('http://127.0.0.1:8080', password);
      await VlcServerService().startServer();
    } catch (_) {}
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget homeScreen;
    if (PlatformUtils.isWindows) {
      homeScreen = const ServerScreen();
    } else if (PlatformUtils.isAndroid) {
      homeScreen = const RemoteScreen();
    } else {
      homeScreen = const RemoteScreen();
    }

    return MaterialApp(
      title: 'VLC Remote',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 2,
          shape: StadiumBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: const StadiumBorder(),
            backgroundColor: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.dark,
            ).primary,
            foregroundColor: Colors.white,
            iconSize: 32,
          ),
        ),
        sliderTheme: SliderThemeData(
          trackHeight: 6,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 12,
            disabledThumbRadius: 12,
          ),
          overlayShape: const RoundSliderOverlayShape(),
          activeTrackColor: Colors.green,
          inactiveTrackColor: Colors.white24,
          thumbColor: Colors.green,
          overlayColor: Colors.green.withAlpha(32),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.green,
        ),
      ),
      home: homeScreen,
    );
  }
}
