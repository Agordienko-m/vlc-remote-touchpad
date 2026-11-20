import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/services/vlc_server_service.dart';
import '../core/services/network_service.dart';
import '../core/services/settings_service.dart';
import '../core/services/windows_volume_service.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  bool _isRunning = false;
  String _localIp = 'Получение...';
  String _vlcPassword = '';
  final TextEditingController _passwordController = TextEditingController();
  final VlcServerService _serverService = VlcServerService();
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _settingsService.init();
    _vlcPassword = _settingsService.getVlcPassword();
    _passwordController.text = _vlcPassword;

    final ip = await NetworkService.getWifiIp();
    setState(() => _localIp = ip ?? 'Не найден');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VLC Сервер'),
        actions: [
          if (Platform.isAndroid)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Выйти',
              onPressed: () {
                _serverService.stopServer();
                SystemNavigator.pop();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServerStatusCard(),
            const SizedBox(height: 24),
            _buildSettingsCard(),
            const SizedBox(height: 24),
            _buildVolumeControlCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildServerStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isRunning ? Colors.green : Colors.grey, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Статус сервера', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Icon(_isRunning ? Icons.check_circle : Icons.cancel, color: _isRunning ? Colors.green : Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          Text('Локальный IP: $_localIp', style: const TextStyle(fontSize: 16, color: Colors.greenAccent)),
          const SizedBox(height: 8),
          const Text('Порт: 8085', style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _toggleServer,
            icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
            label: Text(_isRunning ? 'Остановить' : 'Запустить'),
            style: ElevatedButton.styleFrom(backgroundColor: _isRunning ? Colors.red : Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Пароль VLC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            onChanged: (value) {
              _vlcPassword = value;
              _settingsService.saveVlcPassword(value);
            },
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Пароль VLC HTTP', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControlCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Громкость Windows', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(onPressed: () => WindowsVolumeService.volumeDown(5), icon: const Icon(Icons.volume_down), label: const Text('Тише')),
              ElevatedButton.icon(onPressed: () => WindowsVolumeService.mute(), icon: const Icon(Icons.volume_off), label: const Text('Mute')),
              ElevatedButton.icon(onPressed: () => WindowsVolumeService.volumeUp(5), icon: const Icon(Icons.volume_up), label: const Text('Громче')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleServer() async {
    if (_isRunning) {
      await _serverService.stopServer();
      setState(() => _isRunning = false);
    } else {
      _serverService.configureVlc('http://127.0.0.1:8080', _vlcPassword);
      await _serverService.startServer();
      setState(() => _isRunning = true);
    }
  }

  @override
  void dispose() {
    _serverService.stopServer();
    _passwordController.dispose();
    super.dispose();
  }
}