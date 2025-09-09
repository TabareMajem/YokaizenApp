/// Unity Game Screen
/// Displays Unity games within Flutter app with game controls and state management

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:get/get.dart';

import '../../../services/unity_game_service.dart';
import '../../../util/colors.dart';
import '../../../util/text_styles.dart';

class UnityGameScreen extends StatefulWidget {
  final GameType gameType;
  
  const UnityGameScreen({
    super.key,
    required this.gameType,
  });

  @override
  State<UnityGameScreen> createState() => _UnityGameScreenState();
}

class _UnityGameScreenState extends State<UnityGameScreen> with WidgetsBindingObserver {
  final UnityGameService gameService = UnityGameService.instance;
  UnityWidgetController? unityController;
  bool _isFullScreen = false;
  bool _showControls = true;
  bool _unityAvailable = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupSystemUI();
    _checkUnityAvailability();
  }
  
  /// Check if Unity platform view is available
  Future<void> _checkUnityAvailability() async {
    try {
      // For now, we know Unity isn't available since projects aren't built
      // In the future, this could check for platform view registration
      setState(() {
        _unityAvailable = false;
      });
    } catch (e) {
      setState(() {
        _unityAvailable = false;
      });
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetSystemUI();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (gameService.gameState == GameState.playing) {
          gameService.pauseGame();
        }
        break;
      case AppLifecycleState.resumed:
        // Game will handle resume through UI
        break;
      default:
        break;
    }
  }
  
  void _setupSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }
  
  void _resetSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
  
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _showControls = !_isFullScreen;
    });
    
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      _setupSystemUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFullScreen) {
          _toggleFullScreen();
          return false;
        }
        return await _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullScreen ? null : _buildAppBar(),
        body: Stack(
          children: [
            // Unity Game Widget
            _buildUnityWidget(),
            
            // Game Controls Overlay
            if (_showControls && !_isFullScreen)
              _buildGameControls(),
            
            // Game State Overlay
            _buildGameStateOverlay(),
            
            // Full screen toggle (always visible)
            _buildFullScreenToggle(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'icons/arrowLeft.svg',
          color: Colors.white,
        ),
        onPressed: () async {
          if (await _showExitDialog()) {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        _getGameTitle(),
        style: AppTextStyle.normalBold20.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.fullscreen,
            color: Colors.white,
          ),
          onPressed: _toggleFullScreen,
        ),
      ],
    );
  }

  Widget _buildUnityWidget() {
    // Check if Unity is available before attempting to create the widget
    if (!_unityAvailable) {
      return _buildUnityErrorWidget('Unity platform view not registered');
    }
    
    // If Unity is available, try to create the widget with error handling
    return FutureBuilder<Widget>(
      future: _buildUnityWidgetSafely(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        
        if (snapshot.hasError) {
          return _buildUnityErrorWidget(snapshot.error.toString());
        }
        
        return snapshot.data ?? _buildUnityErrorWidget('Unknown error occurred');
      },
    );
  }
  
  Future<Widget> _buildUnityWidgetSafely() async {
    try {
      // Check if Unity platform view is available before creating widget
      return UnityWidget(
        onUnityCreated: _onUnityCreated,
        onUnityMessage: _onUnityMessage,
        // onUnitySceneLoaded: _onUnitySceneLoaded,
        placeholder: _buildLoadingPlaceholder(),
        borderRadius: BorderRadius.zero,
      );
    } catch (e) {
      // If Unity widget fails to create, return error widget
      throw Exception('Unity platform view error: $e');
    }
  }
  
  Widget _buildUnityErrorWidget(String error) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Unity Games Coming Soon!',
                style: AppTextStyle.normalBold20.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                'The VoiceBridge games are currently being prepared.\nFollow the setup guide to enable Unity integration.',
                style: AppTextStyle.normalBold14.copyWith(
                  color: Colors.white70,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Next Steps:',
                      style: AppTextStyle.normalBold14.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Follow the Unity Game Integration Guide\n2. Build Unity projects for mobile\n3. Configure platform views\n4. Restart the app',
                      style: AppTextStyle.normalBold12.copyWith(
                        color: Colors.orange,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back, size: 18),
                    label: Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coral500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Retry loading the Unity widget
                      _checkUnityAvailability();
                    },
                    icon: Icon(Icons.refresh, size: 18),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: indigo500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: indigo500,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.games,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading ${_getGameTitle()}...'.tr,
              style: AppTextStyle.normalBold20.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Preparing game environment...'.tr,
              style: AppTextStyle.normalBold14.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(coral500),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Obx(() {
        final gameState = gameService.gameState;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildControlButton(
                  icon: gameState == GameState.playing 
                      ? Icons.pause 
                      : Icons.play_arrow,
                  label: gameState == GameState.playing 
                      ? 'Pause'.tr 
                      : 'Play'.tr,
                  onTap: () {
                    if (gameState == GameState.playing) {
                      gameService.pauseGame();
                    } else if (gameState == GameState.paused) {
                      gameService.resumeGame();
                    } else {
                      gameService.startGame();
                    }
                  },
                  color: coral500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControlButton(
                  icon: Icons.refresh,
                  label: 'Restart'.tr,
                  onTap: () => _showRestartDialog(),
                  color: indigo500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControlButton(
                  icon: Icons.settings,
                  label: 'Settings'.tr,
                  onTap: () => _showGameSettings(),
                  color: grey2,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTextStyle.normalBold10.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStateOverlay() {
    return Obx(() {
      final gameState = gameService.gameState;
      
      if (gameState == GameState.paused) {
        return _buildPausedOverlay();
      } else if (gameState == GameState.completed) {
        return _buildCompletedOverlay();
      } else if (gameState == GameState.error) {
        return _buildErrorOverlay();
      }
      
      return const SizedBox.shrink();
    });
  }

  Widget _buildPausedOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pause_circle_filled,
                  size: 60,
                  color: indigo500,
                ),
                const SizedBox(height: 20),
                Text(
                  'Game Paused'.tr,
                  style: AppTextStyle.normalBold18.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap resume to continue playing'.tr,
                  style: AppTextStyle.normalBold14.copyWith(
                    color: grey2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => gameService.resumeGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: coral500,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Resume Game'.tr,
                    style: AppTextStyle.normalBold14.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 60,
                  color: coral500,
                ),
                const SizedBox(height: 20),
                Text(
                  'Congratulations!'.tr,
                  style: AppTextStyle.normalBold18.copyWith(
                    fontWeight: FontWeight.bold,
                    color: coral500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You completed the game!'.tr,
                  style: AppTextStyle.normalBold14.copyWith(
                    color: grey2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final score = gameService.gameData['score'] ?? 0;
                  return Text(
                    'Final Score: $score'.tr,
                    style: AppTextStyle.normalBold20.copyWith(
                      fontWeight: FontWeight.bold,
                      color: indigo500,
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => gameService.restartGame(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: indigo500,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Play Again'.tr,
                          style: AppTextStyle.normalBold14.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          gameService.exitGame();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: coral500,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Exit Game'.tr,
                          style: AppTextStyle.normalBold14.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  'Game Error'.tr,
                  style: AppTextStyle.normalBold18.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Something went wrong. Please try restarting the game.'.tr,
                  style: AppTextStyle.normalBold14.copyWith(
                    color: grey2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => gameService.restartGame(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: indigo500,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Restart'.tr,
                          style: AppTextStyle.normalBold14.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: grey2,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Exit'.tr,
                          style: AppTextStyle.normalBold14.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenToggle() {
    if (_isFullScreen) {
      return Positioned(
        top: 40,
        right: 20,
        child: GestureDetector(
          onTap: _toggleFullScreen,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fullscreen_exit,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // Unity callbacks
  void _onUnityCreated(UnityWidgetController controller) {
    unityController = controller;
    gameService.onUnityCreated(widget.gameType, controller);
  }

  void _onUnityMessage(message) {
    // Messages are handled by the game service
  }

  // void _onUnitySceneLoaded(SceneLoaded scene) {
  //   print('Unity scene loaded: ${scene.name}');
  // }

  // Helper methods
  String _getGameTitle() {
    switch (widget.gameType) {
      case GameType.voiceBridge:
        return 'VoiceBridge Classic';
      case GameType.voiceBridgePolished:
        return 'VoiceBridge Polished';
    }
  }

  // Dialog methods
  Future<bool> _showExitDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Exit Game?'.tr),
        content: Text('Your progress will be saved automatically.'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              gameService.exitGame();
              Get.back(result: true);
            },
            child: Text('Exit'.tr),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showRestartDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Restart Game?'.tr),
        content: Text('All current progress will be lost.'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              gameService.restartGame();
              Get.back();
            },
            child: Text('Restart'.tr),
          ),
        ],
      ),
    );
  }

  void _showGameSettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Settings'.tr,
              style: AppTextStyle.normalBold20.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.volume_up, color: indigo500),
              title: Text('Sound Effects'.tr),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Handle sound toggle
                },
                activeColor: coral500,
              ),
            ),
            ListTile(
              leading: Icon(Icons.vibration, color: indigo500),
              title: Text('Haptic Feedback'.tr),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Handle haptic toggle
                },
                activeColor: coral500,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: coral500,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Close'.tr,
                  style: AppTextStyle.normalBold14.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
