import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import '../game/harmony-seekers-game.dart';
import '../ui/visual-novel-ui.dart';

class GameIntegration extends StatefulWidget {
  const GameIntegration({super.key});

  @override
  State<GameIntegration> createState() => _GameIntegrationState();
}

class _GameIntegrationState extends State<GameIntegration> with WidgetsBindingObserver {
  late HarmonySeekersGame _game;
  bool _isLoaded = false;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Auto-save when app goes to background
      if (_isLoaded) {
        _game.gameState.autoSave();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume audio playback
      if (_isLoaded && !_game.gameState.isMuted) {
        if (_game.gameState.currentMusic.isNotEmpty) {
          _game.audioManager.playBackgroundMusic(_game.gameState.currentMusic);
        }
        if (_game.gameState.currentAmbient.isNotEmpty) {
          _game.audioManager.playAmbientSound(_game.gameState.currentAmbient);
        }
      }
    }
  }

  Future<void> _initializeGame() async {
    try {
      _game = HarmonySeekersGame();

      // Wait for the game to load
      await _game.onLoad();

      setState(() {
        _isLoaded = true;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Failed to load game: $e';
      });
      print('Error initializing game: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      // Error screen
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load game',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isError = false;
                    _errorMessage = '';
                    _isLoaded = false;
                  });
                  _initializeGame();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isLoaded) {
      // Loading screen
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'visualassets/ui/effects/transition.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image can't be loaded
                return const SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading Harmony Seekers...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please wait while we prepare your adventure...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Game UI
    return VisualNovelUI(game: _game);
  }
}