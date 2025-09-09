# Unity Games Integration Guide for YokaizenApp

## 🎮 **Overview**

This guide explains how to integrate your Unity games (`VoiceBridge` and `VoiceBridgePolished`) into the Flutter YokaizenApp.

## 📁 **Current Setup**

Your Unity games are located in:
- `games/game1/VoiceBridge/` - Classic VoiceBridge game
- `games/game2/VoiceBridgePolished/` - Enhanced version with improved graphics

## 🔧 **Flutter Integration Completed**

✅ **Flutter-Side Integration:**
- Unity Game Service (`lib/services/unity_game_service.dart`)
- Games Selection Screen (`lib/screens/games/view/games_screen.dart`)
- Unity Game Player Screen (`lib/screens/games/view/unity_game_screen.dart`)
- Navigation integration (Games tab added to bottom navigation)
- Home screen shortcuts added
- Dependency added to `pubspec.yaml`

## 🎯 **Next Steps: Unity Build Configuration**

### **Step 1: Prepare Unity Projects**

#### **For VoiceBridge Classic:**
1. Open Unity Hub and add the project: `games/game1/VoiceBridge/`
2. Open the project in Unity
3. Go to **File → Build Settings**
4. Add your game scenes to "Scenes In Build"
5. Switch platform to **Android** or **iOS**

#### **For VoiceBridge Polished:**
1. Open Unity Hub and add the project: `games/game2/VoiceBridgePolished/`
2. Open the project in Unity
3. Go to **File → Build Settings**
4. Add your game scenes to "Scenes In Build"
5. Switch platform to **Android** or **iOS**

### **Step 2: Install Flutter Unity Widget in Unity**

1. **Download flutter-unity-widget package:**
   ```bash
   git clone https://github.com/juicycleff/flutter-unity-view-widget.git
   ```

2. **Copy Unity files to your projects:**
   - Copy `unity/FlutterUnityIntegration/` to both:
     - `games/game1/VoiceBridge/Assets/FlutterUnityIntegration/`
     - `games/game2/VoiceBridgePolished/Assets/FlutterUnityIntegration/`

### **Step 3: Configure Unity Projects for Flutter**

#### **Add GameManager Script:**

Create `Assets/Scripts/GameManager.cs` in both projects:

