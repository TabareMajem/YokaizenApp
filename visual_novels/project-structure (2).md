# Complete Admin Wizard Project Structure

Here's the complete project structure for your interactive content admin wizard with all features including audio library integration:

```
vlog_therapy_admin/
│
├── pubspec.yaml                 # Project dependencies
│
├── lib/
│   ├── main.dart                # Application entry point
│   │
│   ├── models/                  # Data models
│   │   ├── admin_state.dart     # Global application state
│   │   ├── audio_asset.dart     # Audio file model
│   │   ├── character.dart       # Character model
│   │   ├── cbt_exercise.dart    # CBT exercise model
│   │   ├── dialogue_node.dart   # Dialogue nodes for stories
│   │   ├── game_module.dart     # Mini-game model
│   │   ├── quiz_module.dart     # Quiz model
│   │   ├── scene.dart           # Scene/background model
│   │   ├── story_module.dart    # Visual novel/story model
│   │   └── visual_asset.dart    # Visual asset model (images, etc.)
│   │
│   ├── services/                # API and backend services
│   │   ├── api_service.dart     # Base API service
│   │   ├── audio_api_config.dart # Audio API configuration
│   │   ├── audio_api_service.dart # Audio API service
│   │   ├── auth_service.dart    # Authentication service
│   │   ├── content_api.dart     # Content API for deployment
│   │   ├── deployment_service.dart # Deployment service
│   │   ├── preview_service.dart # Content preview service
│   │   └── storage_service.dart # Asset storage service
│   │
│   ├── screens/                 # Main screens
│   │   ├── dashboard_screen.dart # Admin dashboard
│   │   ├── login_screen.dart    # Login screen
│   │   ├── settings_screen.dart # Settings screen
│   │   └── wizard_screen.dart   # Main wizard screen
│   │
│   ├── widgets/                 # Reusable UI components
│   │   ├── audio/
│   │   │   ├── audio_library_manager.dart # Audio browser
│   │   │   ├── audio_player_widget.dart   # Audio player
│   │   │   └── audio_selection_dialog.dart # Audio picker
│   │   │
│   │   ├── cbt/
│   │   │   ├── cbt_exercise_creator.dart  # CBT exercise editor
│   │   │   └── exercise_preview.dart      # Exercise preview
│   │   │
│   │   ├── common/
│   │   │   ├── asset_picker.dart          # Asset selection
│   │   │   ├── color_picker.dart          # Color selection
│   │   │   ├── confirmation_dialog.dart   # Confirmation dialogs
│   │   │   ├── loading_overlay.dart       # Loading indicator
│   │   │   └── tag_editor.dart            # Tag editor
│   │   │
│   │   ├── game/
│   │   │   ├── game_character_editor.dart # Game character editor
│   │   │   ├── game_environment_editor.dart # Game environment editor
│   │   │   ├── game_obstacle_editor.dart  # Game obstacle editor
│   │   │   ├── game_preview.dart          # Game preview
│   │   │   ├── game_reward_editor.dart    # Game reward editor
│   │   │   └── mini_game_creator.dart     # Mini-game creator
│   │   │
│   │   ├── quiz/
│   │   │   ├── answer_editor.dart         # Quiz answer editor
│   │   │   ├── question_editor.dart       # Quiz question editor
│   │   │   ├── quiz_creator.dart          # Quiz creator
│   │   │   └── quiz_preview.dart          # Quiz preview
│   │   │
│   │   ├── story/
│   │   │   ├── character_editor.dart      # Character editor
│   │   │   ├── dialogue_editor.dart       # Dialogue editor
│   │   │   ├── node_editor.dart           # Node editor
│   │   │   ├── node_graph.dart            # Node graph visualization
│   │   │   ├── scene_editor.dart          # Scene editor
│   │   │   └── story_preview.dart         # Story preview
│   │   │
│   │   ├── step_characters.dart           # Characters wizard step
│   │   ├── step_deploy.dart               # Deployment wizard step
│   │   ├── step_dialogue_editor.dart      # Dialogue wizard step
│   │   ├── step_preview.dart              # Preview wizard step
│   │   ├── step_scenes.dart               # Scenes wizard step
│   │   └── step_story_info.dart           # Story info wizard step
│   │
│   └── utils/                   # Utility functions
│       ├── audio_utils.dart     # Audio utilities
│       ├── color_utils.dart     # Color utilities
│       ├── export_utils.dart    # Export utilities
│       ├── file_utils.dart      # File handling utilities
│       ├── validation_utils.dart # Validation utilities
│       └── yaml_generator.dart  # YAML generator for Flame/Jenny
│
├── assets/                      # Static assets
│   ├── audio/                   # Default audio assets
│   │   ├── music/               # Background music
│   │   └── sfx/                 # Sound effects
│   │
│   ├── images/                  # Default images
│   │   ├── backgrounds/         # Background images
│   │   ├── characters/          # Character images
│   │   ├── icons/               # UI icons
│   │   └── ui/                  # UI elements
│   │
│   ├── templates/               # Content templates
│   │   ├── cbt/                 # CBT exercise templates
│   │   ├── games/               # Game templates
│   │   ├── quizzes/             # Quiz templates
│   │   └── stories/             # Story templates
│   │
│   └── fonts/                   # Custom fonts
│
├── web/                         # Web-specific files (for Flutter Web)
│   ├── index.html               # HTML entry point
│   ├── favicon.png              # Favicon
│   └── icons/                   # Web app icons
│
└── README.md                    # Project documentation
```

