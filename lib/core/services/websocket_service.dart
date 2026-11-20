import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Сервис для работы с WebSocket-сервером
class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<String>? _messageController;
  StreamController<bool>? _connectionController;

  final String? _serverIp;
  final int _port;

  WebSocketService({
    this._serverIp,
    this._port = 8085,
  });

  /// Поток сообщений от сервера
  Stream<String>? get messages => _messageController?.stream;

  /// Поток состояния соединения
  Stream<bool>? get connectionState => _connectionController?.stream;

  /// Подключиться к WebSocket-серверу с таймаутом
  Future<void> connect({Duration timeout = const Duration(seconds: 3)}) async {
    if (_serverIp == null || _serverIp.isEmpty) {
      throw Exception('Server IP is not set');
    }

    _messageController = StreamController<String>.broadcast();
    _connectionController = StreamController<bool>.broadcast();

    try {
      final uri = Uri.parse('ws://$_serverIp:$_port/ws');
      final channel = WebSocketChannel.connect(uri);

      // Ожидание готовности сокета / подключения с таймаутом
      await channel.ready.timeout(timeout);
      _channel = channel;

      _connectionController?.add(true);

      _channel!.stream.listen(
        (message) {
          _messageController?.add(message.toString());
        },
        onError: (error) {
          _connectionController?.add(false);
        },
        onDone: () {
          _connectionController?.add(false);
        },
      );
    } catch (e) {
      disconnect();
      _connectionController?.add(false);
      rethrow;
    }
  }

  /// Отправить сообщение на сервер
  void send(String message) {
    _channel?.sink.add(message);
  }

  /// Отправить команду
  void sendCommand(String command) {
    send(command);
  }

  /// Закрыть соединение принудительно
  void disconnect() {
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _messageController?.close();
    _connectionController?.close();
    _messageController = null;
    _connectionController = null;
  }

  /// Получить локальный IP-адрес Wi-Fi
  static Future<String?> getLocalWiFiIP() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    return wifiIP;
  }
}
