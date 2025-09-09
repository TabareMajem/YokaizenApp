import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'assets-manager.dart';

class CharacterPositionManager {
  final AssetsManager assetsManager;

  // For portrait mode, we'll use a position that attaches character to the dialogue box
  static var positions = {
    'single': {
      'center': Vector2(0.9, 1.0), // Position character at right side (90% from left) and bottom (100% from top)
    }
  };

  // Scale for portrait mode - adjust as needed
  static const scales = {
    'single': 1.0, // Full size to ensure character is visible
  };

  // We'll only keep track of the current active character
  CharacterSprite? activeCharacter;

  CharacterPositionManager({required this.assetsManager});

  Future<void> showCharacter(
      String characterId,
      String expression,
      String position
      ) async {
    // Clear existing character
    activeCharacter = null;
    
    // Create new character sprite
    activeCharacter = await _createCharacterSprite(
      characterId,
      expression,
      'center', // Always use center position in portrait mode
    );
    
    print('Showing character: $characterId with expression: $expression');
  }

  Future<void> hideCharacter(String characterId) async {
    // Only hide if this is the active character
    if (activeCharacter != null && activeCharacter!.characterId == characterId) {
      activeCharacter = null;
      print('Hiding character: $characterId');
    }
  }

  // Return the currently active character, or null if none is active
  CharacterSprite? getActiveCharacter() {
    return activeCharacter;
  }

  Future<CharacterSprite> _createCharacterSprite(
      String characterId,
      String expression,
      String position,
      ) async {
    // Get character configuration from assets manager
    try {
      final character = assetsManager.characters['characters'][characterId];
      if (character == null) {
        throw Exception('Character not found: $characterId');
      }

      // Always use single center position for portrait mode
      final positionData = positions['single']!['center']!;
      final scale = scales['single']!;

      // Default expression if the requested one doesn't exist
      String actualExpression = expression;
      if (character['sprites']['expressions'][expression] == null) {
        actualExpression = character['defaultExpression'] ?? 'neutral';
      }

      // Preload the character image
      await assetsManager.loadCharacter(characterId, actualExpression);

      return CharacterSprite(
        position: positionData,
        scale: Vector2.all(scale),
        expression: actualExpression,
        characterId: characterId,
      );
    } catch (e) {
      print('Error creating character sprite: $e');
      // Return a default sprite
      return CharacterSprite(
        position: positions['single']!['center']!,
        scale: Vector2.all(1.0),
        expression: 'neutral',
        characterId: characterId,
      );
    }
  }

  Future<void> _updateCharacterSprite(
      CharacterSprite sprite,
      String expression,
      String position,
      ) async {
    try {
      // Get character configuration
      final character = assetsManager.characters['characters'][sprite.characterId];
      if (character == null) {
        throw Exception('Character not found: ${sprite.characterId}');
      }

      // Position is always center in portrait mode
      sprite.position = positions['single']!['center']!;

      // Update expression if specified and exists
      if (expression.isNotEmpty) {
        if (character['sprites']['expressions'][expression] != null) {
          sprite.expression = expression;
          // Preload the new expression
          await assetsManager.loadCharacter(sprite.characterId, expression);
        } else {
          // Fallback to default expression
          final defaultExpression = character['defaultExpression'] ?? 'neutral';
          sprite.expression = defaultExpression;
          await assetsManager.loadCharacter(sprite.characterId, defaultExpression);
        }
      }
    } catch (e) {
      print('Error updating character sprite: $e');
    }
  }

  // Utility method to get character sprite path
  String getCharacterSpritePath(String characterId, String expression) {
    try {
      final character = assetsManager.characters['characters'][characterId];
      if (character != null) {
        final expressionPath = character['sprites']['expressions'][expression];
        if (expressionPath != null) {
          return 'visualassets/${expressionPath}';
        } else {
          // Fallback to base character sprite
          return 'visualassets/${character['sprites']['base']}';
        }
      }
    } catch (e) {
      print('Error getting character sprite path: $e');
    }

    // Fallback
    return 'visualassets/characters/hana/base.png';
  }
}

class CharacterSprite {
  Vector2 position;
  Vector2 scale;
  String expression;
  String characterId;

  CharacterSprite({
    required this.position,
    required this.scale,
    required this.expression,
    required this.characterId,
  });
}