import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/harmony-seekers-game.dart';
import '../ui/visual-novel-ui.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late HarmonySeekersGame _game;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Force portrait orientation instead of landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initializeGame();
  }

  @override
  void dispose() {
    // Clean up game resources
    if (_isLoaded) {
      _game.cleanup();
    }
    
    // No need to reset orientation since we're already in portrait mode
    super.dispose();
  }

  Future<void> _initializeGame() async {
    _game = HarmonySeekersGame();

    // Wait for the game to load
    await _game.onLoad();

    setState(() {
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      // Loading screen
      return SafeArea(
        child: Scaffold(
          body: Center(
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
              ],
            ),
          ),
        ),
      );
    }

    // Game UI
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        _showExitConfirmation(context);
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Visual Novel UI
            VisualNovelUI(game: _game),
            
            // Back button overlay
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showExitConfirmation(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Exit Game', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to exit the game? Any unsaved progress will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clean up game resources
              await _game.cleanup();
              
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}