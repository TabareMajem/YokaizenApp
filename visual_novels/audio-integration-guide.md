# Audio Library Integration Guide

This guide explains how to implement and use the audio library integration in your interactive content admin wizard.

## Overview

The audio library integration allows content creators to:

1. Browse and search open-source sound effects and music
2. Preview audio before selection
3. Add selected audio to different content types (stories, games, exercises, quizzes)
4. Upload custom audio files for unique needs

## Integration Sources

The system integrates with multiple open-source audio libraries:

- **Freesound** - Large collection of sound effects and ambient recordings
- **MusOpen** - Public domain classical music
- **CC Mixter** - Creative Commons licensed music in various genres
- **Free Music Archive** - Diverse collection of music under various CC licenses
- **Uploaded Assets** - Custom audio uploaded by your team

## Implementation Steps

### 1. Add Dependencies

Update your `pubspec.yaml` file with these additional dependencies:

```yaml
dependencies:
  # Existing dependencies...
  audioplayers: ^4.0.1
  file_picker: ^5.3.2
  just_audio: ^0.9.34
  http: ^0.13.6
```

### 2. API Integration Configuration

Create a configuration file at `lib/services/audio_api_config.dart`:

```dart
class AudioApiConfig {
  // API keys for various services
  static const String freesoundApiKey = 'YOUR_FREESOUND_API_KEY';
  static const String freeMusicArchiveApiKey = 'YOUR_FMA_API_KEY';
  
  // Base URLs
  static const String freesoundBaseUrl = 'https://freesound.org/apiv2';
  static const String musopenBaseUrl = 'https://musopen.org/api';
  static const String ccMixterBaseUrl = 'http://ccmixter.org/api';
  static const String fmaBaseUrl = 'https://freemusicarchive.org/api';
  
  // Your backend endpoint for audio storage/retrieval
  static const String backendAudioEndpoint = 'https://your-api.example.com/audio';
}
```

Replace placeholder API keys with actual keys from the respective services.

### 3. Add Audio Fields to Content Models

Update each content model to include audio properties:

#### For Story Modules (`lib/models/story_module.dart`):

```dart
class DialogueNode {
  // Existing properties...
  final String? backgroundMusicId;
  final Map<String, String> soundEffects; // key: trigger, value: soundEffectId
  
  // Update constructor and copyWith method
}
```

#### For Game Modules (`lib/models/game_module.dart`):

```dart
class GameModule {
  // Existing properties...
  final String? backgroundMusicId;
  final Map<GameEventType, String> eventSounds; // event type to sound ID mapping
  
  // Update constructor and copyWith method
}
```

Repeat for other content models.

### 4. Add Audio Selection UI to Each Creator

For each content type creator, add audio selection buttons and previews where appropriate.

#### Example Implementation for Story Module:

```dart
// In the scene editor
ElevatedButton.icon(
  icon: const Icon(Icons.music_note),
  label: const Text('Background Music'),
  onPressed: () => _selectBackgroundMusic(context, adminState, sceneId),
),

// Method to show audio selection dialog
void _selectBackgroundMusic(
  BuildContext context, 
  AdminState adminState, 
  String sceneId
) {
  showDialog(
    context: context,
    builder: (context) => AudioSelectionDialog(
      title: 'Select Background Music',
      audioType: AudioType.music,
      currentAudioId: adminState.getSceneBackgroundMusic(sceneId),
      onSelectAudio: (audioAsset) {
        if (audioAsset != null) {
          adminState.setSceneBackgroundMusic(sceneId, audioAsset.id);
        } else {
          adminState.removeSceneBackgroundMusic(sceneId);
        }
      },
    ),
  );
}
```

## API Integration Details

### Freesound API

Example usage with the Freesound API:

```dart
Future<List<AudioAsset>> searchFreesoundEffects(String query) async {
  final url = Uri.parse(
    '${AudioApiConfig.freesoundBaseUrl}/search/text/' +
    '?query=$query&token=${AudioApiConfig.freesoundApiKey}' +
    '&fields=id,name,url,duration,license,tags'
  );
  
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final results = data['results'] as List;
    
    return results.map((item) {
      return AudioAsset(
        id: 'freesound_${item['id']}',
        title: item['name'],
        url: item['url'],
        type: 'sound_effect',
        duration: (item['duration'] as double).round(),
        source: 'Freesound',
        license: item['license'],
        tags: List<String>.from(item['tags']),
      );
    }).toList();
  } else {
    throw Exception('Failed to load sound effects');
  }
}
```

Implement similar methods for each audio source.

## Custom Audio Upload

For uploaded audio assets:

1. Use the `file_picker` package to select audio files
2. Upload to your backend storage
3. Register in your audio database
4. Make available in the audio library

```dart
Future<void> uploadAudioFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.audio,
    allowMultiple: false,
  );
  
  if (result != null && result.files.isNotEmpty) {
    final file = result.files.first;
    
    // Create multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AudioApiConfig.backendAudioEndpoint}/upload'),
    );
    
    // Add file
    request.files.add(
      http.MultipartFile.fromBytes(
        'audio',
        file.bytes!,
        filename: file.name,
      ),
    );
    
    // Add metadata
    request.fields['title'] = file.name;
    request.fields['type'] = _isMusic(file.name) ? 'music' : 'sound_effect';
    request.fields['source'] = 'Uploaded Assets';
    request.fields['license'] = 'Custom';
    request.fields['tags'] = ''; // Add UI to set tags
    
    // Send the request
    var response = await request.send();
    
    if (response.statusCode == 200) {
      // Success handling
    } else {
      // Error handling
    }
  }
}

bool _isMusic(String filename) {
  // Simple heuristic - could be improved
  return filename.toLowerCase().contains('music') || 
         filename.toLowerCase().contains('song') ||
         filename.toLowerCase().contains('track');
}
```

## Audio Playback Preview

For audio preview functionality:

```dart
class AudioPreviewController {
  final _player = AudioPlayer();
  String? _currentlyPlayingId;
  
  Future<void> playPreview(AudioAsset asset) async {
    if (_currentlyPlayingId != null) {
      await stopPreview();
    }
    
    await _player.setUrl(asset.url);
    await _player.play();
    _currentlyPlayingId = asset.id;
  }
  
  Future<void> stopPreview() async {
    await _player.stop();
    _currentlyPlayingId = null;
  }
  
  void dispose() {
    _player.dispose();
  }
}
```

## Testing the Integration

1. Obtain API keys for each service
2. Configure backend for storing uploaded audio
3. Test audio search, preview, and selection in each content type
4. Verify audio playback in the content preview
5. Test deployment to ensure audio assets are properly included

## Next Steps

After implementing the audio library:

1. Add volume controls for background music vs. sound effects
2. Implement looping options for background music
3. Add timing controls for sound effects in interactive content
4. Create a tagging system for your uploaded audio
5. Implement audio filtering by mood, tempo, or genre

## License Considerations

When using audio from these sources, ensure your app properly attributes the creators according to the specific license requirements. Each selected audio asset should store its license information, and your app should display appropriate credits.
