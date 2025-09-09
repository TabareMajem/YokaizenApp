import 'package:flutter/material.dart';
import '../models/audio_asset.dart';
import 'audio_library_manager.dart';

class AudioSelectionDialog extends StatefulWidget {
  final String title;
  final AudioType audioType;
  final String? currentAudioId;
  final Function(AudioAsset?) onSelectAudio;

  const AudioSelectionDialog({
    Key? key,
    required this.title,
    required this.audioType,
    this.currentAudioId,
    required this.onSelectAudio,
  }) : super(key: key);

  @override
  _AudioSelectionDialogState createState() => _AudioSelectionDialogState();
}

class _AudioSelectionDialogState extends State<AudioSelectionDialog> {
  AudioAsset? _selectedAudio;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const Divider(),
            
            // Audio library
            Expanded(
              child: AudioLibraryManager(
                audioType: widget.audioType,
                currentAudioId: widget.currentAudioId ?? '',
                onSelectAudio: (audio) {
                  setState(() {
                    _selectedAudio = audio;
                  });
                },
              ),
            ),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onSelectAudio(null);
                    Navigator.of(context).pop();
                  },
                  child: const Text('No Audio'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _selectedAudio != null
                      ? () {
                          widget.onSelectAudio(_selectedAudio);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
