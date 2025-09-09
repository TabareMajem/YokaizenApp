# Integration Guide For Existing "Yokaizen" System

This guide outlines how to integrate the interactive content creation wizard with your existing Flutter app, admin panel, and Flask API.

## System Architecture Overview

### Current System
```
┌─────────────────┐     ┌──────────────┐     ┌────────────────────┐
│  Yokaizen App   │◄───►│   Flask API   │◄───►│  Admin Panel       │
│  (Flutter)      │     │               │     │  (Flutter)         │
└─────────────────┘     └──────────────┘     └────────────────────┘
```

### Enhanced System with Interactive Content Wizard
```
┌─────────────────┐     ┌────────────────────────────┐     ┌───────────────────────────┐
│  Yokaizen App   │◄───►│         Flask API          │◄───►│  Admin Panel               │
│  (Flutter)      │     │  +Content Endpoints        │     │  +Interactive Content      │
│  +Flame Engine  │     │  +Storage Management       │     │   Creation Wizard          │
│  +Jenny Dialog  │     │  +Audio API Integration    │     │                            │
└─────────────────┘     └────────────────────────────┘     └───────────────────────────┘
```

## 1. Integration with Existing Admin Panel

The interactive content creation wizard should be integrated as a new module within your existing admin panel. This approach preserves your authentication system, user management, and other admin functionality.

### Admin Panel Integration Steps

1. **Add New Module Route**
   - Add a new route/page in your admin panel for the content creator
   - Create navigation links in your existing sidebar/menu

2. **Import Content Creator Components**
   - Add the content creator widgets as a sub-module
   - Ensure state management compatibility (Provider, Bloc, etc.)

3. **Share Authentication/User Context**
   - Leverage existing authentication to manage permissions
   - Track content ownership based on existing user system

### Code Example: Admin Panel Module Integration

```dart
// In your admin_panel_navigation.dart or similar file
ListTile(
  leading: const Icon(Icons.auto_stories),
  title: const Text('Interactive Content'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentCreatorScreen(
          user: currentUser,  // Pass your existing auth context
          apiBaseUrl: yourApiBaseUrl,  // Use your existing API settings
        ),
      ),
    );
  },
),
```

## 2. Flask API Enhancements

Your Flask API will need new endpoints to manage the interactive content, assets, and deployment processes.

### Required API Endpoints

1. **Content Management**
   - `GET /api/content` - List all content modules
   - `GET /api/content/{id}` - Get specific content details
   - `POST /api/content` - Create new content module
   - `PUT /api/content/{id}` - Update content module
   - `DELETE /api/content/{id}` - Delete content module

2. **Asset Management**
   - `POST /api/assets/upload` - Upload images, audio, etc.
   - `GET /api/assets` - List assets (with filtering)
   - `DELETE /api/assets/{id}` - Delete an asset

3. **Audio Integration**
   - `GET /api/audio/search` - Search across audio libraries
   - `GET /api/audio/{source}/{id}` - Get specific audio details

4. **Deployment**
   - `POST /api/deploy/{content_id}` - Deploy content to app
   - `GET /api/deploy/status/{deploy_id}` - Check deployment status

### Flask API Implementation Example