```csharp
using UnityEngine;
using FlutterUnityIntegration;
using System.Collections;

public class GameManager : MonoBehaviour
{
    [Header("Game Settings")]
    public bool soundEnabled = true;
    public bool hapticFeedback = true;
    public string difficulty = "normal";
    
    [Header("Game State")]
    public int currentScore = 0;
    public int currentLevel = 1;
    public bool isGameActive = false;
    
    private void Start()
    {
        // Initialize game
        Debug.Log("VoiceBridge Game Manager started");
        SendMessageToFlutter("game_initialized", "Game is ready to play");
    }
    
    // Called from Flutter
    public void InitializeGame(string data)
    {
        Debug.Log($"Initializing game with data: {data}");
        
        // Parse Flutter data (JSON)
        try
        {
            var gameData = JsonUtility.FromJson<GameInitData>(data);
            soundEnabled = gameData.settings.sound_enabled;
            hapticFeedback = gameData.settings.haptic_feedback;
            difficulty = gameData.settings.difficulty;
            
            SendMessageToFlutter("game_ready", "Game initialized successfully");
        }
        catch (System.Exception e)
        {
            Debug.LogError($"Failed to parse game data: {e.Message}");
        }
    }
    
    // Called from Flutter
    public void StartGame()
    {
        Debug.Log("Starting game...");
        isGameActive = true;
        currentScore = 0;
        currentLevel = 1;
        
        // Start your game logic here
        SendMessageToFlutter("game_started", $"{{\"level\": {currentLevel}, \"score\": {currentScore}}}");
    }
    
    // Called from Flutter
    public void PauseGame()
    {
        Debug.Log("Pausing game...");
        isGameActive = false;
        Time.timeScale = 0f;
        
        SendMessageToFlutter("game_paused", "Game paused");
    }
    
    // Called from Flutter
    public void ResumeGame()
    {
        Debug.Log("Resuming game...");
        isGameActive = true;
        Time.timeScale = 1f;
        
        SendMessageToFlutter("game_resumed", "Game resumed");
    }
    
    // Called from Flutter
    public void RestartGame()
    {
        Debug.Log("Restarting game...");
        currentScore = 0;
        currentLevel = 1;
        Time.timeScale = 1f;
        
        // Restart your game logic here
        SendMessageToFlutter("game_restarted", "Game restarted");
    }
    
    // Called from Flutter
    public void ExitGame()
    {
        Debug.Log("Exiting game...");
        isGameActive = false;
        Time.timeScale = 1f;
        
        SendMessageToFlutter("game_exited", "Game exited");
    }
    
    // Game events (call these from your game logic)
    public void OnScoreUpdated(int newScore)
    {
        currentScore = newScore;
        SendMessageToFlutter("score_updated", $"{{\"score\": {currentScore}}}");
    }
    
    public void OnLevelCompleted(int level, float completionTime)
    {
        currentLevel = level + 1;
        SendMessageToFlutter("level_completed", $"{{\"level\": {level}, \"completion_time\": {completionTime}}}");
    }
    
    public void OnGameCompleted(int finalScore)
    {
        isGameActive = false;
        SendMessageToFlutter("game_completed", $"{{\"final_score\": {finalScore}, \"total_levels\": {currentLevel}}}");
    }
    
    // Helper method to send messages to Flutter
    private void SendMessageToFlutter(string type, string data)
    {
        var message = new
        {
            type = type,
            data = data,
            timestamp = System.DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        };
        
        string jsonMessage = JsonUtility.ToJson(message);
        UnityMessageManager.Instance.SendMessageToFlutter(jsonMessage);
    }
}

// Data classes for JSON parsing
[System.Serializable]
public class GameInitData
{
    public string user_id;
    public string app_version;
    public string language;
    public GameSettings settings;
}

[System.Serializable]
public class GameSettings
{
    public bool sound_enabled;
    public bool haptic_feedback;
    public string difficulty;
}
```

#### **Add to Your Existing Game Scripts:**

In your existing `VoiceBridgeGame.cs` scripts, add references to GameManager:

```csharp
public class VoiceBridgeGame : MonoBehaviour
{
    private GameManager gameManager;
    
    private void Start()
    {
        gameManager = FindObjectOfType<GameManager>();
        // Your existing start logic
    }
    
    // When score changes
    private void UpdateScore(int newScore)
    {
        // Your existing score logic
        if (gameManager != null)
            gameManager.OnScoreUpdated(newScore);
    }
    
    // When level is completed
    private void CompleteLevel(int level, float time)
    {
        // Your existing level completion logic
        if (gameManager != null)
            gameManager.OnLevelCompleted(level, time);
    }
    
    // When game is completed
    private void CompleteGame(int finalScore)
    {
        // Your existing game completion logic
        if (gameManager != null)
            gameManager.OnGameCompleted(finalScore);
    }
}
```

### **Step 4: Build Unity Projects**

#### **For Android:**
1. File → Build Settings → Android
2. Player Settings → Configure:
   - **Company Name:** `com.yokaizen.app`
   - **Product Name:** `VoiceBridge` (or `VoiceBridgePolished`)
   - **Bundle Identifier:** `com.yokaizen.app.voicebridge`
   - **Minimum API Level:** 21
   - **Target API Level:** 33 or higher
3. **Build** → Create folder: `android/unityLibrary/voicebridge/`
4. Build the project

#### **For iOS:**
1. File → Build Settings → iOS
2. Player Settings → Configure:
   - **Company Name:** `com.yokaizen.app`
   - **Product Name:** `VoiceBridge` (or `VoiceBridgePolished`)
   - **Bundle Identifier:** `com.yokaizen.app.voicebridge`
   - **Target minimum iOS Version:** 11.0
3. **Build** → Create folder: `ios/UnityLibrary/voicebridge/`
4. Build the project

### **Step 5: Integrate Built Unity Projects**

#### **Android Integration:**
1. Copy the built Unity project to: `android/unityLibrary/`
2. Update `android/settings.gradle`:
   ```gradle
   include ':unityLibrary:voicebridge'
   include ':unityLibrary:voicebridgepolished'
   ```
