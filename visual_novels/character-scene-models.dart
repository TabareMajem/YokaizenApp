// character.dart
class Character {
  final String id;
  final String name;
  final String description;
  final Map<String, String> expressions;
  
  Character({
    required this.id,
    required this.name,
    required this.description,
    required this.expressions,
  });
  
  // Copy with method for immutability
  Character copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, String>? expressions,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      expressions: expressions ?? this.expressions,
    );
  }
  
  // Convert to JSON for storage and API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'expressions': expressions,
    };
  }
  
  // Create from JSON
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      expressions: Map<String, String>.from(json['expressions']),
    );
  }
}

// scene.dart
class Scene {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  
  Scene({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
  });
  
  // Copy with method for immutability
  Scene copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
  }) {
    return Scene(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
    );
  }
  
  // Convert to JSON for storage and API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
    };
  }
  
  // Create from JSON
  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imagePath: json['imagePath'],
    );
  }
}
