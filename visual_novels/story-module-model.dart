import 'character.dart';
import 'scene.dart';
import 'dialogue_node.dart';

class StoryModule {
  final String id;
  final String title;
  final String description;
  final String author;
  final String version;
  final String category;
  final String difficulty;
  final int estimatedDuration; // in minutes
  final List<Character> characters;
  final List<Scene> scenes;
  final List<DialogueNode> nodes;
  final List<Stat> stats;
  
  StoryModule({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.version,
    required this.category,
    required this.difficulty,
    required this.estimatedDuration,
    required this.characters,
    required this.scenes,
    required this.nodes,
    required this.stats,
  });
  
  // Generate a Jenny-compatible Yarn file
  String toYarnScript() {
    final buffer = StringBuffer();
    
    // Add title header
    buffer.writeln('title: $title');
    buffer.writeln('---');
    
    // Add each dialogue node
    for (final node in nodes) {
      buffer.writeln('node: ${node.id}');
      
      // Add scene change command if present
      if (node.sceneId.isNotEmpty) {
        buffer.writeln('<<set_background ${_getSceneImagePath(node.sceneId)}>>\n');
      }
      
      // Add character display command if present
      if (node.characterId.isNotEmpty && node.expression.isNotEmpty) {
        buffer.writeln('<<show_character ${_getCharacterExpressionPath(node.characterId, node.expression)}>>\n');
      }
      
      // Add dialogue lines
      for (final line in node.lines) {
        if (line.speakerId.isNotEmpty) {
          final speakerName = _getCharacterName(line.speakerId);
          buffer.writeln('[$speakerName] ${line.text}');
        } else {
          buffer.writeln(line.text);
        }
      }
      
      // Add stat change commands
      for (final statChange in node.statChanges) {
        buffer.writeln('<<add_points ${statChange.statId} ${statChange.value}>>');
      }
      
      // Add choices if present
      if (node.choices.isNotEmpty) {
        for (final choice in node.choices) {
          buffer.writeln('-> ${choice.text}');
          buffer.writeln('    <<jump ${choice.targetNodeId}>>');
        }
      }
      
      // Node separator
      buffer.writeln('---');
    }
    
    // Close file
    buffer.writeln('===');
    
    return buffer.toString();
  }
  
  // Generate a Flutter/Flame configuration
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'version': version,
      'category': category,
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'characters': characters.map((c) => c.toJson()).toList(),
      'scenes': scenes.map((s) => s.toJson()).toList(),
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'stats': stats.map((s) => s.toJson()).toList(),
    };
  }
  
  // Helper methods for generating Yarn script
  String _getSceneImagePath(String sceneId) {
    final scene = scenes.firstWhere(
      (s) => s.id == sceneId,
      orElse: () => Scene(id: '', name: '', description: '', imagePath: 'default.png'),
    );
    return scene.imagePath;
  }
  
  String _getCharacterExpressionPath(String characterId, String expression) {
    final character = characters.firstWhere(
      (c) => c.id == characterId,
      orElse: () => Character(id: '', name: '', description: '', expressions: {}),
    );
    return character.expressions[expression] ?? 'default.png';
  }
  
  String _getCharacterName(String characterId) {
    final character = characters.firstWhere(
      (c) => c.id == characterId,
      orElse: () => Character(id: '', name: 'Unknown', description: '', expressions: {}),
    );
    return character.name;
  }
  
  // Copy with method for immutability
  StoryModule copyWith({
    String? id,
    String? title,
    String? description,
    String? author,
    String? version,
    String? category,
    String? difficulty,
    int? estimatedDuration,
    List<Character>? characters,
    List<Scene>? scenes,
    List<DialogueNode>? nodes,
    List<Stat>? stats,
  }) {
    return StoryModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      version: version ?? this.version,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      characters: characters ?? this.characters,
      scenes: scenes ?? this.scenes,
      nodes: nodes ?? this.nodes,
      stats: stats ?? this.stats,
    );
  }
}

class Stat {
  final String id;
  final String name;
  final String icon;
  
  Stat({
    required this.id,
    required this.name,
    required this.icon,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}
