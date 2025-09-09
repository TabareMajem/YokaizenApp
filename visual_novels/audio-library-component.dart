import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/admin_state.dart';
import '../models/audio_asset.dart';

class AudioLibraryManager extends StatefulWidget {
  final Function(AudioAsset) onSelectAudio;
  final String currentAudioId;
  final AudioType audioType;

  const AudioLibraryManager({
    Key? key,
    required this.onSelectAudio,
    required this.currentAudioId,
    required this.audioType,
  }) : super(key: key);

  @override
  _AudioLibraryManagerState createState() => _AudioLibraryManagerState();
}

class _AudioLibraryManagerState extends State<AudioLibraryManager> {
  bool _isLoading = true;
  String _searchQuery = '';
  List<AudioAsset> _audioAssets = [];
  List<AudioAsset> _filteredAssets = [];
  AudioAsset? _previewingAsset;
  bool _isPlaying = false;
  String? _errorMessage;

  // AudioSource categories
  final List<String> _audioSources = [
    'All Sources',
    'Freesound',
    'MusOpen',
    'CC Mixter',
    'Free Music Archive',
    'Uploaded Assets',
  ];
  String _selectedSource = 'All Sources';

  @override
  void initState() {
    super.initState();
    _loadAudioAssets();
  }

  @override
  void dispose() {
    // Stop any playing audio
    _stopAudioPreview();
    super.dispose();
  }

  Future<void> _loadAudioAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real implementation, this would call your backend API
      // For now, we'll use a fake delay and mock data
      await Future.delayed(const Duration(seconds: 1));
      
      // Filter type based on widget.audioType
      final typeFilter = widget.audioType == AudioType.music 
          ? 'music' 
          : 'sound_effect';
      
      // Load assets from AdminState or API
      _audioAssets = _getMockAudioAssets().where((asset) => asset.type == typeFilter).toList();
      _applyFilters();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load audio library: $e';
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAssets = _audioAssets.where((asset) {
        // Apply search filter
        final matchesSearch = asset.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             asset.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
        
        // Apply source filter
        final matchesSource = _selectedSource == 'All Sources' || asset.source == _selectedSource;
        
        return matchesSearch && matchesSource;
      }).toList();
    });
  }

  Future<void> _playAudioPreview(AudioAsset asset) async {
    // Stop currently playing audio if any
    if (_isPlaying) {
      await _stopAudioPreview();
    }
    
    setState(() {
      _previewingAsset = asset;
      _isPlaying = true;
    });
    
    // In a real implementation, this would use AudioPlayer or similar
    // For now, we'll just simulate playing with a delay
    await Future.delayed(const Duration(seconds: 3));
    
    // Auto-stop after preview duration
    if (mounted && _isPlaying && _previewingAsset?.id == asset.id) {
      setState(() {
        _isPlaying = false;
        _previewingAsset = null;
      });
    }
  }

  Future<void> _stopAudioPreview() async {
    // In a real implementation, this would stop the AudioPlayer
    setState(() {
      _isPlaying = false;
      _previewingAsset = null;
    });
  }

  Future<void> _uploadNewAudio() async {
    // This would open a file picker in a real implementation
    // For now, we'll just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File upload would be implemented here'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.audioType == AudioType.music 
                ? 'Background Music Library' 
                : 'Sound Effects Library',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 16),
          
          // Search and filters row
          Row(
            children: [
              // Search box
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by name or tag...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Source filter dropdown
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Source',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSource,
                  items: _audioSources.map((source) {
                    return DropdownMenuItem<String>(
                      value: source,
                      child: Text(source),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSource = value;
                      });
                      _applyFilters();
                    }
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Upload button
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload'),
                onPressed: _uploadNewAudio,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Audio assets grid/list
          Expanded(
            child: _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredAssets.isEmpty
                        ? const Center(child: Text('No audio assets found matching your search'))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: _filteredAssets.length,
                            itemBuilder: (context, index) {
                              final asset = _filteredAssets[index];
                              final isSelected = asset.id == widget.currentAudioId;
                              final isPlaying = _isPlaying && _previewingAsset?.id == asset.id;
                              
                              return Card(
                                color: isSelected ? Colors.blue.shade100 : null,
                                child: InkWell(
                                  onTap: () => widget.onSelectAudio(asset),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        // Play/Stop button
                                        IconButton(
                                          icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                                          onPressed: isPlaying
                                              ? _stopAudioPreview
                                              : () => _playAudioPreview(asset),
                                        ),
                                        
                                        // Audio info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                asset.title,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Source: ${asset.source} | Duration: ${asset.duration}s',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              Row(
                                                children: asset.tags.take(3).map((tag) {
                                                  return Container(
                                                    margin: const EdgeInsets.only(right: 4, top: 4),
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade200,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      tag,
                                                      style: const TextStyle(fontSize: 10),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // License info
                                        Tooltip(
                                          message: 'License: ${asset.license}',
                                          child: const Icon(Icons.info_outline, size: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
  
  // Mock data for development - this would be replaced by API calls
  List<AudioAsset> _getMockAudioAssets() {
    return [
      AudioAsset(
        id: 'bgm1',
        title: 'Peaceful Ambience',
        url: 'https://example.com/peaceful_ambience.mp3',
        type: 'music',
        duration: 120,
        source: 'Free Music Archive',
        license: 'CC BY',
        tags: ['peaceful', 'ambient', 'background'],
      ),
      AudioAsset(
        id: 'bgm2',
        title: 'Upbeat Adventure',
        url: 'https://example.com/upbeat_adventure.mp3',
        type: 'music',
        duration: 95,
        source: 'MusOpen',
        license: 'CC BY-SA',
        tags: ['upbeat', 'adventure', 'energetic'],
      ),
      AudioAsset(
        id: 'bgm3',
        title: 'Mysterious Tension',
        url: 'https://example.com/mysterious_tension.mp3',
        type: 'music',
        duration: 105,
        source: 'CC Mixter',
        license: 'CC BY-NC',
        tags: ['mysterious', 'tension', 'suspense'],
      ),
      AudioAsset(
        id: 'sfx1',
        title: 'Button Click',
        url: 'https://example.com/button_click.mp3',
        type: 'sound_effect',
        duration: 1,
        source: 'Freesound',
        license: 'CC0',
        tags: ['ui', 'click', 'button'],
      ),
      AudioAsset(
        id: 'sfx2',
        title: 'Success Chime',
        url: 'https://example.com/success_chime.mp3',
        type: 'sound_effect',
        duration: 2,
        source: 'Freesound',
        license: 'CC BY',
        tags: ['success', 'achievement', 'positive'],
      ),
      AudioAsset(
        id: 'sfx3',
        title: 'Error Buzz',
        url: 'https://example.com/error_buzz.mp3',
        type: 'sound_effect',
        duration: 1,
        source: 'Freesound',
        license: 'CC0',
        tags: ['error', 'negative', 'buzz'],
      ),
      AudioAsset(
        id: 'bgm4',
        title: 'Reflective Piano',
        url: 'https://example.com/reflective_piano.mp3',
        type: 'music',
        duration: 180,
        source: 'Uploaded Assets',
        license: 'Custom',
        tags: ['piano', 'reflective', 'calm'],
      ),
      AudioAsset(
        id: 'sfx4',
        title: 'Page Turn',
        url: 'https://example.com/page_turn.mp3',
        type: 'sound_effect',
        duration: 1,
        source: 'Uploaded Assets',
        license: 'Custom',
        tags: ['page', 'turn', 'book'],
      ),
    ];
  }
}