## Core Files Implementation

### pubspec.yaml

```yaml
name: vlog_therapy_admin
description: Admin wizard for creating interactive content with Flutter, Flame, and Jenny.

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=2.19.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.0.5
  http: ^0.13.5
  uuid: ^3.0.7
  firebase_core: ^2.4.1
  firebase_auth: ^4.2.5
  cloud_firestore: ^4.3.1
  flame: ^1.8.0
  jenny: ^1.0.0
  file_picker: ^5.2.5
  image_picker_web: ^3.0.0
  flutter_colorpicker: ^1.0.3
  flutter_markdown: ^0.6.14
  code_text_field: ^1.0.2
  graphview: ^1.1.1
  just_audio: ^0.9.34
  path_provider: ^2.0.15
  shared_preferences: ^2.1.1
  url_launcher: ^6.1.12
  intl: ^0.18.1
  flutter_svg: ^2.0.7
  drag_and_drop_lists: ^0.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/audio/music/
    - assets/audio/sfx/
    - assets/images/backgrounds/
    - assets/images/characters/
    - assets/images/icons/
    - assets/images/ui/
    - assets/templates/cbt/
    - assets/templates/games/
    - assets/templates/quizzes/
    - assets/templates/stories/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
        - asset: assets/fonts/Roboto-Italic.ttf
          style: italic
```

### lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/admin_state.dart';
import 'screens/login_screen.dart';
import 'screens/wizard_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        authDomain: "YOUR_AUTH_DOMAIN",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_STORAGE_BUCKET",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
      ),
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue without Firebase for development
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AdminState()),
        Provider(create: (context) => AuthService()),
      ],
      child: const AdminWizardApp(),
    ),
  );
}

class AdminWizardApp extends StatelessWidget {
  const AdminWizardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return MaterialApp(
      title: 'Interactive Content Admin Wizard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: StreamBuilder<bool>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          final bool isLoggedIn = snapshot.data ?? false;
          return isLoggedIn 
              ? const ContentWizard() 
              : const LoginScreen();
        },
      ),
    );
  }
}
```

## Implementation Notes

This structure provides a comprehensive framework for your interactive content admin wizard with all the features discussed:

1. **Visual Novel/Story Editor**: Full dialogue tree editor with node visualization
2. **Mini-Game Creator**: Environment, character, obstacle, and reward editors
3. **CBT Exercise Designer**: Templates for various CBT exercise types
4. **Quiz Creator**: Multiple question types and feedback configuration
5. **Audio Library**: Integration with open source audio services and upload capability
6. **Visual Asset Management**: Upload and management of images and visual assets

The project is organized following Flutter best practices with a clear separation of:

- **Models**: Data structures for all content types
- **Services**: API integrations and backend communication
- **Screens**: Main application screens
- **Widgets**: Reusable UI components organized by content type
- **Utils**: Helper functions for common tasks

This structure makes the codebase maintainable and extensible, allowing you to:

- Add new content types in the future
- Enhance existing editors with new features
- Integrate additional third-party services

The implementation uses Provider for state management, Firebase for authentication and storage, and follows an immutable data pattern for consistency and reliability.
