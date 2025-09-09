import 'package:flame/game.dart';
import 'package:jenny/jenny.dart' hide DialogueLine;
import 'package:flutter/material.dart';
import '../managers/assets-manager.dart';
import '../managers/audio-manager.dart';
import '../managers/character-position-manager.dart';
import '../state/game-state.dart';
import '../ui/visual-novel-ui.dart';
import 'dialogue_parser.dart';

class HarmonySeekersGame extends FlameGame {
  late DialogueParser dialogueParser;
  late GameState gameState;
  late AssetsManager assetsManager;
  late AudioManager audioManager;
  late CharacterPositionManager characterManager;
  late VisualNovelUI visualNovelUI;

  // Current dialogue state
  String currentNodeName = 'Start';
  int currentLineIndex = 0;
  List<DialogueLine> currentNodeContent = [];
  String currentDialogueText = '';
  String currentCharacterName = '';
  List<String>? currentChoices;

  // UI update callback
  Function(String, String, List<String>?)? onUpdateUI;

  @override
  Future<void> onLoad() async {
    // Initialize systems
    gameState = await GameState.initialize();
    assetsManager = await AssetsManager.initialize();
    audioManager = await AudioManager.initialize();
    characterManager = CharacterPositionManager(assetsManager: assetsManager);
    dialogueParser = DialogueParser();

    // Load dialogue content
    await _loadDialogueContent();

    // Start game from the beginning
    startGame();
  }

  Future<void> _loadDialogueContent() async {
    // Load all dialogue files
    final dialogueFiles = await assetsManager.loadDialogueFiles();

    print("Loaded dialogue files count: ${dialogueFiles.length}");
    dialogueFiles.forEach((key, content) {
      print("Dialogue file key: $key, Content preview: ${content.substring(0,10)}");
      dialogueParser.parseContent(content);
    });

    print('Loaded ${dialogueParser.nodes.length} dialogue nodes');
    dialogueParser.nodes.forEach((key, node) {
      print("Available node: $key with ${node.content.length} lines");
    });
  }


  void startGame() {
    // Set initial dialogue text
    currentDialogueText = "Click on the next button to start the story";
    _updateUI();
    
    // Start from the first node in the current chapter
    final chapterInfo = assetsManager.getChapterInfo(gameState.currentChapter);
    if (chapterInfo != null && chapterInfo['startNode'] != null) {
      currentNodeName = chapterInfo['startNode'];
    } else {
      // Default fallback
      currentNodeName = 'Start';
    }

    // Start from this node
    _processNode(currentNodeName);
  }

  void _processNode(String nodeName) {
    final node = dialogueParser.getNode(nodeName);
    if (node == null) {
      print('Error: Node $nodeName not found');
      return;
    }

    // Update current node state
    currentNodeName = nodeName;
    currentNodeContent = node.content;
    currentLineIndex = 0;
    gameState.updateNode(nodeName);

    // Process the first line
    if (currentNodeContent.isNotEmpty) {
      _processCurrentLine();
    }
  }

  void _processCurrentLine() {
    if (currentLineIndex >= currentNodeContent.length) {
      // End of node reached
      print('End of node $currentNodeName reached');
      return;
    }

    final line = currentNodeContent[currentLineIndex];

    switch (line.type) {
      case DialogueLineType.dialogue:
        _processDialogueLine(line.content);
        break;

      case DialogueLineType.command:
        _processCommandLine(line.content);
        // Auto-advance after commands
        advanceDialogue();
        break;

      case DialogueLineType.choice:
        _processChoiceLine(line.content);
        break;

      case DialogueLineType.jump:
        _processJumpLine(line.content);
        break;

      case DialogueLineType.tag:
      // Process tags if needed
      // Auto-advance after tags
        advanceDialogue();
        break;
    }
  }

