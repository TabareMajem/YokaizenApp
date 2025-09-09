import 'package:flutter/material.dart';
import 'story_module.dart';
import 'character.dart';
import 'scene.dart';
import 'dialogue_node.dart';

class AdminState extends ChangeNotifier {
  StoryModule _storyModule = StoryModule(
    id: '',
    title: '',
    description: '',
    author: '',
    version: '1.0.0',
    category: 'self_esteem',
    difficulty: 'medium',
    estimatedDuration: 20,
    characters: [],
    scenes: [],
    nodes: [],
    stats: [
      Stat(id: 'authenticity', name: 'Authenticity', icon: 'heart'),
      Stat(id: 'confidence', name: 'Confidence', icon: 'star'),
      Stat(id: 'resilience', name: 'Resilience', icon: 'shield'),
      Stat(id: 'selfEsteem', name: 'Self-Esteem', icon: 'trending_up'),
    ],
  );
  
  // Active item trackers for editing
  Character? _activeCharacter;
  Scene? _activeScene;
  DialogueNode? _activeNode;
  
  // Preview state
  bool _isPreviewMode = false;
  
  // Asset library (cached for reuse)
  List<Character> _characterTemplates = [];
  List<Scene> _sceneTemplates = [];
  List<DialogueNode> _nodeTemplates = [];

  // Getters
  StoryModule get storyModule => _storyModule;
  Character? get activeCharacter => _activeCharacter;
  Scene? get activeScene => _activeScene;
  DialogueNode? get activeNode => _activeNode;
  bool get isPreviewMode => _isPreviewMode;
  List<Character> get characterTemplates => _characterTemplates;
  List<Scene> get sceneTemplates => _sceneTemplates;
  List<DialogueNode> get nodeTemplates => _nodeTemplates;
  
  // Story Module Methods
  void updateStoryInfo({
    String? title,
    String? description,
    String? author,
    String? version,
    String? category,
    String? difficulty,
    int? estimatedDuration,
  }) {
    _storyModule = _storyModule.copyWith(
      title: title,
      description: description,
      author: author,
      version: version,
      category: category,
      difficulty: difficulty,
      estimatedDuration: estimatedDuration,
    );
    notifyListeners();
  }
  
  // Character Methods
  void addCharacter(Character character) {
    final characters = List<Character>.from(_storyModule.characters);
    characters.add(character);
    _storyModule = _storyModule.copyWith(characters: characters);
    notifyListeners();
  }
  
  void updateCharacter(Character updatedCharacter) {
    final characters = List<Character>.from(_storyModule.characters);
    final index = characters.indexWhere((c) => c.id == updatedCharacter.id);
    
    if (index != -1) {
      characters[index] = updatedCharacter;
      _storyModule = _storyModule.copyWith(characters: characters);
      
      if (_activeCharacter?.id == updatedCharacter.id) {
        _activeCharacter = updatedCharacter;
      }
      
      notifyListeners();
    }
  }
  
  void removeCharacter(String characterId) {
    final characters = List<Character>.from(_storyModule.characters);
    characters.removeWhere((c) => c.id == characterId);
    _storyModule = _storyModule.copyWith(characters: characters);
    
    if (_activeCharacter?.id == characterId) {
      _activeCharacter = null;
    }
    
    notifyListeners();
  }
  
  void setActiveCharacter(Character? character) {
    _activeCharacter = character;
    notifyListeners();
  }
  
  // Scene Methods
  void addScene(Scene scene) {
    final scenes = List<Scene>.from(_storyModule.scenes);
    scenes.add(scene);
    _storyModule = _storyModule.copyWith(scenes: scenes);
    notifyListeners();
  }
  
  void updateScene(Scene updatedScene) {
    final scenes = List<Scene>.from(_storyModule.scenes);
    final index = scenes.indexWhere((s) => s.id == updatedScene.id);
    
    if (index != -1) {
      scenes[index] = updatedScene;
      _storyModule = _storyModule.copyWith(scenes: scenes);
      
      if (_activeScene?.id == updatedScene.id) {
        _activeScene = updatedScene;
      }
      
      notifyListeners();
    }
  }
  
