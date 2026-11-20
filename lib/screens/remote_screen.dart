import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/services/websocket_service.dart';
import '../core/services/settings_service.dart';
import '../models/player_state_model.dart';
import '../widgets/control_button.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> with WidgetsBindingObserver {
  String _serverIp = '';
  bool _connected = false;
  bool _manualDisconnect = false;
  bool _isReconnecting = false;
  late WebSocketService _wsService;
  late SettingsService _settingsService;
  PlayerState _playerState = const PlayerState();
  StreamSubscription<String>? _messageSub;
  StreamSubscription<bool>? _connSub;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  final TextEditingController _ipController = TextEditingController();

  bool _isDraggingVolume = false;
  double _dragVolumeValue = 0.0;
  int _currentTab = 0; // 0 = Пульт VLC, 1 = Тачпад
  DateTime? _lastMoveTime;
  double _touchSensitivity = 4.0;
  final TextEditingController _keyboardController = TextEditingController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settingsService = SettingsService();
    _wsService = WebSocketService();
    _initSettings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (!_manualDisconnect && _serverIp.isNotEmpty) {
        _wsService.disconnect();
        _wsService = WebSocketService(serverIp: _serverIp);
        _connect(silent: true);
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // app paused/inactive
    }
  }

  Future<void> _initSettings() async {
    await _settingsService.init();
    final savedIp = _settingsService.getServerIp();
    final savedSensitivity = _settingsService.getTouchpadSensitivity();
    if (savedIp != null) {
      setState(() {
        _serverIp = savedIp;
        _ipController.text = savedIp;
        _touchSensitivity = savedSensitivity;
      });
    } else {
      setState(() {
        _touchSensitivity = savedSensitivity;
      });
    }
  }

  void _toggleConnection() async {
    if (_connected) {
      _manualDisconnect = true;
      _disconnect();
    } else {
      _manualDisconnect = false;
      if (_serverIp.isNotEmpty) {
        _settingsService.saveServerIp(_serverIp);
        await _connect();
      }
    }
  }

  Future<void> _connect({bool silent = false}) async {
    if (_serverIp.isEmpty || _isReconnecting) return;
    _isReconnecting = true;
    _reconnectTimer?.cancel();
    
    // Forcibly close old connection and nullify reference before creating new one
    try {
      _wsService.disconnect();
    } catch (_) {}

    try {
      _wsService = WebSocketService(serverIp: _serverIp);
      await _wsService.connect(timeout: const Duration(seconds: 3));
      setState(() => _connected = true);
      _manualDisconnect = false;
      _isReconnecting = false;

      _startHeartbeat();

      _connSub?.cancel();
      _connSub = _wsService.connectionState?.listen((isConnected) {
        setState(() => _connected = isConnected);
        if (!isConnected && !_manualDisconnect) {
          _handleConnectionLoss();
        }
      });

      _messageSub?.cancel();
      _messageSub = _wsService.messages?.listen((message) {
        try {
          final Map<String, dynamic> data = jsonDecode(message);
          if (data['type'] == 'state' && data['data'] != null) {
            if (!_isDraggingVolume) {
              setState(() {
                _playerState = PlayerState.fromJson(data['data']);
              });
            }
          } else if (data['type'] == 'notification' || data['type'] == 'error') {
            final msg = data['message'] as String?;
            if (msg != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  action: data['type'] == 'notification' && msg.contains('выключ')
                      ? SnackBarAction(
                          label: 'Отмена',
                          textColor: Colors.yellow,
                          onPressed: () => _sendCommand('cancel_shutdown'),
                        )
                      : null,
                ),
              );
            }
          }
        } catch (_) {}
      }, onError: (_) {
        if (!_manualDisconnect) {
          _handleConnectionLoss();
        }
      }, onDone: () {
        if (!_manualDisconnect) {
          _handleConnectionLoss();
        }
      });
    } catch (_) {
      _isReconnecting = false;
      setState(() => _connected = false);
      try {
        _wsService.disconnect();
      } catch (_) {}
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось подключиться к серверу')),
        );
      }
      if (!_manualDisconnect) {
        _scheduleReconnect();
      }
    }
  }

  void _handleConnectionLoss() {
    if (_manualDisconnect) return;
    setState(() => _connected = false);
    _stopHeartbeat();
    _scheduleReconnect();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_connected && !_isReconnecting) {
        try {
          // Отправляем тестовый ping / запрос статуса
          _wsService.sendCommand(jsonEncode({'action': 'ping'}));
        } catch (_) {
          if (!_isReconnecting) {
            _handleConnectionLoss();
          }
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    if (_manualDisconnect || _serverIp.isEmpty || _isReconnecting) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_connected && !_manualDisconnect && _serverIp.isNotEmpty && !_isReconnecting) {
        _connect(silent: true);
      }
    });
  }

  void _disconnect() {
    _manualDisconnect = true;
    _isReconnecting = false;
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _messageSub?.cancel();
    _connSub?.cancel();
    _wsService.disconnect();
    setState(() => _connected = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTab == 0 ? 'VLC Пульт' : 'Тачпад мыши'),
        bottom: _connected
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: const Color(0xFF1E1E1E),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => setState(() => _currentTab = 0),
                          icon: const Icon(Icons.settings_remote),
                          label: const Text('Пульт VLC'),
                          style: TextButton.styleFrom(
                            foregroundColor: _currentTab == 0 ? Colors.green : Colors.white70,
                            backgroundColor: _currentTab == 0 ? Colors.white10 : Colors.transparent,
                            shape: const RoundedRectangleBorder(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => setState(() => _currentTab = 1),
                          icon: const Icon(Icons.touch_app),
                          label: const Text('Тачпад'),
                          style: TextButton.styleFrom(
                            foregroundColor: _currentTab == 1 ? Colors.green : Colors.white70,
                            backgroundColor: _currentTab == 1 ? Colors.white10 : Colors.transparent,
                            shape: const RoundedRectangleBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        actions: [
          if (Platform.isAndroid)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Выйти',
              onPressed: () {
                _disconnect();
                SystemNavigator.pop();
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _settingsService.saveServerIp(_serverIp);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('IP-адрес сохранен')),
              );
            },
            tooltip: 'Сохранить IP',
          ),
        ],
      ),
      body: _currentTab == 1 && _connected
          ? _buildTouchpadScreen()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConnectionSection(),
                  const SizedBox(height: 24),
                  _buildPlaybackStatus(),
                  const SizedBox(height: 24),
                  _buildProgressSection(),
                  const SizedBox(height: 24),
                  _buildVolumeSection(),
                  const SizedBox(height: 24),
                  _buildControlButtons(),
                  const SizedBox(height: 24),
                  _buildShutdownSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Подключение', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          TextField(
            controller: _ipController,
            onChanged: (value) => _serverIp = value,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'IP-адрес сервера', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _toggleConnection,
            icon: Icon(_connected ? Icons.check : Icons.wifi),
            label: Text(_connected ? 'Отключиться' : 'Подключиться'),
            style: ElevatedButton.styleFrom(backgroundColor: _connected ? Colors.red : Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Статус', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text('Файл: ${_playerState.currentFileName.isEmpty ? "Нет" : _playerState.currentFileName}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('Состояние: ${_playerState.isPlaying ? "Воспроизведение" : "Пауза"}', style: TextStyle(color: _playerState.isPlaying ? Colors.green : Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final double maxDuration = _playerState.totalDuration > 0 ? _playerState.totalDuration.toDouble() : 100.0;
    final double currentPos = _playerState.currentPosition.toDouble().clamp(0.0, maxDuration);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Позиция воспроизведения', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Slider(
            value: currentPos,
            max: maxDuration,
            onChanged: _connected ? (value) {
              _sendCommandMap({'action': 'seek', 'seconds': value.toInt()});
            } : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_playerState.currentPosition), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              Text(_formatDuration(_playerState.totalDuration), style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSection() {
    final double currentVolume = _isDraggingVolume 
        ? _dragVolumeValue 
        : _playerState.volume.clamp(0.0, 1.25);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Громкость VLC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${(currentVolume * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: currentVolume,
            max: 1.25,
            onChanged: _connected ? (value) {
              setState(() {
                _isDraggingVolume = true;
                _dragVolumeValue = value;
              });
              final volPercent = (value * 256).toInt();
              _sendCommandMap({'action': 'set_volume', 'volume': volPercent});
            } : null,
            onChangeEnd: _connected ? (value) {
              setState(() {
                _isDraggingVolume = false;
                _dragVolumeValue = value;
              });
              final volPercent = (value * 256).toInt();
              _sendCommandMap({'action': 'set_volume', 'volume': volPercent});
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ControlButton(icon: Icons.skip_previous, label: 'Пред.', color: Colors.blue, isActive: _connected, onTap: () => _sendCommand('previous')),
            ControlButton(icon: _playerState.isPlaying ? Icons.pause : Icons.play_arrow, label: _playerState.isPlaying ? 'Пауза' : 'Плей', color: Colors.green, isActive: _connected, onTap: () => _sendCommand(_playerState.isPlaying ? 'pause' : 'play')),
            ControlButton(icon: Icons.skip_next, label: 'След.', color: Colors.blue, isActive: _connected, onTap: () => _sendCommand('next')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ControlButton(icon: Icons.stop, label: 'Стоп', color: Colors.red, isActive: _connected, onTap: () => _sendCommand('stop')),
            ControlButton(icon: Icons.fullscreen, label: 'Экран', color: Colors.purple, isActive: _connected, onTap: () => _sendCommand('fullscreen')),
          ],
        ),
      ],
    );
  }

  Widget _buildShutdownSection() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _connected ? _confirmShutdown : null,
        icon: const Icon(Icons.power_settings_new, color: Colors.white),
        label: const Text('Выключить ПК', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildTouchpadScreen() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Text(
                  'Скорость: ${_touchSensitivity.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Slider(
                    value: _touchSensitivity,
                    min: 1.0,
                    max: 8.0,
                    divisions: 14,
                    activeColor: Colors.green,
                    inactiveColor: Colors.white24,
                    onChanged: (value) {
                      setState(() {
                        _touchSensitivity = value;
                      });
                      _settingsService.saveTouchpadSensitivity(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final now = DateTime.now();
                      if (_lastMoveTime != null && now.difference(_lastMoveTime!).inMilliseconds < 15) {
                        return;
                      }
                      _lastMoveTime = now;

                      double dx = details.delta.dx;
                      double dy = details.delta.dy;
                      final double speedMagnitude = (dx * dx + dy * dy);
                      double accelerationFactor = 1.0;
                      if (speedMagnitude > 400.0) {
                        accelerationFactor = 1.5;
                      } else if (speedMagnitude > 1200.0) {
                        accelerationFactor = 2.0;
                      }

                      _sendCommandMap({
                        'action': 'mouse_move',
                        'dx': dx,
                        'dy': dy,
                        'sens': _touchSensitivity * accelerationFactor,
                      });
                    },
                    onTap: () => _sendCommandMap({'action': 'mouse_left_click'}),
                    onDoubleTap: () => _sendCommandMap({'action': 'mouse_double_click'}),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withAlpha(100), width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          'Сенсорная область тачпада\n(проведите для перемещения, тап - ЛКМ, двойной тап - двойной клик)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      final now = DateTime.now();
                      if (_lastMoveTime != null && now.difference(_lastMoveTime!).inMilliseconds < 20) {
                        return;
                      }
                      _lastMoveTime = now;
                      final delta = (-details.delta.dy * 3).toInt();
                      if (delta != 0) {
                        _sendCommandMap({'action': 'mouse_wheel', 'delta': delta});
                      }
                    },
                    child: const Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text('СКРОЛЛ', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _sendCommandMap({'action': 'mouse_left_click'}),
                  child: const Text('ЛКМ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _sendCommandMap({'action': 'mouse_right_click'}),
                  child: const Text('ПКМ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showKeyboardDialog,
                child: const Icon(Icons.keyboard, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showKeyboardDialog() {
    _keyboardController.text = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Ввод текста / Клавиатура', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _keyboardController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Введите текст для отправки на ПК...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _sendCommandMap({'action': 'mouse_key_press', 'vk': 0x08});
                    },
                    icon: const Icon(Icons.backspace),
                    label: const Text('Backspace'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _sendCommandMap({'action': 'mouse_key_press', 'vk': 0x0D});
                    },
                    icon: const Icon(Icons.keyboard_return),
                    label: const Text('Enter'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                final text = _keyboardController.text;
                if (text.isNotEmpty) {
                  _sendCommandMap({'action': 'mouse_keyboard_input', 'text': text});
                }
                Navigator.of(context).pop();
              },
              child: const Text('Отправить', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _confirmShutdown() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Выключение компьютера', style: TextStyle(color: Colors.white)),
          content: const Text('Выключить компьютер через 5 секунд?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                _sendCommand('shutdown');
              },
              child: const Text('Выключить', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    return '$minutes:${remainingSecs.toString().padLeft(2, '0')}';
  }

  void _sendCommand(String action) {
    if (_connected) {
      _wsService.sendCommand(jsonEncode({'action': action}));
    }
  }

  void _sendCommandMap(Map<String, dynamic> map) {
    if (_connected) {
      _wsService.sendCommand(jsonEncode(map));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _disconnect();
    _ipController.dispose();
    super.dispose();
  }
}