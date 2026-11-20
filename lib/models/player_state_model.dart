/// Модель состояния проигрывателя
class PlayerState {
  final bool isPlaying;
  final int currentPosition; // в секундах
  final int totalDuration; // в секундах
  final String currentFileName;
  final double volume; // 0.0 - 1.0
  final bool isFullscreen;

  const PlayerState({
    this.isPlaying = false,
    this.currentPosition = 0,
    this.totalDuration = 0,
    this.currentFileName = '',
    this.volume = 0.5,
    this.isFullscreen = false,
  });

  PlayerState copyWith({
    bool? isPlaying,
    int? currentPosition,
    int? totalDuration,
    String? currentFileName,
    double? volume,
    bool? isFullscreen,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      currentFileName: currentFileName ?? this.currentFileName,
      volume: volume ?? this.volume,
      isFullscreen: isFullscreen ?? this.isFullscreen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPlaying': isPlaying,
      'currentPosition': currentPosition,
      'totalDuration': totalDuration,
      'currentFileName': currentFileName,
      'volume': volume,
      'isFullscreen': isFullscreen,
    };
  }

  static PlayerState fromJson(Map<String, dynamic> json) {
    return PlayerState(
      isPlaying: json['isPlaying'] as bool? ?? false,
      currentPosition: json['currentPosition'] as int? ?? 0,
      totalDuration: json['totalDuration'] as int? ?? 0,
      currentFileName: json['currentFileName'] as String? ?? '',
      volume: (json['volume'] as num?)?.toDouble() ?? 0.5,
      isFullscreen: json['isFullscreen'] as bool? ?? false,
    );
  }
}