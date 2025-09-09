import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/story_module.dart';

class ContentApi {
  // API base URL
  final String _baseUrl = 'https://api.example.com/v1'; // Replace with your actual API endpoint
  final String _apiKey = 'your_api_key_here'; // Replace with your actual API key
  final _uuid = const Uuid();
  
  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };
  
  // Get all story modules
  Future<List<StoryModule>> getStoryModules() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stories'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StoryModule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load story modules: ${response.statusCode}');
      }
    } catch (e) {
      // For demo purposes, return mock data if API is not available
      return _getMockStoryModules();
    }
  }
  
  // Get a specific story module
  Future<StoryModule> getStoryModule(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stories/$id'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return StoryModule.fromJson(data);
      } else {
        throw Exception('Failed to load story module: ${response.statusCode}');
      }
    } catch (e) {
      // For demo purposes, return a mock story if API is not available
      final mockStories = _getMockStoryModules();
      return mockStories.firstWhere(
        (story) => story.id == id,
        orElse: () => mockStories.first,
      );
    }
  }
  
  // Deploy (create or update) a story module
  Future<StoryModule> deployStory(StoryModule storyModule) async {
    // If id is empty, create a new UUID for it
    final id = storyModule.id.isEmpty ? _uuid.v4() : storyModule.id;
    final deployModule = storyModule.copyWith(id: id);
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/stories'),
        headers: _headers,
        body: json.encode(deployModule.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        return StoryModule.fromJson(data);
      } else {
        throw Exception('Failed to deploy story module: ${response.statusCode}');
      }
    } catch (e) {
      // For demo purposes, just log the error and return the module as if it succeeded
      print('API error (mock): $e');
      
      // Generate a yarn file and save it locally (simulation)
      _generateYarnFile(deployModule);
      
      // In a real app, you'd handle this error appropriately
      return deployModule;
    }
  }
  
  // Delete a story module
  Future<bool> deleteStoryModule(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/stories/$id'),
        headers: _headers,
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      // For demo purposes, just log the error and return success
      print('API error (mock): $e');
      return true;
    }
  }
  
  // Mock method to simulate generating a Yarn script file
  void _generateYarnFile(StoryModule storyModule) {
    final yarnScript = storyModule.toYarnScript();
    
    // In a real app, you might save this to a file or send it to a server
    print('Generated Yarn script for "${storyModule.title}":');
    print(yarnScript);
  }
  
  // Mock method to get sample story modules for demo
  List<StoryModule> _getMockStoryModules() {
    return [
      StoryModule(
        id: 'sample1',
        title: 'Overcoming Anxiety',
        description: 'A journey through anxiety management techniques',
        author: 'Dr. Emma Johnson',
        version: '1.0.0',
        category: 'anxiety',
        difficulty: 'beginner',
        estimatedDuration: 15,
        characters: [],
        scenes: [],
        nodes: [],
        stats: [
          Stat(id: 'awareness', name: 'Awareness', icon: 'visibility'),
          Stat(id: 'coping', name: 'Coping Skills', icon: 'psychology'),
        ],
      ),
      StoryModule(
        id: 'sample2',
        title: 'Building Confidence',
        description: 'Interactive exercises to build self-confidence',
        author: 'Mark Chen',
        version: '1.2.1',
        category: 'self_esteem',
        difficulty: 'intermediate',
        estimatedDuration: 25,
        characters: [],
        scenes: [],
        nodes: [],
        stats: [
          Stat(id: 'confidence', name: 'Confidence', icon: 'star'),
          Stat(id: 'resilience', name: 'Resilience', icon: 'shield'),
        ],
      ),
    ];
  }
}
