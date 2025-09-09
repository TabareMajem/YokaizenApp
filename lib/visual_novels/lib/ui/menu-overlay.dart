import 'package:flutter/material.dart';
import '../managers/audio-manager.dart';
import '../state/game-state.dart';

class MenuOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onSave;
  final VoidCallback? onLoad;
  final AudioManager? audioManager;
  final GameState? gameState;

  const MenuOverlay({
    super.key,
    required this.onClose,
    this.onSave,
    this.onLoad,
    this.audioManager,
    this.gameState,
  });

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  MenuTab _currentTab = MenuTab.main;
  String? _selectedSaveSlot;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeMenu() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  void _switchTab(MenuTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  void _saveGame(String slotId) {
    if (widget.gameState != null) {
      widget.gameState!.saveGame(slotId);
      if (widget.audioManager != null) {
        widget.audioManager!.playSoundEffect('ui_click');
      }

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _loadGame(String slotId) {
    if (widget.onLoad != null) {
      _selectedSaveSlot = slotId;
      if (widget.audioManager != null) {
        widget.audioManager!.playSoundEffect('ui_click');
      }
      widget.onLoad!();
      _closeMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size to make UI responsive
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    // Calculate menu width based on screen size
    final menuWidth = isSmallScreen ? screenSize.width * 0.85 : 340.0;
    final menuHeight = isSmallScreen ? screenSize.height * 0.7 : 480.0;

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Container(
              width: menuWidth,
              constraints: BoxConstraints(maxHeight: menuHeight),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Menu Header
                  _buildMenuHeader(),

                  // Menu Content based on current tab
                  Flexible(
                    child: _getTabContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Text(
            'Game Menu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: _closeMenu,
          ),
        ],
      ),
    );
  }

  Widget _getTabContent() {
    switch (_currentTab) {
      case MenuTab.main:
        return _buildMainMenuTab();
      case MenuTab.save:
        return _buildSaveTab();
      case MenuTab.load:
        return _buildLoadTab();
      case MenuTab.settings:
        return _buildSettingsTab();
    }
  }

  Widget _buildMainMenuTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuButton(
            text: 'Continue',
            onPressed: _closeMenu,
            icon: Icons.play_arrow,
          ),

          _MenuButton(
            text: 'Settings',
            onPressed: () => _switchTab(MenuTab.settings),
            icon: Icons.settings,
          ),

          _MenuButton(
            text: 'Return to Main Menu',
            onPressed: () {
              // Confirm before returning to main menu
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
                        // Ensure all audio is stopped
                        if (widget.audioManager != null) {
                          await widget.audioManager!.stopAllAudio();
                        }
                        
                        // Make sure to release all audio resources
                        if (widget.audioManager != null) {
                          try {
                            widget.audioManager!.currentMusic = null;
                            widget.audioManager!.currentAmbient = null;
                          } catch (e) {
                            print('Error resetting audio state: $e');
                          }
                        }
                        
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Close menu
                        Navigator.pop(context); // Return to previous screen
                      },
                      child: const Text('Exit'),
                    ),
                  ],
                ),
              );
            },
            icon: Icons.home,
            isPrimary: false,
          ),

          _MenuButton(
            text: 'Quit Game',
            onPressed: () {
              // Confirm before quitting
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black87,
                  title: const Text('Quit Game', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Are you sure you want to quit the game? Any unsaved progress will be lost.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Ensure all audio is stopped
                        if (widget.audioManager != null) {
                          await widget.audioManager!.stopAllAudio();
                        }
                        
                        // Make sure to release all audio resources
                        if (widget.audioManager != null) {
                          try {
                            widget.audioManager!.currentMusic = null;
                            widget.audioManager!.currentAmbient = null;
                          } catch (e) {
                            print('Error resetting audio state: $e');
                          }
                        }
                        
                        Navigator.pop(context); // Close dialog
                        _closeMenu(); // Close menu
                      },
                      child: const Text('Quit'),
                    ),
                  ],
                ),
              );
            },
            icon: Icons.exit_to_app,
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveTab() {
    return Column(
      children: [
        // Tab Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.black54,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => _switchTab(MenuTab.main),
              ),
              const Text(
                'Save Game',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Feature not available message
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white70,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Save functionality is not available in this version.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your progress will be automatically saved when you complete a chapter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Back button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            onPressed: () => _switchTab(MenuTab.main),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadTab() {
    return Column(
      children: [
        // Tab Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.black54,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => _switchTab(MenuTab.main),
              ),
              const Text(
                'Load Game',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Feature not available message
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white70,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Load functionality is not available in this version.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your progress will be automatically loaded when you restart the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Back button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            onPressed: () => _switchTab(MenuTab.main),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return Column(
      children: [
        // Tab Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.black54,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => _switchTab(MenuTab.main),
              ),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SettingsMenu(
              musicVolume: widget.gameState?.musicVolume ?? 0.7,
              sfxVolume: widget.gameState?.sfxVolume ?? 1.0,
              isMuted: widget.gameState?.isMuted ?? false,
              onMusicVolumeChanged: (volume) {
                if (widget.audioManager != null && widget.gameState != null) {
                  widget.audioManager!.setMusicVolume(volume);
                  widget.gameState!.setMusicVolume(volume);
                  setState(() {});
                }
              },
              onSfxVolumeChanged: (volume) {
                if (widget.audioManager != null && widget.gameState != null) {
                  widget.audioManager!.setSfxVolume(volume);
                  widget.gameState!.setSfxVolume(volume);
                  setState(() {});
                }
              },
              onMuteToggled: (isMuted) {
                if (widget.audioManager != null && widget.gameState != null) {
                  widget.audioManager!.toggleMute();
                  widget.gameState!.toggleMute();
                  setState(() {});
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

enum MenuTab {
  main,
  save,
  load,
  settings,
}

class _MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;

  const _MenuButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.arrow_forward),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.blue.shade800 : Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

class _SaveSlotItem extends StatelessWidget {
  final String slotId;
  final int slotNumber;
  final String saveDate;
  final bool hasSave;
  final VoidCallback? onTap;

  const _SaveSlotItem({
    required this.slotId,
    required this.slotNumber,
    required this.saveDate,
    required this.hasSave,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: hasSave ? Colors.blue.shade700 : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Slot Number
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hasSave ? Colors.blue.shade900 : Colors.black38,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30),
              ),
              child: Text(
                '$slotNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Save info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save Slot $slotNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    saveDate,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Icon
            Icon(
              hasSave ? Icons.save : Icons.save_outlined,
              color: hasSave ? Colors.blue.shade400 : Colors.white30,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsMenu extends StatefulWidget {
  final double musicVolume;
  final double sfxVolume;
  final bool isMuted;
  final Function(double) onMusicVolumeChanged;
  final Function(double) onSfxVolumeChanged;
  final Function(bool) onMuteToggled;

  const SettingsMenu({
    super.key,
    required this.musicVolume,
    required this.sfxVolume,
    required this.isMuted,
    required this.onMusicVolumeChanged,
    required this.onSfxVolumeChanged,
    required this.onMuteToggled,
  });

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  late double _musicVolume;
  late double _sfxVolume;
  late bool _isMuted;
  late bool _autoPlay = false;
  late double _textSpeed = 0.5;

  @override
  void initState() {
    super.initState();
    _musicVolume = widget.musicVolume;
    _sfxVolume = widget.sfxVolume;
    _isMuted = widget.isMuted;
  }

  @override
  void didUpdateWidget(SettingsMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.musicVolume != widget.musicVolume ||
        oldWidget.sfxVolume != widget.sfxVolume ||
        oldWidget.isMuted != widget.isMuted) {
      setState(() {
        _musicVolume = widget.musicVolume;
        _sfxVolume = widget.sfxVolume;
        _isMuted = widget.isMuted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Title - Audio
        _buildSectionHeader('Audio Settings'),

        // Music Volume Slider
        _buildVolumeSlider(
          'Music Volume',
          _musicVolume,
          Icons.music_note,
              (value) {
            setState(() => _musicVolume = value);
            widget.onMusicVolumeChanged(value);
          },
        ),

        // SFX Volume Slider
        _buildVolumeSlider(
          'Sound Effects',
          _sfxVolume,
          Icons.volume_up,
              (value) {
            setState(() => _sfxVolume = value);
            widget.onSfxVolumeChanged(value);
          },
        ),

        // Mute Toggle
        _buildSwitchOption(
          'Mute All Sounds',
          _isMuted,
          Icons.volume_off,
              (value) {
            setState(() => _isMuted = value);
            widget.onMuteToggled(value);
          },
        ),

        const SizedBox(height: 16),

        // Section Title - Display
        _buildSectionHeader('Display Settings'),

        // Auto-play toggle
        _buildSwitchOption(
          'Auto-Play Dialogue',
          _autoPlay,
          Icons.auto_stories,
              (value) {
            setState(() => _autoPlay = value);
            // This would update game settings
          },
        ),

        // Text Speed
        _buildVolumeSlider(
          'Text Speed',
          _textSpeed,
          Icons.speed,
              (value) {
            setState(() => _textSpeed = value);
            // This would update game settings
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 1,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider(
      String label,
      double value,
      IconData icon,
      Function(double) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Slider(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.blue.shade400,
                  inactiveColor: Colors.grey.shade800,
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption(
      String label,
      bool value,
      IconData icon,
      Function(bool) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue.shade400,
          ),
        ],
      ),
    );
  }
}