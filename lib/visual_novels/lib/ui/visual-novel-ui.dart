import 'package:flutter/material.dart';
import 'dart:async';

import 'dialogue-box.dart';
import 'menu-overlay.dart';
import '../managers/assets-manager.dart';
import '../managers/audio-manager.dart';
import '../managers/character-position-manager.dart';
import '../state/game-state.dart';
import '../game/harmony-seekers-game.dart';

class VisualNovelUI extends StatefulWidget {
  final HarmonySeekersGame game;
  final GlobalKey<_VisualNovelUIState> _stateKey = GlobalKey<_VisualNovelUIState>();

  VisualNovelUI({
    super.key,
    required this.game,
  });

  @override
  State<VisualNovelUI> createState() => _VisualNovelUIState();

  void triggerEffect(String effectId) {
    _stateKey.currentState?.triggerEffect(effectId);
  }
  
  void showExitDialogue() {
    _stateKey.currentState?._showExitConfirmation();
  }
}

class _VisualNovelUIState extends State<VisualNovelUI> with TickerProviderStateMixin {
  bool _isMenuOpen = false;
  bool _isEffectActive = false;
  String? _activeEffect;
  late AnimationController _effectAnimationController;

  // Current state variables
  String _currentDialogue = '';
  String _currentCharacter = '';
  List<String>? _choices;