  void _processDialogueLine(String content) {
    // Extract character name and dialogue text
    final RegExp characterPattern = RegExp(r'([^:]+):\s*(.*)');
    final match = characterPattern.firstMatch(content);

    if (match != null) {
      currentCharacterName = match.group(1)?.trim() ?? '';
      currentDialogueText = match.group(2)?.trim() ?? '';

      // Check for emotion tags
      final RegExp emotionPattern = RegExp(r'#emotion:\s*(\w+)');
      final emotionMatch = emotionPattern.firstMatch(currentDialogueText);

      String? emotion;

      if (emotionMatch != null) {
        emotion = emotionMatch.group(1);
        // Remove the emotion tag from the dialogue text
        currentDialogueText = currentDialogueText.replaceAll(emotionPattern, '').trim();
      }

      // Show the current speaking character and hide all others
      final characterId = currentCharacterName.toLowerCase();
      
      // Hide all other characters that aren't the current speaker
      List<String> allCharacterIds = gameState.characters.keys.toList();
      for (var id in allCharacterIds) {
        if (id != characterId && gameState.characters[id]?.isVisible == true) {
          characterManager.hideCharacter(id);
          gameState.characters[id]?.setVisibility(false);
        }
      }
      
      // Show current speaker with appropriate expression
      final expression = emotion ?? 'neutral';
      const position = 'center'; // Always center in portrait mode
      
      // Update game state first
      if (!gameState.characters.containsKey(characterId)) {
        gameState.characters[characterId] = CharacterState(
          expression: expression,
          position: position,
          isVisible: true,
          scale: 1.0,
          relationships: {},
        );
      } else {
        gameState.characters[characterId]?.updateExpression(expression);
        gameState.characters[characterId]?.updatePosition(position);
        gameState.characters[characterId]?.setVisibility(true);
      }
      
      // Then update the character manager to show the character
      characterManager.showCharacter(characterId, expression, position);
      
    } else if (content.contains('#narration')) {
      // Handle narration (no character name)
      currentCharacterName = '';
      currentDialogueText = content.replaceAll('#narration', '').trim();
    } else {
      // Default case
      currentCharacterName = '';
      currentDialogueText = content;
    }

    // Update UI
    _updateUI();
  }

  void _processCommandLine(String content) {
    final command = dialogueParser.parseCommand(content);

    // Process different commands
    switch (command.name) {
      case 'change_background':
        if (command.arguments.isNotEmpty) {
          _changeBackground(command.arguments[0]);
        }
        break;

      case 'show_character':
        if (command.arguments.isNotEmpty) {
          final characterId = command.arguments[0];
          final expression = command.arguments.length > 1 ? command.arguments[1] : 'neutral';
          final position = command.arguments.length > 2 ? command.arguments[2] : 'center';
          _showCharacter(characterId, expression, position);
        }
        break;

      case 'hide_character':
        if (command.arguments.isNotEmpty) {
          _hideCharacter(command.arguments[0]);
        }
        break;

      case 'play_sound':
        if (command.arguments.isNotEmpty) {
          _playSound(command.arguments[0]);
        }
        break;

      case 'show_effect':
        if (command.arguments.isNotEmpty) {
          // Implement effect display
          // This would trigger an effect in the UI
          if (visualNovelUI != null) {
            visualNovelUI.triggerEffect(command.arguments[0]);
          }
        }
        break;

      case 'declare':
      case 'set':
      // Process variable declarations/assignments
        dialogueParser.processVariables(content);
        break;

      case 'wait':
        if (command.arguments.isNotEmpty) {
          // Implement wait logic if needed
          // For now we'll just continue
        }
        break;
    }
  }

  void _processChoiceLine(String content) {
    final choices = dialogueParser.parseChoices(content);
    currentChoices = choices.map((choice) => choice.text).toList();
    _updateUI();
  }

  void _processJumpLine(String content) {
    // Extract node name after ->
    final parts = content.split('->');
    if (parts.length > 1) {
      final destination = parts[1].trim();
      _processNode(destination);
    } else {
      // Invalid jump, just advance
      advanceDialogue();
    }
  }

