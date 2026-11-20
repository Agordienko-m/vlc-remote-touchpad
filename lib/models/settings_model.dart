/// Модель настроек
class Settings {
  final String? serverIp;
  final String vlcPassword;
  final bool autoDetectMode;

  const Settings({
    this.serverIp,
    this.vlcPassword = '',
    this.autoDetectMode = true,
  });

  Settings copyWith({
    String? serverIp,
    String? vlcPassword,
    bool? autoDetectMode,
  }) {
    return Settings(
      serverIp: serverIp ?? this.serverIp,
      vlcPassword: vlcPassword ?? this.vlcPassword,
      autoDetectMode: autoDetectMode ?? this.autoDetectMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverIp': serverIp,
      'vlcPassword': vlcPassword,
      'autoDetectMode': autoDetectMode,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      serverIp: json['serverIp'] as String?,
      vlcPassword: json['vlcPassword'] as String? ?? '',
      autoDetectMode: json['autoDetectMode'] as bool? ?? true,
    );
  }
}