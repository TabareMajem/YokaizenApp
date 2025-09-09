import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/dialogue_node.dart';
import '../models/character.dart';
import '../models/scene.dart';
import '../models/story_module.dart';

class NodeEditorDialog extends StatefulWidget {
  final DialogueNode node;
  final List<Character> characters;
  final List<Scene> scenes;
  final List<Stat> stats;
  final List<DialogueNode> allNodes;
  final Function(DialogueNode) onSave;
  
  const NodeEditorDialog({
    Key? key,
    required this.node,
    required this.characters,
    required this.scenes,
    required this.stats,
    required this.allNodes,
    required this.onSave,
  }) : super(key: key);

  @override
  _NodeEditorDialogState createState() => _NodeEditorDialogState();
}

class _NodeEditorDialogState extends State<NodeEditorDialog> with SingleTickerProviderStateMixin {
  late DialogueNode _editedNode;
  final Uuid _uuid = const Uuid();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _editedNode = widget.node;
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Editing Node: ${_editedNode.title}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            // Node title editor
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                initialValue: _editedNode.title,
                decoration: const InputDecoration(
                  labelText: 'Node Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _editedNode = _editedNode.copyWith(title: value);
                  });
                },
              ),
            ),
            
            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Basic Settings'),
                Tab(text: 'Dialogue Lines'),
                Tab(text: 'Choices'),
                Tab(text: 'Stats'),
              ],
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicSettingsTab(),
                  _buildDialogueLinesTab(),
                  _buildChoicesTab(),
                  _buildStatsTab(),
                ],
              ),
            ),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => widget.onSave(_editedNode),
                  child: const Text('Save Node'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBasicSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scene selection
          const Text(
            'Scene Background:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _editedNode.sceneId.isNotEmpty ? _editedNode.sceneId : null,
            decoration: const InputDecoration(
              labelText: 'Select Scene',
              border: OutlineInputBorder(),
            ),
            items: widget.scenes.map((scene) {
              return DropdownMenuItem<String>(
                value: scene.id,
                child: Text(scene.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _editedNode = _editedNode.copyWith(sceneId: value);
                });
              }
            },
          ),
          
          const SizedBox(height: 24),
          
          // Character selection
          const Text(
            'Character:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _editedNode.characterId.isNotEmpty ? _editedNode.characterId : null,
                  decoration: const InputDecoration(
                    labelText: 'Select Character',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.characters.map((character) {
                    return DropdownMenuItem<String>(
                      value: character.id,
                      child: Text(character.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _editedNode = _editedNode.copyWith(characterId: value);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _editedNode.expression,
                  decoration: const InputDecoration(
                    labelText: 'Expression',
                    border: OutlineInputBorder(),
                  ),
                  items: _getExpressionOptions(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _editedNode = _editedNode.copyWith(expression: value);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Preview
          Expanded(
            child: Center(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Preview',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Scene preview
                      if (_editedNode.sceneId.isNotEmpty)
                        Text('Scene: ${_getSceneName(_editedNode.sceneId)}'),
                      const SizedBox(height: 8),
                      // Character preview
                      if (_editedNode.characterId.isNotEmpty)
                        Text('Character: ${_getCharacterName(_editedNode.characterId)} (${_editedNode.expression})'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDialogueLinesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dialogue Lines',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Line'),
                onPressed: _addNewLine,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Lines list
          Expanded(
            child: _editedNode.lines.isEmpty
                ? const Center(child: Text('No dialogue lines yet. Add some!'))
                : ListView.builder(
                    itemCount: _editedNode.lines.length,
                    itemBuilder: (context, index) {
                      final line = _editedNode.lines[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: line.speakerId.isNotEmpty ? line.speakerId : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Speaker',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: [
                                        const DropdownMenuItem<String>(
                                          value: '',
                                          child: Text('Narrator/System'),
                                        ),
                                        ...widget.characters.map((character) {
                                          return DropdownMenuItem<String>(
                                            value: character.id,
                                            child: Text(character.name),
                                          );
                                        }).toList(),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          final updatedLines = List<DialogueLine>.from(_editedNode.lines);
                                          updatedLines[index] = line.copyWith(speakerId: value ?? '');
                                          _editedNode = _editedNode.copyWith(lines: updatedLines);
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeLine(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: line.text,
                                decoration: const InputDecoration(
                                  labelText: 'Dialogue Text',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                onChanged: (value) {
                                  setState(() {
                                    final updatedLines = List<DialogueLine>.from(_editedNode.lines);
                                    updatedLines[index] = line.copyWith(text: value);
                                    _editedNode = _editedNode.copyWith(lines: updatedLines);
                                  });
                                },
                              ),
                            ],
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
  
  Widget _buildChoicesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Player Choices',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Choice'),
                onPressed: _addNewChoice,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Choices list
          Expanded(
            child: _editedNode.choices.isEmpty
                ? const Center(child: Text('No choices yet. Add some for branching dialogue!'))
                : ListView.builder(
                    itemCount: _editedNode.choices.length,
                    itemBuilder: (context, index) {
                      final choice = _editedNode.choices[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: choice.text,
                                      decoration: const InputDecoration(
                                        labelText: 'Choice Text',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          final updatedChoices = List<DialogueChoice>.from(_editedNode.choices);
                                          updatedChoices[index] = choice.copyWith(text: value);
                                          _editedNode = _editedNode.copyWith(choices: updatedChoices);
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeChoice(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: choice.targetNodeId.isNotEmpty ? choice.targetNodeId : null,
                                decoration: const InputDecoration(
                                  labelText: 'Target Node (where this choice leads)',
                                  border: OutlineInputBorder(),
                                ),
                                items: widget.allNodes
                                    .where((node) => node.id != _editedNode.id) // Prevent self-references
                                    .map((node) {
                                  return DropdownMenuItem<String>(
                                    value: node.id,
                                    child: Text(node.title),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      final updatedChoices = List<DialogueChoice>.from(_editedNode.choices);
                                      updatedChoices[index] = choice.copyWith(targetNodeId: value);
                                      _editedNode = _editedNode.copyWith(choices: updatedChoices);
                                    });
                                  }
                                },
                              ),
                            ],
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
  
  Widget _buildStatsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stat Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Stat Change'),
                onPressed: _addNewStatChange,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stat changes list
          Expanded(
            child: _editedNode.statChanges.isEmpty
                ? const Center(child: Text('No stat changes yet. Add some to track player progress!'))
                : ListView.builder(
                    itemCount: _editedNode.statChanges.length,
                    itemBuilder: (context, index) {
                      final statChange = _editedNode.statChanges[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: statChange.statId,
                                  decoration: const InputDecoration(
                                    labelText: 'Stat',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: widget.stats.map((stat) {
                                    return DropdownMenuItem<String>(
                                      value: stat.id,
                                      child: Text(stat.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        final updatedStatChanges = List<StatChange>.from(_editedNode.statChanges);
                                        updatedStatChanges[index] = statChange.copyWith(statId: value);
                                        _editedNode = _editedNode.copyWith(statChanges: updatedStatChanges);
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: statChange.value.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Value Change',
                                    border: OutlineInputBorder(),
                                    hintText: 'e.g., 10, -5',
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(signed: true),
                                  onChanged: (value) {
                                    final intValue = int.tryParse(value) ?? 0;
                                    setState(() {
                                      final updatedStatChanges = List<StatChange>.from(_editedNode.statChanges);
                                      updatedStatChanges[index] = statChange.copyWith(value: intValue);
                                      _editedNode = _editedNode.copyWith(statChanges: updatedStatChanges);
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeStatChange(index),
                              ),
                            ],
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
  
  // Helper methods
  List<DropdownMenuItem<String>> _getExpressionOptions() {
    if (_editedNode.characterId.isEmpty) {
      return [const DropdownMenuItem<String>(value: 'neutral', child: Text('Neutral'))];
    }
    
    final character = widget.characters.firstWhere(
      (c) => c.id == _editedNode.characterId,
      orElse: () => Character(id: '', name: '', description: '', expressions: {'neutral': 'default.png'}),
    );
    
    return character.expressions.keys.map((expression) {
      return DropdownMenuItem<String>(
        value: expression,
        child: Text(expression.substring(0, 1).toUpperCase() + expression.substring(1)),
      );
    }).toList();
  }
  
  String _getSceneName(String sceneId) {
    final scene = widget.scenes.firstWhere(
      (s) => s.id == sceneId,
      orElse: () => Scene(id: '', name: 'Unknown', description: '', imagePath: ''),
    );
    return scene.name;
  }
  
  String _getCharacterName(String characterId) {
    final character = widget.characters.firstWhere(
      (c) => c.id == characterId,
      orElse: () => Character(id: '', name: 'Unknown', description: '', expressions: {}),
    );
    return character.name;
  }
  
  void _addNewLine() {
    setState(() {
      final newLine = DialogueLine(
        id: 'line_${_uuid.v4()}',
        speakerId: _editedNode.characterId.isNotEmpty ? _editedNode.characterId : '',
        text: '',
      );
      
      final updatedLines = List<DialogueLine>.from(_editedNode.lines)..add(newLine);
      _editedNode = _editedNode.copyWith(lines: updatedLines);
    });
  }
  
  void _removeLine(int index) {
    setState(() {
      final updatedLines = List<DialogueLine>.from(_editedNode.lines);
      updatedLines.removeAt(index);
      _editedNode = _editedNode.copyWith(lines: updatedLines);
    });
  }
  
  void _addNewChoice() {
    setState(() {
      final newChoice = DialogueChoice(
        id: 'choice_${_uuid.v4()}',
        text: 'New choice',
        targetNodeId: '',
      );
      
      final updatedChoices = List<DialogueChoice>.from(_editedNode.choices)..add(newChoice);
      _editedNode = _editedNode.copyWith(choices: updatedChoices);
    });
  }
  
  void _removeChoice(int index) {
    setState(() {
      final updatedChoices = List<DialogueChoice>.from(_editedNode.choices);
      updatedChoices.removeAt(index);
      _editedNode = _editedNode.copyWith(choices: updatedChoices);
    });
  }
  
  void _addNewStatChange() {
    if (widget.stats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stats available. Please define stats first.')),
      );
      return;
    }
    
    setState(() {
      final newStatChange = StatChange(
        id: 'stat_change_${_uuid.v4()}',
        statId: widget.stats.first.id,
        value: 5,
      );
      
      final updatedStatChanges = List<StatChange>.from(_editedNode.statChanges)..add(newStatChange);
      _editedNode = _editedNode.copyWith(statChanges: updatedStatChanges);
    });
  }
  
  void _removeStatChange(int index) {
    setState(() {
      final updatedStatChanges = List<StatChange>.from(_editedNode.statChanges);
      updatedStatChanges.removeAt(index);
      _editedNode = _editedNode.copyWith(statChanges: updatedStatChanges);
    });
  }
}

class NodeListView extends StatelessWidget {
  final List<DialogueNode> nodes;
  final Function(DialogueNode) onNodeSelected;
  final String? activeNodeId;
  
  const NodeListView({
    Key? key,
    required this.nodes,
    required this.onNodeSelected,
    this.activeNodeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return nodes.isEmpty
        ? const Center(child: Text('No dialogue nodes yet. Add your first node to get started!'))
        : ListView.builder(
            itemCount: nodes.length,
            itemBuilder: (context, index) {
              final node = nodes[index];
              final isSelected = node.id == activeNodeId;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isSelected ? Colors.blue.shade100 : null,
                child: ListTile(
                  title: Text(node.title),
                  subtitle: Text('${node.lines.length} lines, ${node.choices.length} choices'),
                  selected: isSelected,
                  onTap: () => onNodeSelected(node),
                ),
              );
            },
          );
  }
}