  void _changeBackground(String backgroundId) {
    // Update game state
    gameState.currentBackground = backgroundId;

    // Get scene info
    final sceneInfo = assetsManager.backgrounds['scenes'][backgroundId];
    if (sceneInfo != null) {
      // Play associated music if available
      if (sceneInfo['music'] != null) {
        final musicId = sceneInfo['music'];
        audioManager.playBackgroundMusic(musicId);
        gameState.updateMusic(musicId);
      }

      // Play associated ambient sound if available
      if (sceneInfo['ambient'] != null) {
        final ambientId = sceneInfo['ambient'];
        audioManager.playAmbientSound(ambientId);
        gameState.updateAmbient(ambientId);
      }
    }
  }

  void _showCharacter(String characterId, String expression, String position) {
    characterManager.showCharacter(characterId, expression, position);

    // Update game state
    if (!gameState.characters.containsKey(characterId)) {
      final character = CharacterState(
        expression: expression,
        position: position,
        isVisible: true,
        scale: 1.0,
        relationships: {},
      );
      gameState.updateCharacter(characterId, character);
    } else {
      gameState.characters[characterId]!.updateExpression(expression);
      gameState.characters[characterId]!.updatePosition(position);
      gameState.characters[characterId]!.setVisibility(true);
    }
  }

  void _hideCharacter(String characterId) {
    characterManager.hideCharacter(characterId);

    // Update game state
    if (gameState.characters.containsKey(characterId)) {
      gameState.characters[characterId]!.setVisibility(false);
    }
  }

  void _playSound(String soundId) {
    audioManager.playSoundEffect(soundId);
  }

  void _updateUI() {
    // Get the full character name from the ID if possible
    String displayName = currentCharacterName;
    if (currentCharacterName.isNotEmpty) {
      try {
        final characterId = currentCharacterName.toLowerCase();
        final fullName = assetsManager.getCharacterName(characterId);
        if (fullName.isNotEmpty) {
          displayName = fullName;
        }
      } catch (e) {
        // Keep the original name if there's an error
      }
    }

    if (onUpdateUI != null) {
      onUpdateUI!(displayName, currentDialogueText, currentChoices);
    }
  }

  // Public method to advance to the next dialogue line
  void advanceDialogue() {
    // Add visual debug print for tracking
    print('AdvanceDialogue called. Current text: "$currentDialogueText"');
    
    // Check if we've reached the end of the node's content
    if (currentLineIndex >= currentNodeContent.length - 1) {
      // End of node reached
      print('End of node $currentNodeName reached - showing end message');
      
      // Notify player about the end of the chapter
      currentCharacterName = '';
      currentDialogueText = "End of chapter reached. Thank you for reading!";
      _updateUI();
      
      // Set a flag that we've reached the end of a node
      gameState.setFlag('node_ended_${currentNodeName}');
      
      // Note: The actual exit dialogue will be shown by the DialogueBox 
      // when the next button is clicked on this message
      return;
    }
    
    // Normal dialogue advancement
    currentLineIndex++;
    currentChoices = null;
    _processCurrentLine();
  }

  // Process a choice selection
  void selectChoice(int choiceIndex) {
    if (currentChoices == null || choiceIndex >= currentChoices!.length) {
      return;
    }

    // In the full implementation, this would jump to the corresponding node
    // For now, just advance the dialogue
    advanceDialogue();
  }

  // Called when the menu button is pressed
  void openMenu() {
    // This would be implemented to open the menu overlay
    print('Menu opened');
  }

  // Connect the UI to the game
  void connectUI(VisualNovelUI ui) {
    visualNovelUI = ui;
  }

  void saveGame(String slotId) {
    gameState.saveGame(slotId);
  }

  void loadGame(String slotId) async {
    try {
      gameState = await GameState.loadGame(slotId);
      // Resume from current state
      _processNode(gameState.currentNode);
    } catch (e) {
      print('Error loading game: $e');
    }
  }

  // Clean up resources when the game is exited
  Future<void> cleanup() async {
    // Stop all audio
    await audioManager.stopAllAudio();
    
    // Save current state if needed
    gameState.saveGame('auto_save');
    
    print('Game resources cleaned up');
  }
}