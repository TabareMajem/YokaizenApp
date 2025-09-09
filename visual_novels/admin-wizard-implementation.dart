import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/story_module.dart';
import 'models/admin_state.dart';
import 'widgets/step_story_info.dart';
import 'widgets/step_characters.dart';
import 'widgets/step_scenes.dart';
import 'widgets/step_dialogue_editor.dart';
import 'widgets/step_preview.dart';
import 'widgets/step_deploy.dart';
import 'services/content_api.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AdminState()),
      ],
      child: const AdminWizardApp(),
    ),
  );
}

class AdminWizardApp extends StatelessWidget {
  const AdminWizardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Story Admin Wizard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const StoryWizard(),
    );
  }
}

class StoryWizard extends StatefulWidget {
  const StoryWizard({Key? key}) : super(key: key);

  @override
  _StoryWizardState createState() => _StoryWizardState();
}

class _StoryWizardState extends State<StoryWizard> {
  int _currentStep = 0;
  final ContentApi _contentApi = ContentApi();
  
  final List<String> _stepTitles = [
    'Story Information',
    'Characters',
    'Scenes & Backgrounds',
    'Dialogue Editor',
    'Preview',
    'Deploy'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Story Creator - ${_stepTitles[_currentStep]}'),
        elevation: 0,
      ),
      body: Row(
        children: [
          // Sidebar navigation
          NavigationRail(
            selectedIndex: _currentStep,
            onDestinationSelected: (int index) {
              // Validate current step before moving
              if (_validateCurrentStep()) {
                setState(() {
                  _currentStep = index;
                });
              }
            },
            destinations: _stepTitles.map((title) {
              return NavigationRailDestination(
                icon: Icon(_getIconForStep(_stepTitles.indexOf(title))),
                label: Text(title),
              );
            }).toList(),
            extended: true,
            minExtendedWidth: 200,
          ),
          
          // Main content area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildCurrentStep(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              if (_currentStep > 0)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  child: const Text('Previous'),
                ),
              if (_currentStep == 0)
                const SizedBox(width: 88), // Space holder for alignment
                
              // Next/Finish button
              ElevatedButton(
                onPressed: () async {
                  if (_validateCurrentStep()) {
                    if (_currentStep < _stepTitles.length - 1) {
                      setState(() {
                        _currentStep++;
                      });
                    } else {
                      // Final step - deploy the story
                      await _deployStory();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStep == _stepTitles.length - 1 
                      ? Colors.green 
                      : Theme.of(context).primaryColor,
                ),
                child: Text(_currentStep == _stepTitles.length - 1 ? 'Deploy' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    final adminState = Provider.of<AdminState>(context);
    
    switch (_currentStep) {
      case 0:
        return StoryInfoStep(adminState: adminState);
      case 1:
        return CharactersStep(adminState: adminState);
      case 2:
        return ScenesStep(adminState: adminState);
      case 3:
        return DialogueEditorStep(adminState: adminState);
      case 4:
        return PreviewStep(adminState: adminState);
      case 5:
        return DeployStep(adminState: adminState);
      default:
        return const Center(child: Text('Unknown step'));
    }
  }

  IconData _getIconForStep(int step) {
    switch (step) {
      case 0:
        return Icons.info_outline;
      case 1:
        return Icons.people_outline;
      case 2:
        return Icons.image_outlined;
      case 3:
        return Icons.forum_outlined;
      case 4:
        return Icons.visibility_outlined;
      case 5:
        return Icons.cloud_upload_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  bool _validateCurrentStep() {
    final adminState = Provider.of<AdminState>(context, listen: false);
    String? errorMessage;
    
    switch (_currentStep) {
      case 0: // Story Info
        if (adminState.storyModule.title.isEmpty) {
          errorMessage = 'Please enter a story title';
        }
        break;
      case 1: // Characters
        if (adminState.storyModule.characters.isEmpty) {
          errorMessage = 'Please add at least one character';
        }
        break;
      case 2: // Scenes
        if (adminState.storyModule.scenes.isEmpty) {
          errorMessage = 'Please add at least one scene';
        }
        break;
      case 3: // Dialogue
        if (adminState.storyModule.nodes.isEmpty) {
          errorMessage = 'Please add some dialogue content';
        }
        break;
      // No validation for Preview and Deploy steps
    }
    
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage))
      );
      return false;
    }
    
    return true;
  }

  Future<void> _deployStory() async {
    final adminState = Provider.of<AdminState>(context, listen: false);
    
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deploying story module...')
              ],
            ),
          );
        },
      );
      
      // Deploy story to backend
      final result = await _contentApi.deployStory(adminState.storyModule);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Deployment Successful'),
            content: Text('Your story "${adminState.storyModule.title}" has been deployed successfully. It is now available in the app.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Reset the form for a new story
                  adminState.resetState();
                  setState(() {
                    _currentStep = 0;
                  });
                },
                child: const Text('Create Another Story'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Deployment Failed'),
            content: Text('Error: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
