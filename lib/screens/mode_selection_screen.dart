import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/services/platform_service.dart';
import '../core/services/tray_service.dart';
import 'server_screen.dart';
import 'remote_screen.dart';

/// Главный экран с выбором режима работы
class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    if (PlatformUtils.isWindows) {
      Future.delayed(const Duration(milliseconds: 200), () async {
        try {
          await windowManager.show();
          await windowManager.focus();
        } catch (_) {}

        try {
          await TrayService().init();
        } catch (_) {}
      });
    }
  }

  void _navigateToServer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ServerScreen()),
    );
  }

  void _navigateToRemote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RemoteScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAppIcon(),
                const SizedBox(height: 40),
                _buildHeader(context),
                const SizedBox(height: 48),
                _buildModeCard(
                  context,
                  icon: Icons.computer,
                  title: 'Сервер',
                  description: 'Запуск локального сервера\nдля управления VLC',
                  color: Colors.blue,
                  onTap: _navigateToServer,
                ),
                const SizedBox(height: 20),
                _buildModeCard(
                  context,
                  icon: Icons.phone_android,
                  title: 'Пульт',
                  description: 'Управление VLC\nс другого устройства',
                  color: Colors.green,
                  onTap: _navigateToRemote,
                ),
                const SizedBox(height: 40),
                _buildPlatformInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(32),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.sports_esports,
        size: 80,
        color: Colors.green[300],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'VLC Remote',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Управляйте воспроизведением VLC',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white54,
              ),
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withAlpha(100),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(32),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformInfo() {
    String platform;
    if (PlatformUtils.isWindows) {
      platform = 'Windows';
    } else if (PlatformUtils.isAndroid) {
      platform = 'Android';
    } else {
      platform = 'Desktop';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Text(
          'Платформа: $platform',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }
}