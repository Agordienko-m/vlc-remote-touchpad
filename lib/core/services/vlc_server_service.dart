import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'windows_mouse_service.dart';

import '../../models/player_state_model.dart';
import '../constants/app_constants.dart';
import 'vlc_service.dart';

/// Сервис WebSocket-сервера для режима Сервера (Windows)
class VlcServerService {
  static final VlcServerService _instance = VlcServerService._internal();
  factory VlcServerService() => _instance;
  VlcServerService._internal();

  HttpServer? _server;
  final Set<WebSocket> _clients = {};
  final StreamController<PlayerState> _stateController = StreamController<PlayerState>.broadcast();
  Timer? _pollTimer;

  VlcService? _vlcService;
  StreamSubscription<PlayerState>? _vlcStatusSubscription;

  Stream<PlayerState> get stateStream => _stateController.stream;

  bool get isRunning => _server != null;
  int get connectedClients => _clients.length;

  /// Запуск WebSocket-сервера на порту 8085
  Future<void> startServer() async {
    if (_server != null) return;

    _server = await HttpServer.bind(InternetAddress.anyIPv4, AppConstants.serverPort);

    _server!.listen((request) async {
      if (request.uri.path == AppConstants.wsPath) {
        final ws = await WebSocketTransformer.upgrade(request);
        _clients.add(ws);

        ws.listen(
          (data) => _handleWebSocketMessage(ws, data),
          onDone: () => _clients.remove(ws),
          onError: (_) => _clients.remove(ws),
        );
      } else {
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.text;
        request.response.write('VLC Remote Server - port ${AppConstants.serverPort}');
        await request.response.close();
      }
    });

    // Начинаем опрос VLC
    _startPolling();

    // Уведомляем о состоянии
    _stateController.add(const PlayerState());
  }

  /// Остановка сервера
  Future<void> stopServer() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    await _vlcStatusSubscription?.cancel();
    _vlcStatusSubscription = null;

    for (final client in _clients) {
      client.close();
    }
    _clients.clear();

    await _server?.close();
    _server = null;
  }

  /// Настройка VLC сервиса
  void configureVlc(String baseUrl, String password) {
    _vlcService = VlcService(baseUrl: baseUrl, password: password);
  }

  /// Обработка входящего WebSocket сообщения
  void _handleWebSocketMessage(WebSocket sender, dynamic data) {
    try {
      if (data is String) {
        final Map<String, dynamic> msg = jsonDecode(data);
        _processCommand(sender, msg);
      } else if (data is Map) {
        _processCommand(sender, data.cast<String, dynamic>());
      }
    } catch (e) {
      _sendError(sender, 'Неверный формат сообщения: $e');
    }
  }

  /// Обработка команды от клиента
  void _processCommand(WebSocket sender, Map<String, dynamic> cmd) {
    final action = cmd['action'] as String?;
    if (_vlcService == null) return;

    switch (action) {
      case 'play':
        _vlcService!.play();
        break;
      case 'pause':
        _vlcService!.pause();
        break;
      case 'stop':
        _vlcService!.stop();
        break;
      case 'next':
        _vlcService!.next();
        break;
      case 'previous':
        _vlcService!.previous();
        break;
      case 'set_volume':
        final volume = cmd['volume'];
        if (volume != null) {
          if (volume is int) {
            _vlcService!.setVolume(volume);
          } else if (volume is double) {
            _vlcService!.setVolume(volume.toInt());
          } else if (volume is String) {
            final parsed = int.tryParse(volume);
            if (parsed != null) {
              _vlcService!.setVolume(parsed);
            } else {
              _vlcService!.command({'command': 'volume', 'val': volume});
            }
          }
        }
        break;
      case 'seek':
        final seconds = cmd['seconds'] as int?;
        if (seconds != null) {
          _vlcService!.setPosition(seconds);
        }
        break;
      case 'seek_rel':
        final delta = cmd['delta'] as int?;
        if (delta != null) {
          _seekRelative(delta);
        }
        break;
      case 'fullscreen':
        _vlcService!.fullscreen();
        break;
      case 'shutdown':
      case '/shutdown':
        if (Platform.isWindows) {
          () async {
            await Process.run('taskkill', ['/IM', 'vlc.exe']);
            await Future.delayed(const Duration(seconds: 2));
            await Process.run('shutdown', ['/s', '/t', '5']);
          }();
          _sendNotification(sender, 'Компьютер выключится через 5 секунд');
        } else {
          _sendError(sender, 'Команда выключения доступна только на Windows');
        }
        break;
      case 'cancel_shutdown':
      case '/cancel_shutdown':
        if (Platform.isWindows) {
          Process.run('shutdown', ['/a']);
          _sendNotification(sender, 'Выключение отменено');
        } else {
          _sendError(sender, 'Команда отмены доступна только на Windows');
        }
        break;
      case 'ping':
        _pollVlcStatus();
        break;

      case 'mouse_move':
        if (Platform.isWindows) {
          final dx = (cmd['dx'] as num?)?.toDouble() ?? 0.0;
          final dy = (cmd['dy'] as num?)?.toDouble() ?? 0.0;
          final sens = (cmd['sens'] as num?)?.toDouble() ?? 1.2;
          WindowsMouseService.moveCursorRel(dx, dy, sensitivity: sens);
        }
        break;
      case 'mouse_left_click':
        if (Platform.isWindows) {
          WindowsMouseService.leftClick();
        }
        break;
      case 'mouse_double_click':
        if (Platform.isWindows) {
          WindowsMouseService.doubleLeftClick();
        }
        break;
      case 'mouse_right_click':
        if (Platform.isWindows) {
          WindowsMouseService.rightClick();
        }
        break;
      case 'mouse_wheel':
        if (Platform.isWindows) {
          final delta = cmd['delta'] as int? ?? 0;
          WindowsMouseService.mouseWheel(delta);
        }
        break;
      case 'mouse_keyboard_input':
        if (Platform.isWindows) {
          final text = cmd['text'] as String? ?? '';
          WindowsMouseService.sendText(text);
        }
        break;
      case 'mouse_key_press':
        if (Platform.isWindows) {
          final vk = cmd['vk'] as int? ?? 0;
          if (vk != 0) {
            WindowsMouseService.sendKey(vk);
          }
        }
        break;
    }

    // Опрашиваем состояние после команды
    _pollVlcStatus();
  }

  void _seekRelative(int deltaSeconds) async {
    await _vlcService!.setPosition(0);
  }

  /// Опрос состояния VLC
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _pollVlcStatus();
    });
  }

  Future<void> _pollVlcStatus() async {
    if (_vlcService == null) return;

    try {
      final state = await _vlcService!.getPlayerState();
      _stateController.add(state);
      _broadcastState(state);
    } catch (_) {
      // Игнорируем ошибки опроса
    }
  }

  void _broadcastState(PlayerState state) {
    final msg = jsonEncode({
      'type': 'state',
      'data': state.toJson(),
    });
    for (final client in _clients.toList()) {
      try {
        client.add(msg);
      } catch (_) {
        _clients.remove(client);
      }
    }
  }

  void _sendError(WebSocket sender, String message) {
    sender.add(jsonEncode({'type': 'error', 'message': message}));
  }

  void _sendNotification(WebSocket sender, String message) {
    sender.add(jsonEncode({'type': 'notification', 'message': message}));
  }
}