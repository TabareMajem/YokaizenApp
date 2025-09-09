enum AudioType {
  music,
  soundEffect,
}

class AudioAsset {
  final String id;
  final String title;
  final String url;
  final String type; // 'music' or 'sound_effect'
  final int duration; // in seconds
  final String source;
  final String license;
  final List<String> tags;
  
  AudioAsset({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    required this.duration,
    required this.source,
    required this.license,
    required this.tags,
  });
  
  // Convert to JSON for storage and API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'type': type,
      'duration': duration,
      'source': source,
      'license': license,
      'tags': tags,
    };
  }
  
  // Create from JSON
  factory AudioAsset.fromJson(Map<String, dynamic> json) {
    return AudioAsset(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      type: json['type'],
      duration: json['duration'],
      source: json['source'],
      license: json['license'],
      tags: List<String>.from(json['tags']),
    );
  }
  
  // Copy with method for immutability
  AudioAsset copyWith({
    String? id,
    String? title,
    String? url,
    String? type,
    int? duration,
    String? source,
    String? license,
    List<String>? tags,
  }) {
    return AudioAsset(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      source: source ?? this.source,
      license: license ?? this.license,
      tags: tags ?? this.tags,
    );
  }
}
