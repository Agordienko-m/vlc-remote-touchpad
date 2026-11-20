import 'dart:io';

/// Сервис для работы с сетью
class NetworkService {
  /// Получить локальный IP-адрес любого активного интерфейса (универсальный перебор)
  static Future<String?> getAnyIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      final List<String> validIps = [];

      for (var interface in interfaces) {
        final nameLower = interface.name.toLowerCase();
        // Исключаем виртуальные адаптеры
        if (nameLower.contains('vethernet') ||
            nameLower.contains('virtualbox') ||
            nameLower.contains('vmware') ||
            nameLower.contains('wsl')) {
          continue;
        }

        for (var addr in interface.addresses) {
          if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
            final ip = addr.address;
            // Исключаем автонастраиваемые адреса 169.254.x.x
            if (!ip.startsWith('169.254.')) {
              validIps.add(ip);
            }
          }
        }
      }

      if (validIps.isNotEmpty) {
        return validIps.join(', ');
      }
    } catch (_) {}
    return null;
  }

  /// Получить локальный IP-адрес Wi-Fi (совместимость)
  static Future<String?> getWifiIp() async {
    return await getAnyIp();
  }
}
