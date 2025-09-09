import 'package:flame_audio/flame_audio.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AudioManager {
  bool isMuted = false;
  double musicVolume = 0.7;
  double sfxVolume = 1.0;
  String? currentMusic;
  String? currentAmbient;
  // Track the ambient audio player
  dynamic _ambientPlayer;

  // Audio configuration
  Map<String, dynamic> audioConfig = {};

  static Future<AudioManager> initialize() async {
    final manager = AudioManager();
    await manager._loadAudioConfig();
    
    // Configure FlameAudio to use the correct prefix
    FlameAudio.audioCache.prefix = '';
    
    return manager;
  }

  Future<void> _loadAudioConfig() async {
    try {
      // Load audio configuration from file
      final content = await rootBundle.loadString('visualassets/config/audio-config.json');
      audioConfig = jsonDecode(content);

      // Set default volumes from config if available
      if (audioConfig.containsKey('music')) {
        final firstMusic = audioConfig['music'].values.firstWhere(
                (music) => music != null,
            orElse: () => null
        );
        if (firstMusic != null && firstMusic['volume'] != null) {
          musicVolume = firstMusic['volume'];
        }
      }

      if (audioConfig.containsKey('sfx')) {
        // Find any sfx with volume to use as default
        double? defaultSfxVolume;
        audioConfig['sfx'].forEach((category, sounds) {
          sounds.forEach((sound, config) {
            if (config != null && config['volume'] != null) {
              defaultSfxVolume = config['volume'];
            }
          });
        });

        if (defaultSfxVolume != null) {
          sfxVolume = defaultSfxVolume!;
        }
      }

      // Preload audio files is skipped for now as it's causing issues
      // await _preloadAudioFiles();

    } catch (e) {
      print('Error loading audio config: $e');
      // Create a default config if loading fails
      audioConfig = {
        "music": {},
        "ambient": {},
        "sfx": {"ui": {}, "effects": {}}
      };
    }
  }

  // Check if an asset exists
  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      print('Asset exists: $assetPath');
      return true;
    } catch (e) {
      print('Asset does not exist: $assetPath - $e');
      return false;
    }
  }

  Future<void> playBackgroundMusic(String musicId) async {
    if (musicId == currentMusic) return;

    if (currentMusic != null) {
      try {
        await FlameAudio.bgm.stop();
      } catch (e) {
        print('Error stopping background music: $e');
      }
    }

    if (!isMuted && musicId.isNotEmpty) {
      try {
        // Direct play attempt using hardcoded paths
        currentMusic = musicId;
        
        // Use direct asset path based on musicId
        String assetPath;
        if (musicId == 'school_theme') {
          assetPath = 'visualassets/audio/music/school_theme.mp3';
        } else if (musicId == 'mystery_theme') {
          assetPath = 'visualassets/audio/music/mystery_theme.wav'; // Changed to .wav
        } else {
          assetPath = 'visualassets/audio/music/$musicId.mp3';
        }
        
        // Try to load the asset to verify it exists
        if (await _assetExists(assetPath)) {
          await FlameAudio.bgm.play(
            assetPath,
            volume: musicVolume,
          );
          print('Successfully started playing music: $assetPath');
        } else {
          print('Cannot play music - asset does not exist: $assetPath');
        }
      } catch (e) {
        print('Error playing background music: $e');
      }
    }
  }

  Future<void> playAmbientSound(String ambientId) async {
    if (ambientId == currentAmbient) return;

    // Stop current ambient if playing
    if (currentAmbient != null) {
      try {
        // Stop current ambient
        await FlameAudio.audioCache.clearAll();
        
        // Also try to stop the specific ambient player if we have it
        if (_ambientPlayer != null) {
          try {
            await _ambientPlayer.stop();
            await _ambientPlayer.release();
            _ambientPlayer = null;
            print('Successfully stopped ambient player');
          } catch (e) {
            print('Error stopping ambient player: $e');
          }
        }
      } catch (e) {
        print('Error stopping ambient sound: $e');
      }
    }

    if (!isMuted && ambientId.isNotEmpty) {
      try {
        // Direct play attempt using hardcoded paths
        currentAmbient = ambientId;
        
        // Use direct asset path based on ambientId
        String assetPath;
        if (ambientId == 'school_morning') {
          assetPath = 'visualassets/audio/ambient/school_morning.mp3';
        } else if (ambientId == 'classroom') {
          assetPath = 'visualassets/audio/ambient/classroom.mp3';
        } else if (ambientId == 'storage_room') {
          assetPath = 'visualassets/audio/ambient/storage_room.mp3';
        } else {
          assetPath = 'visualassets/audio/ambient/$ambientId.mp3';
        }
        
        // Try to load the asset to verify it exists
        if (await _assetExists(assetPath)) {
          // Store the player reference for later stopping
          _ambientPlayer = await FlameAudio.loopLongAudio(
            assetPath,
            volume: musicVolume * 0.5,
          );
          print('Successfully started playing ambient sound: $assetPath');
        } else {
          print('Cannot play ambient sound - asset does not exist: $assetPath');
        }
      } catch (e) {
        print('Error playing ambient sound: $e');
      }
    }
  }

  Future<void> playSoundEffect(String sfxId) async {
    if (isMuted) return;

    try {
      // Direct play attempt with category inference
      String assetPath;
      
      if (sfxId.startsWith('ui_')) {
        assetPath = 'visualassets/audio/sfx/ui/${sfxId.substring(3)}.mp3';
      } else if (sfxId.contains('effect') || sfxId == 'artifact_glow' || sfxId == 'time_shard' || sfxId == 'mirror_reveal') {
        assetPath = 'visualassets/audio/sfx/effects/$sfxId.mp3';
      } else {
        assetPath = 'visualassets/audio/sfx/$sfxId.mp3';
      }
      
      // Try to load the asset to verify it exists
      if (await _assetExists(assetPath)) {
        await FlameAudio.play(
          assetPath,
          volume: sfxVolume,
        );
        print('Successfully played sound effect: $assetPath');
      } else {
        print('Cannot play sound effect - asset does not exist: $assetPath');
      }
    } catch (e) {
      print('Error playing sound effect $sfxId: $e');
    }
  }

  // Helper method to stop looping audio
  Future<void> _stopLoopingAudio() async {
    try {
      // Try to stop any looping audio by playing a silent sound
      // This is a workaround since we can't directly access the looping audio player
      await FlameAudio.play('visualassets/audio/ambient/silence.mp3', volume: 0);
      print('Attempted to stop looping audio with silent playback');
    } catch (e) {
      print('Error stopping looping audio: $e');
    }
  }

  // New method to stop all audio when exiting the game
  Future<void> stopAllAudio() async {
    try {
      print('Stopping all audio...');
      
      // Save references to current audio before clearing them
      String? oldMusic = currentMusic;
      String? oldAmbient = currentAmbient;
      
      // Reset tracking variables first to prevent any restart attempts
      currentMusic = null;
      currentAmbient = null;
      
      // Stop background music
      try {
        await FlameAudio.bgm.stop();
        print('Successfully stopped background music');
      } catch (e) {
        print('Error stopping background music: $e');
      }
      
      // Stop ambient sounds - more thorough approach
      try {
        // Clear all audio cache to stop ambient sounds
        await FlameAudio.audioCache.clearAll();
        print('Successfully cleared audio cache');
        
        // Try to explicitly stop the ambient player if we have it
        if (_ambientPlayer != null) {
          try {
            await _ambientPlayer.stop();
            await _ambientPlayer.release();
            _ambientPlayer = null;
            print('Successfully stopped ambient player');
          } catch (e) {
            print('Error stopping ambient player: $e');
          }
        }
        
        // Try to explicitly stop looping audio by calling the internal player
        try {
          // This is a direct approach to stop the looping audio
          // Access the underlying audio player if possible
          if (FlameAudio.audioCache.loadedFiles.isNotEmpty) {
            FlameAudio.audioCache.loadedFiles.clear();
            print('Cleared loaded audio files');
          }
        } catch (e) {
          print('Error clearing loaded files: $e');
        }
      } catch (e) {
        print('Error clearing audio cache: $e');
      }
      
      // Additional steps to ensure all audio is stopped
      try {
        // Release all audio resources
        FlameAudio.bgm.audioPlayer.release();
        print('Successfully released audio player resources');
      } catch (e) {
        print('Error releasing audio player: $e');
      }
      
      // Force dispose audio players
      try {
        FlameAudio.bgm.dispose();
        print('Successfully disposed bgm');
      } catch (e) {
        print('Error disposing bgm: $e');
      }
      
      // Force garbage collection to clean up any lingering audio resources
      try {
        // Set volume to 0 for any potentially playing audio
        FlameAudio.bgm.audioPlayer.setVolume(0);
      } catch (e) {
        print('Error setting volume to 0: $e');
      }
      
      print('Successfully stopped all audio');
    } catch (e) {
      print('Error stopping all audio: $e');
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      try {
        FlameAudio.bgm.stop();
        FlameAudio.audioCache.clearAll(); // Stop ambient sounds
        
        // Also stop the ambient player if we have it
        if (_ambientPlayer != null) {
          try {
            _ambientPlayer.stop();
            _ambientPlayer.release();
            _ambientPlayer = null;
            print('Successfully stopped ambient player on mute');
          } catch (e) {
            print('Error stopping ambient player on mute: $e');
          }
        }
      } catch (e) {
        print('Error toggling mute: $e');
      }
    } else if (currentMusic != null) {
      playBackgroundMusic(currentMusic!);
      if (currentAmbient != null) {
        playAmbientSound(currentAmbient!);
      }
    }
  }

  void setMusicVolume(double volume) {
    musicVolume = volume.clamp(0.0, 1.0);
    if (currentMusic != null && !isMuted) {
      // Update current music volume
      try {
        FlameAudio.bgm.audioPlayer.setVolume(musicVolume);
      } catch (e) {
        print('Error setting music volume: $e');
      }
    }
  }

  void setSfxVolume(double volume) {
    sfxVolume = volume.clamp(0.0, 1.0);
  }

  // Get a specific sound file path
  String? getSoundPath(String soundId, String category) {
    if (category == 'music') {
      if (soundId == 'mystery_theme') {
        return 'music/$soundId.wav';
      }
      return 'music/$soundId.mp3';
    } else if (category == 'ambient') {
      return 'ambient/$soundId.mp3';
    } else if (category == 'sfx') {
      if (soundId.startsWith('ui_')) {
        return 'sfx/ui/${soundId.substring(3)}.mp3';
      } else if (soundId.contains('effect')) {
        return 'sfx/effects/$soundId.mp3';
      } else {
        return 'sfx/$soundId.mp3';
      }
    }
    return null;
  }

  // Play UI sound
  Future<void> playUISound(String soundId) async {
    await playSoundEffect('ui_$soundId');
  }

  // Play effect sound
  Future<void> playEffectSound(String effectId) async {
    await playSoundEffect('effect_$effectId');
  }
}