  void removeScene(String sceneId) {
    final scenes = List<Scene>.from(_storyModule.scenes);
    scenes.removeWhere((s) => s.id == sceneId);
    _storyModule = _storyModule.copyWith(scenes: scenes);
    
    if (_activeScene?.id == sceneId) {
      _activeScene = null;
    }
    
    notifyListeners();
  }
  
  void setActiveScene(Scene? scene) {
    _activeScene = scene;
    notifyListeners();
  }
  
  // Dialogue Node Methods
  void addNode(DialogueNode node) {
    final nodes = List<DialogueNode>.from(_storyModule.nodes);
    nodes.add(node);
    _storyModule = _storyModule.copyWith(nodes: nodes);
    notifyListeners();
  }
  
  void updateNode(DialogueNode updatedNode) {
    final nodes = List<DialogueNode>.from(_storyModule.nodes);
    final index = nodes.indexWhere((n) => n.id == updatedNode.id);
    
    if (index != -1) {
      nodes[index] = updatedNode;
      _storyModule = _storyModule.copyWith(nodes: nodes);
      
      if (_activeNode?.id == updatedNode.id) {
        _activeNode = updatedNode;
      }
      
      notifyListeners();
    }
  }
  
  void removeNode(String nodeId) {
    final nodes = List<DialogueNode>.from(_storyModule.nodes);
    nodes.removeWhere((n) => n.id == nodeId);
    _storyModule = _storyModule.copyWith(nodes: nodes);
    
    if (_activeNode?.id == nodeId) {
      _activeNode = null;
    }
    
    notifyListeners();
  }
  
  void setActiveNode(DialogueNode? node) {
    _activeNode = node;
    notifyListeners();
  }
  
  // Preview Methods
  void togglePreviewMode() {
    _isPreviewMode = !_isPreviewMode;
    notifyListeners();
  }
  
  // Template Methods
  Future<void> loadTemplates() async {
    // This would normally load from a service or local storage
    // For now, we'll just set some sample templates
    _characterTemplates = [
      Character(
        id: 'template_protagonist',
        name: 'Protagonist',
        description: 'Main character template',
        expressions: {
          'neutral': 'character_neutral.png',
          'happy': 'character_happy.png',
          'sad': 'character_sad.png',
        },
      ),
      Character(
        id: 'template_mentor',
        name: 'Mentor',
        description: 'Wise guide character template',
        expressions: {
          'neutral': 'mentor_neutral.png',
          'happy': 'mentor_happy.png',
        },
      ),
    ];
    
    _sceneTemplates = [
      Scene(
        id: 'template_bedroom',
        name: 'Bedroom',
        description: 'Character\'s personal space',
        imagePath: 'bedroom.png',
      ),
      Scene(
        id: 'template_park',
        name: 'Park',
        description: 'Peaceful outdoor setting',
        imagePath: 'park.png',
      ),
    ];
    
    notifyListeners();
  }
  
  // Reset the entire state
  void resetState() {
    _storyModule = StoryModule(
      id: '',
      title: '',
      description: '',
      author: '',
      version: '1.0.0',
      category: 'self_esteem',
      difficulty: 'medium',
      estimatedDuration: 20,
      characters: [],
      scenes: [],
      nodes: [],
      stats: [
        Stat(id: 'authenticity', name: 'Authenticity', icon: 'heart'),
        Stat(id: 'confidence', name: 'Confidence', icon: 'star'),
        Stat(id: 'resilience', name: 'Resilience', icon: 'shield'),
        Stat(id: 'selfEsteem', name: 'Self-Esteem', icon: 'trending_up'),
      ],
    );
    
    _activeCharacter = null;
    _activeScene = null;
    _activeNode = null;
    _isPreviewMode = false;
    
    notifyListeners();
  }
}
