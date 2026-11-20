import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../models/player_state_model.dart';

/// Сервис для работы с VLC HTTP интерфейсом
class VlcService {
  final String baseUrl;
  final String password;

  VlcService({
    required this.baseUrl,
    this.password = '',
  });

  /// Выполняет HTTP GET запрос к VLC
  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.get(
      uri,
      headers: _buildHeaders(),
    );
    // ignore: avoid_print
    print('VLC GET ${uri.path}: status ${response.statusCode}');
    return response;
  }

  /// Выполняет HTTP POST запрос к VLC
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      body: body.isNotEmpty ? jsonEncode(body) : null,
      headers: _buildHeaders(),
    );
    // ignore: avoid_print
    print('VLC POST ${uri.path}: status ${response.statusCode}');
    return response;
  }

  /// Выполняет HTTP GET запрос с параметрами (для команд управления через /requests/status.xml)
  Future<http.Response> command(Map<String, String> queryParams) async {
    final uri = Uri.parse('$baseUrl/requests/status.xml').replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: _buildHeaders(),
    );
    // ignore: avoid_print
    print('VLC COMMAND ${uri.query}: status ${response.statusCode}');
    return response;
  }

  Map<String, String> _buildHeaders() {
    final headers = {
      'User-Agent': 'vlc-remote/1.0',
    };

    if (password.isNotEmpty) {
      final credentials = base64Encode(utf8.encode(':$password'));
      headers['Authorization'] = 'Basic $credentials';
    }

    return headers;
  }

  // ========== Команды воспроизведения через /requests/status.xml ==========

  Future<http.Response> play() async {
    return await command({'command': 'pl_play'});
  }

  Future<http.Response> pause() async {
    return await command({'command': 'pl_pause'});
  }

  Future<http.Response> stop() async {
    return await command({'command': 'pl_stop'});
  }

  Future<http.Response> next() async {
    return await command({'command': 'pl_next'});
  }

  Future<http.Response> previous() async {
    return await command({'command': 'pl_previous'});
  }

  Future<http.Response> setVolume(int volume) async {
    return await command({'command': 'volume', 'val': volume.toString()});
  }

  Future<http.Response> setPosition(int seconds) async {
    return await command({'command': 'seek', 'val': '$seconds'});
  }

  Future<http.Response> fullscreen() async {
    return await command({'command': 'fullscreen'});
  }

  // ========== Получение состояния и плейлиста ==========

  Future<http.Response> getStatusResponse() async {
    return await get('/requests/status.xml');
  }

  Future<http.Response> getPlaylistResponse() async {
    return await get('/requests/playlist.xml');
  }

  /// Получает и парсит состояние проигрывателя из /requests/status.xml
  Future<PlayerState> getPlayerState() async {
    final response = await getStatusResponse();
    if (response.statusCode == 200) {
      return parseStatusXml(response.body);
    }
    throw Exception('Failed to get status: ${response.statusCode}');
  }

  /// Парсинг XML ответа /requests/status.xml
  PlayerState parseStatusXml(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      final root = document.rootElement;

      final stateStr = root.findElements('state').firstOrNull?.text.toLowerCase() ?? 'stopped';
      final isPlaying = stateStr == 'playing';

      final timeStr = root.findElements('time').firstOrNull?.text ?? '0';
      final currentPosition = int.tryParse(timeStr) ?? 0;

      final lengthStr = root.findElements('length').firstOrNull?.text ?? '0';
      final totalDuration = int.tryParse(lengthStr) ?? 0;

      final volumeStr = root.findElements('volume').firstOrNull?.text ?? '256';
      final rawVolume = int.tryParse(volumeStr) ?? 256;
      final normalizedVolume = (rawVolume / 320.0).clamp(0.0, 1.25);

      final fullscreenStr = root.findElements('fullscreen').firstOrNull?.text ?? '0';
      final isFullscreen = fullscreenStr == '1' || fullscreenStr.toLowerCase() == 'true';

      String currentFileName = '';
      final information = root.findElements('information').firstOrNull;
      if (information != null) {
        for (final category in information.findElements('category')) {
          for (final info in category.findElements('info')) {
            if (info.getAttribute('name') == 'filename') {
              currentFileName = info.text;
              break;
            }
          }
          if (currentFileName.isNotEmpty) break;
        }
      }

      if (currentFileName.isEmpty) {
        for (final category in information?.findElements('category') ?? <XmlElement>[]) {
          if (category.getAttribute('name') == 'meta') {
            for (final info in category.findElements('info')) {
              if (info.getAttribute('name') == 'title') {
                currentFileName = info.text;
                break;
              }
            }
          }
        }
      }

      return PlayerState(
        isPlaying: isPlaying,
        currentPosition: currentPosition,
        totalDuration: totalDuration,
        currentFileName: currentFileName,
        volume: normalizedVolume,
        isFullscreen: isFullscreen,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing VLC status XML: $e');
      return const PlayerState();
    }
  }
}