```python
# In your Flask app (app.py or similar)
from flask import Flask, request, jsonify
import os
import json
from werkzeug.utils import secure_filename
from your_existing_auth import auth_required

app = Flask(__name__)

# Content management endpoints
@app.route('/api/content', methods=['GET'])
@auth_required
def list_content():
    # Query your database for content modules
    # Filter by user permissions if needed
    return jsonify({"content": content_list})

@app.route('/api/content', methods=['POST'])
@auth_required
def create_content():
    data = request.json
    # Validate content structure
    # Store in your database
    # Generate any necessary files
    return jsonify({"id": new_content_id, "status": "created"})

# Asset management endpoints
@app.route('/api/assets/upload', methods=['POST'])
@auth_required
def upload_asset():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
        
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
        
    if file:
        filename = secure_filename(file.filename)
        asset_type = request.form.get('type', 'image')
        tags = request.form.get('tags', '').split(',')
        
        # Save file to appropriate location
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], asset_type, filename)
        file.save(file_path)
        
        # Store metadata in database
        asset_id = save_asset_metadata(filename, file_path, asset_type, tags)
        
        return jsonify({
            "id": asset_id,
            "name": filename,
            "url": f"/assets/{asset_type}/{filename}",
            "type": asset_type,
            "tags": tags
        })

# Audio integration endpoints
@app.route('/api/audio/search', methods=['GET'])
def search_audio():
    query = request.args.get('q', '')
    source = request.args.get('source', 'all')
    audio_type = request.args.get('type', 'all')
    
    # Implement API calls to the various audio services
    # Or use your own audio library
    
    return jsonify({"results": audio_results})

# Deployment endpoints
@app.route('/api/deploy/<content_id>', methods=['POST'])
@auth_required
def deploy_content(content_id):
    # Get content from database
    # Package for app consumption
    # Store deployment record
    return jsonify({"deploy_id": deploy_id, "status": "deploying"})
```

## 3. Yokaizen App Integration

Your Yokaizen app needs to be enhanced to render and interact with the created content. This involves integrating the Flame Engine and Jenny dialogue system.

### App Integration Steps

1. **Add Dependencies**
   ```yaml
   dependencies:
     flame: ^1.8.0
     jenny: ^1.0.0
     just_audio: ^0.9.34
   ```

2. **Create Content Renderer Module**
   - Add a dedicated section in your app for interactive content
   - Implement content type detection and appropriate rendering

3. **Content Fetching**
   - Add API calls to fetch latest content from your backend
   - Implement caching for offline access if needed

### Code Example: Content Renderer in Yokaizen App

```dart
// In your Yokaizen app
class InteractiveContentScreen extends StatefulWidget {
  final String contentId;
  
  const InteractiveContentScreen({Key? key, required this.contentId}) : super(key: key);
  
  @override
  _InteractiveContentScreenState createState() => _InteractiveContentScreenState();
}

class _InteractiveContentScreenState extends State<InteractiveContentScreen> {
  late ContentModule _content;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadContent();
  }
  
  Future<void> _loadContent() async {
    try {
      // Fetch content from your API
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/content/${widget.contentId}'),
        headers: {'Authorization': 'Bearer $userToken'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Determine content type and create appropriate module
        final contentType = data['content_type'];
        
        switch (contentType) {
          case 'story':
            _content = StoryModule.fromJson(data);
            break;
          case 'game':
            _content = GameModule.fromJson(data);
            break;
          case 'cbt_exercise':
            _content = CBTExerciseModule.fromJson(data);
            break;
          case 'quiz':
            _content = QuizModule.fromJson(data);
            break;
          default:
            throw Exception('Unknown content type: $contentType');
        }
        
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load content: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading content: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(_errorMessage!)),
      );
    }
    
    // Render appropriate content based on type
    switch (_content.runtimeType) {
      case StoryModule:
        return StoryRenderer(module: _content as StoryModule);
      case GameModule:
        return GameRenderer(module: _content as GameModule);
      case CBTExerciseModule:
        return ExerciseRenderer(module: _content as CBTExerciseModule);
      case QuizModule:
        return QuizRenderer(module: _content as QuizModule);
      default:
        return const Scaffold(
          body: Center(child: Text('Unknown content type')),
        );
    }
  }
}
```

## 4. Content Format Standards

To ensure compatibility between your content creator, API, and app, establish standard formats for each content type.

### JSON Schema Examples

#### Story/Visual Novel
```json
{
  "id": "story_12345",
  "title": "Journey to Self-Discovery",
  "type": "story",
  "version": "1.0.0",
  "characters": [
    {
      "id": "char_1",
      "name": "Aya",
      "expressions": {
        "neutral": "aya_neutral.png",
        "happy": "aya_happy.png"
      }
    }
  ],
  "scenes": [
    {
      "id": "scene_1",
      "name": "Bedroom",
      "background": "bedroom.png",
      "backgroundMusic": "peaceful_morning.mp3"
    }
  ],
  "nodes": [
    {
      "id": "start",
      "scene": "scene_1",
      "character": "char_1",
      "expression": "neutral",
      "text": "Today is a new day...",
      "choices": [
        {
          "text": "I'm feeling optimistic",
          "target": "node_2"
        }
      ]
    }
  ]
}
```

