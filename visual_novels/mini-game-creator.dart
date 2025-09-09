import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_module.dart';
import '../models/admin_state.dart';
import 'game_environment_editor.dart';
import 'game_character_editor.dart';
import 'game_obstacle_editor.dart';
import 'game_reward_editor.dart';
import 'game_preview.dart';

class MiniGameCreator extends StatefulWidget {
  const MiniGameCreator({Key? key}) : super(key: key);

  @override
  _MiniGameCreatorState createState() => _MiniGameCreatorState();
}

class _MiniGameCreatorState extends State<MiniGameCreator> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Initialize with default game template if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminState = Provider.of<AdminState>(context, listen: false);
      if (adminState.gameModule == null) {
        adminState.initializeGameModule(GameType.taskDash);
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminState>(
      builder: (context, adminState, _) {
        final gameModule = adminState.gameModule;
        
        if (gameModule == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with game type selector
            _buildHeader(gameModule, adminState),
            
            const SizedBox(height: 16),
            
            // Tab navigation for game editor sections
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Environment', icon: Icon(Icons.landscape)),
                Tab(text: 'Character', icon: Icon(Icons.person)),
                Tab(text: 'Obstacles', icon: Icon(Icons.dangerous)),
                Tab(text: 'Rewards', icon: Icon(Icons.star)),
                Tab(text: 'Preview', icon: Icon(Icons.play_arrow)),
              ],
            ),
            
            // Main content area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  GameEnvironmentEditor(gameModule: gameModule),
                  GameCharacterEditor(gameModule: gameModule),
                  GameObstacleEditor(gameModule: gameModule),
                  GameRewardEditor(gameModule: gameModule),
                  GamePreview(gameModule: gameModule),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildHeader(GameModule gameModule, AdminState adminState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mini-Game Creator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: gameModule.title,
                    decoration: const InputDecoration(
                      labelText: 'Game Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      adminState.updateGameModule(
                        gameModule.copyWith(title: value),
                      );
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: DropdownButtonFormField<GameType>(
                    value: gameModule.gameType,
                    decoration: const InputDecoration(
                      labelText: 'Game Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: GameType.taskDash,
                        child: Text('Task Dash (Procrastination)'),
                      ),
                      DropdownMenuItem(
                        value: GameType.stressEscape,
                        child: Text('Stress Escape (Relaxation)'),
                      ),
                      DropdownMenuItem(
                        value: GameType.confidenceQuest,
                        child: Text('Confidence Quest (Self-Esteem)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        // Show confirmation dialog if changing game type on existing game
                        if (gameModule.gameElements.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Change Game Type?'),
                              content: const Text('Changing the game type will reset your current game elements. Continue?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    adminState.initializeGameModule(value);
                                  },
                                  child: const Text('Continue'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          adminState.initializeGameModule(value);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              initialValue: gameModule.description,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Game Description',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                adminState.updateGameModule(
                  gameModule.copyWith(description: value),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: gameModule.difficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty Level',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'hard', child: Text('Hard')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        adminState.updateGameModule(
                          gameModule.copyWith(difficulty: value),
                        );
                      }
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: TextFormField(
                    initialValue: gameModule.estimatedDuration.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Estimated Duration (seconds)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final duration = int.tryParse(value) ?? 60;
                      adminState.updateGameModule(
                        gameModule.copyWith(estimatedDuration: duration),
                      );
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: gameModule.targetSkill,
                    decoration: const InputDecoration(
                      labelText: 'Target Skill',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'focus', child: Text('Focus')),
                      DropdownMenuItem(value: 'relaxation', child: Text('Relaxation')),
                      DropdownMenuItem(value: 'confidence', child: Text('Confidence')),
                      DropdownMenuItem(value: 'discipline', child: Text('Discipline')),
                      DropdownMenuItem(value: 'self_awareness', child: Text('Self-Awareness')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        adminState.updateGameModule(
                          gameModule.copyWith(targetSkill: value),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GameEnvironmentEditor extends StatelessWidget {
  final GameModule gameModule;
  
  const GameEnvironmentEditor({
    Key? key,
    required this.gameModule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminState>(
      builder: (context, adminState, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Game Environment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 16),
              
              // Environment settings
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - settings
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Background selector
                        const Text('Game Background', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: gameModule.backgroundImage,
                          decoration: const InputDecoration(
                            labelText: 'Select Background',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            'office_space.png',
                            'forest_path.png',
                            'mountain_climb.png',
                            'space_journey.png',
                            'ocean_depths.png',
                          ].map((bg) {
                            return DropdownMenuItem<String>(
                              value: bg,
                              child: Text(bg.replaceAll('_', ' ').replaceAll('.png', '')),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              adminState.updateGameModule(
                                gameModule.copyWith(backgroundImage: value),
                              );
                            }
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Physics settings
                        const Text('Physics Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        
                        // Gravity slider
                        Row(
                          children: [
                            const Text('Gravity: '),
                            Expanded(
                              child: Slider(
                                value: gameModule.physics.gravity,
                                min: 0,
                                max: 20,
                                divisions: 20,
                                label: gameModule.physics.gravity.toStringAsFixed(1),
                                onChanged: (value) {
                                  final updatedPhysics = gameModule.physics.copyWith(gravity: value);
                                  adminState.updateGameModule(
                                    gameModule.copyWith(physics: updatedPhysics),
                                  );
                                },
                              ),
                            ),
                            Text(gameModule.physics.gravity.toStringAsFixed(1)),
                          ],
                        ),
                        
                        // Bounce slider
                        Row(
                          children: [
                            const Text('Bounce: '),
                            Expanded(
                              child: Slider(
                                value: gameModule.physics.bounce,
                                min: 0,
                                max: 1,
                                divisions: 10,
                                label: gameModule.physics.bounce.toStringAsFixed(1),
                                onChanged: (value) {
                                  final updatedPhysics = gameModule.physics.copyWith(bounce: value);
                                  adminState.updateGameModule(
                                    gameModule.copyWith(physics: updatedPhysics),
                                  );
                                },
                              ),
                            ),
                            Text(gameModule.physics.bounce.toStringAsFixed(1)),
                          ],
                        ),
                        
                        // Speed slider
                        Row(
                          children: [
                            const Text('Speed: '),
                            Expanded(
                              child: Slider(
                                value: gameModule.physics.speed,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: gameModule.physics.speed.toStringAsFixed(1),
                                onChanged: (value) {
                                  final updatedPhysics = gameModule.physics.copyWith(speed: value);
                                  adminState.updateGameModule(
                                    gameModule.copyWith(physics: updatedPhysics),
                                  );
                                },
                              ),
                            ),
                            Text(gameModule.physics.speed.toStringAsFixed(1)),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Game element placement
                        const Text('Game Elements', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Platform'),
                              onPressed: () {
                                adminState.addGameElement(
                                  GameElementType.platform,
                                  const Offset(100, 300),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Obstacle'),
                              onPressed: () {
                                adminState.addGameElement(
                                  GameElementType.obstacle,
                                  const Offset(200, 200),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Collectible'),
                              onPressed: () {
                                adminState.addGameElement(
                                  GameElementType.collectible,
                                  const Offset(300, 150),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Right side - preview
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 500,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          // Background image
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/backgrounds/${gameModule.backgroundImage}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Text('Background image preview'),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Game elements
                          ...gameModule.gameElements.map((element) {
                            return Positioned(
                              left: element.position.dx,
                              top: element.position.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  adminState.updateGameElementPosition(
                                    element.id,
                                    element.position + details.delta,
                                  );
                                },
                                child: _buildGameElementWidget(element),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGameElementWidget(GameElement element) {
    // Different visualizations based on element type
    switch (element.type) {
      case GameElementType.platform:
        return Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.brown,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      
      case GameElementType.obstacle:
        return Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        );
      
      case GameElementType.collectible:
        return Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Colors.yellow,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.star, color: Colors.white, size: 20),
        );
      
      default:
        return Container(
          width: 30,
          height: 30,
          color: Colors.purple,
        );
    }
  }
}

// Sample of just one editor - in a real implementation you'd create similar
// editors for characters, obstacles, rewards, etc.