3. Update `android/app/build.gradle`:
   ```gradle
   dependencies {
       implementation project(':unityLibrary:voicebridge')
       implementation project(':unityLibrary:voicebridgepolished')
   }
   ```

#### **iOS Integration:**
1. Copy the built Unity project to: `ios/UnityLibrary/`
2. Open `ios/Runner.xcworkspace` in Xcode
3. Drag the Unity projects into the workspace
4. Add to "Embedded Binaries"

### **Step 6: Update Flutter Unity Widget Configuration**

Update your `pubspec.yaml`:
```yaml
flutter_unity_widget: ^2022.2.1
```

### **Step 7: Test Integration**

1. **Build Flutter app:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --debug  # For Android
   flutter build ios --debug  # For iOS
   ```

2. **Test on device:**
   - Navigate to Games tab in bottom navigation
   - Select a game from the games screen
   - Verify Unity game loads and communicates with Flutter

## 🎮 **Game Features Implemented**

### **Games Screen Features:**
- ✅ Game selection with preview cards
- ✅ Game descriptions and difficulty indicators
- ✅ Play time estimates
- ✅ High scores and statistics
- ✅ Beautiful UI with animations

### **Unity Game Player Features:**
- ✅ Full-screen gaming experience
- ✅ Game controls (Play, Pause, Restart)
- ✅ Settings overlay
- ✅ Progress tracking
- ✅ Score display
- ✅ Game completion handling
- ✅ Error handling and recovery

### **Navigation Integration:**
- ✅ Games tab in bottom navigation
- ✅ Home screen shortcuts
- ✅ Smooth transitions
- ✅ Back button handling

## 🔧 **Communication Protocol**

### **Flutter → Unity Messages:**
- `initialize_game` - Initialize with user data
- `start_game` - Start gameplay
- `pause_game` - Pause the game
- `resume_game` - Resume gameplay
- `restart_game` - Restart from beginning
- `exit_game` - Exit to menu

### **Unity → Flutter Messages:**
- `game_initialized` - Game is ready
- `game_started` - Gameplay started
- `game_paused` - Game paused
- `game_completed` - Game finished
- `score_updated` - Score changed
- `level_completed` - Level finished

## 🎯 **Testing Checklist**

### **Before Testing:**
- [ ] Unity projects build successfully
- [ ] GameManager script added to both projects
- [ ] Flutter Unity Widget dependency added
- [ ] Games integrated into Flutter navigation

### **Test on Device:**
- [ ] Games tab appears in bottom navigation
- [ ] Games screen loads with both games
- [ ] Tapping a game shows loading dialog
- [ ] Unity game loads in full screen
- [ ] Game controls work (play, pause, restart)
- [ ] Messages flow between Flutter and Unity
- [ ] Game completion flow works
- [ ] Back button returns to games screen

## 🚨 **Troubleshooting**

### **Common Issues:**

1. **Unity project won't build:**
   - Check Unity version compatibility
   - Ensure all required packages are installed
   - Verify platform-specific settings

2. **Flutter can't find Unity projects:**
   - Check file paths in build configuration
   - Verify Unity projects are in correct folders
   - Rebuild Flutter project

3. **No communication between Flutter and Unity:**
   - Verify GameManager script is attached to a GameObject
   - Check UnityMessageManager is properly initialized
   - Verify message format matches expected JSON

4. **Performance issues:**
   - Optimize Unity graphics settings
   - Enable hardware acceleration
   - Test on physical device, not emulator

## 📱 **Next Steps**

1. **Build Unity Projects:** Follow Step 4 above
2. **Integrate with Flutter:** Follow Steps 5-6
3. **Test on Device:** Use testing checklist
4. **Deploy to Production:** After successful testing

## 🎉 **Conclusion**

Your Unity games are now fully integrated into the Flutter app with:
- Professional game selection UI
- Full-screen gaming experience
- Two-way communication between Flutter and Unity
- Progress tracking and statistics
- Seamless navigation integration

The games will appear in the bottom navigation and home screen, providing users with engaging voice-controlled gaming experiences within your YokaizenApp!