  @override
  void initState() {
    super.initState();

    // Setup animation controller for effects
    _effectAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _effectAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isEffectActive = false;
          _activeEffect = null;
        });
      }
    });

    // Register UI update callback
    widget.game.onUpdateUI = (character, dialogue, choices) {
      setState(() {
        _currentCharacter = character;
        _currentDialogue = dialogue;
        _choices = choices;
      });
    };

    // Connect UI to game
    widget.game.connectUI(widget);

    // Load initial data
    _initializeUI();
  }


  void _initializeUI() {
    // Initial state setup - will be replaced by game's callback later
    setState(() {
      _currentDialogue = "Click on the next button to start";
      _currentCharacter = "";
    });
  }

  @override
  void dispose() {
    // Stop all audio when the UI is disposed
    widget.game.audioManager.stopAllAudio();
    
    _effectAnimationController.dispose();
    super.dispose();
  }

  void triggerEffect(String effectId) {
    setState(() {
      _isEffectActive = true;
      _activeEffect = effectId;
      _effectAnimationController.reset();
      _effectAnimationController.forward();
    });

    // Play effect sound if available
    try {
      final effect = widget.game.assetsManager.getEffectConfig(effectId);
      if (effect != null && effect['sound'] != null) {
        widget.game.audioManager.playSoundEffect(effectId);
      }
    } catch (e) {
      print('Error playing effect sound: $e');
    }
  }

  void _handleNext() {
    widget.game.advanceDialogue();
  }

  void _handleChoice(String choice) {
    if (_choices != null) {
      final index = _choices!.indexOf(choice);
      if (index >= 0) {
        widget.game.selectChoice(index);
      }
    }
  }

  void _handleMenuOpen() {
    widget.game.openMenu();
  }
  
  // Show exit confirmation when chapter ends or back button is pressed
  void _showExitConfirmation([BuildContext? ctx]) {
    final context = ctx ?? this.context;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Chapter Complete', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You have reached the end of this chapter. Would you like to return to the main game?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () async {
              // Clean up game resources
              await widget.game.cleanup();
              
              // Return directly to previous screen without a second confirmation
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit back to main game
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current background from game state
    final currentBackground = widget.game.gameState.currentBackground;
    final backgroundPath = _getBackgroundPath(currentBackground);
    
    // Calculate heights for better positioning
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogueBoxHeight = screenHeight * 0.25; // Approximately 25% of screen height

    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        _showExitConfirmation();
        return false; // Prevent default back behavior
      },
      child: Stack(
        children: [
          // Background Layer
          Positioned.fill(
            child: Image.asset(
              backgroundPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading background: $error');
                return Container(color: Colors.black);
              },
            ),
          ),
  
          // Effects Layer (when active)
          if (_isEffectActive && _activeEffect != null)
            Positioned.fill(
              child: FadeTransition(
                opacity: _effectAnimationController,
                child: _buildEffectWidget(_activeEffect!),
              ),
            ),
  
          // UI Layer with Dialogue at bottom
          Positioned.fill(
            child: Column(
              children: [
                // Top Bar with Menu Button
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          _isMenuOpen = true;
                        });
                        _handleMenuOpen();
                      },
                    ),
                  ),
                ),
  
                const Spacer(),
                
                // Combined character and dialogue box area
                SizedBox(
                  height: screenHeight * 0.6, // 60% of screen height for character + dialogue
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Dialogue Box
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: DialogueBox(
                          characterName: _currentCharacter,
                          text: _currentDialogue,
                          onNext: _handleNext,
                          choices: _choices,
                          onChoice: _handleChoice,
                          assetsManager: widget.game.assetsManager,
                        ),
                      ),
                      
                      // Active character positioned directly on top of dialogue box
                      Positioned(
                        bottom: dialogueBoxHeight - 1, // Slight overlap to avoid any gap
                        right: 20, // Right padding to match dialogue box styling
                        width: screenHeight * 0.3, // Control width to avoid crowding
                        child: SizedBox(
                          height: screenHeight * 0.4, // Slightly taller for better proportions
                          child: _buildActiveCharacter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
  
          // Menu Overlay
          if (_isMenuOpen)
            MenuOverlay(
              onClose: () {
                setState(() {
                  _isMenuOpen = false;
                });
              },
              onSave: () {
                widget.game.saveGame('manual');
                widget.game.audioManager.playSoundEffect('ui_click');
              },
              onLoad: () {
                widget.game.loadGame('quick');
                widget.game.audioManager.playSoundEffect('ui_click');
              },
              audioManager: widget.game.audioManager,
              gameState: widget.game.gameState,
            ),
        ],
      ),
    );
  }

  String _getBackgroundPath(String backgroundId) {
    try {
      final sceneInfo = widget.game.assetsManager.backgrounds['scenes'][backgroundId];
      if (sceneInfo != null && sceneInfo['background'] != null) {
        return 'visualassets/${sceneInfo['background']}';
      } else {
        // Fallback to a default background
        return 'visualassets/background/school_entrance_morning.png';
      }
    } catch (e) {
      print('Error getting background: $e');
      return 'visualassets/background/school_entrance_morning.png';
    }
  }

  // Build single active character for portrait mode
  Widget _buildActiveCharacter() {
    // Get the active character from the character manager
    final activeCharacter = widget.game.characterManager.getActiveCharacter();
    
    // If no active character, return empty container
    if (activeCharacter == null) {
      return Container();
    }
    
    final characterPath = _getCharacterPath(
      activeCharacter.characterId, 
      activeCharacter.expression
    );

    return Align(
      alignment: Alignment.bottomRight, // Ensure character is aligned to bottom
      child: Image.asset(
        characterPath,
        fit: BoxFit.contain, 
        alignment: Alignment.bottomRight, // Align the image itself to bottom right
        errorBuilder: (context, error, stackTrace) {
          print('Error loading character: $error, path: $characterPath');
          return Container();
        },
      ),
    );
  }

  String _getCharacterPath(String characterId, String expression) {
    final path = widget.game.characterManager.getCharacterSpritePath(characterId, expression);
    
    // Check if path already includes visualassets
    if (path.startsWith('visualassets/')) {
      return path;
    } else {
      return 'visualassets/$path';
    }
  }

  Widget _buildEffectWidget(String effectId) {
    try {
      final effectInfo = widget.game.assetsManager.getEffectConfig(effectId);
      if (effectInfo != null && effectInfo['image'] != null) {
        return Image.asset(
          'visualassets/${effectInfo['image']}',
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      print('Error building effect widget: $e');
    }
    
    // Fallback
    return Container(
      color: Colors.black.withOpacity(0.5),
    );
  }
}