#### Mini-Game
```json
{
  "id": "game_789",
  "title": "Task Dash",
  "type": "game",
  "gameType": "taskDash",
  "backgroundMusic": "upbeat_motivation.mp3",
  "difficulty": "medium",
  "environment": {
    "background": "office_space.png",
    "gravity": 9.8,
    "speed": 5.0
  },
  "character": {
    "sprite": "player.png",
    "jumpHeight": 5.0,
    "speed": 5.0
  },
  "obstacles": [
    {
      "type": "distraction",
      "sprite": "social_media.png",
      "speed": 3.0,
      "spawnRate": 2.0
    }
  ],
  "collectibles": [
    {
      "type": "task",
      "sprite": "task_token.png",
      "value": 10
    }
  ]
}
```

## 5. Database Schema Updates

Your existing database will need new tables to store content modules, assets, and deployment records.

### Example Database Schema

```sql
-- Content modules table
CREATE TABLE content_modules (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    content_type VARCHAR(20) NOT NULL,
    data JSONB NOT NULL,
    creator_id INT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version VARCHAR(20) NOT NULL DEFAULT '1.0.0',
    status VARCHAR(20) NOT NULL DEFAULT 'draft'
);

-- Assets table
CREATE TABLE assets (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    asset_type VARCHAR(20) NOT NULL,
    mime_type VARCHAR(50) NOT NULL,
    size INT NOT NULL,
    tags TEXT[], 
    uploader_id INT NOT NULL REFERENCES users(id),
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Deployments table
CREATE TABLE deployments (
    id VARCHAR(50) PRIMARY KEY,
    content_id VARCHAR(50) NOT NULL REFERENCES content_modules(id),
    version VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    deployed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deployed_by INT NOT NULL REFERENCES users(id)
);
```

## 6. Implementation Phases

To integrate this system effectively, follow these implementation phases:

### Phase 1: API Extensions
1. Add content management endpoints to Flask API
2. Implement asset storage and management
3. Create deployment mechanism

### Phase 2: Admin Panel Integration
1. Add interactive content section to admin panel
2. Implement basic story/visual novel editor
3. Add asset management UI

### Phase 3: App Rendering
1. Add Flame and Jenny to Yokaizen app
2. Implement story/visual novel renderer
3. Add content browsing and selection UI

### Phase 4: Advanced Content Types
1. Add mini-game creator to admin panel
2. Implement game renderer in app
3. Add CBT exercises and quiz creators

### Phase 5: Audio Integration
1. Implement audio API integrations
2. Add audio library to admin panel
3. Implement audio playback in app

## 7. Testing Strategy

Implement a comprehensive testing strategy to ensure all components work together:

1. **API Testing**
   - Test all endpoints with various input scenarios
   - Verify proper error handling and validation

2. **Admin Panel Testing**
   - Test content creation workflow end-to-end
   - Verify asset management functionality

3. **App Testing**
   - Test content rendering for all types
   - Verify audio playback functionality
   - Test offline capabilities if implemented

4. **Integration Testing**
   - Test complete workflow from creation to deployment to rendering
   - Verify content updates and versioning

## 8. Performance Considerations

As you integrate these new features, pay attention to:

1. **Asset Optimization**
   - Implement image compression
   - Optimize audio files for mobile use
   - Consider content delivery network (CDN) for assets

2. **Mobile Performance**
   - Ensure game performance is smooth on target devices
   - Implement asset preloading for smoother transitions

3. **API Efficiency**
   - Use pagination for asset and content listings
   - Implement request caching where appropriate

## Conclusion

This integration approach allows you to enhance your existing Yokaizen system with interactive content creation and rendering while preserving your current infrastructure. By following the phased implementation approach, you can gradually add these capabilities without disrupting existing functionality.
