import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/admin_state.dart';
import 'widgets/step_story_info.dart';
import 'widgets/step_characters.dart';
import 'widgets/step_scenes.dart';
import 'widgets/step_dialogue_editor.dart';
import 'widgets/step_preview.dart';
import 'widgets/step_deploy.dart';

// Import new module creators
import 'mini_game_creator.dart';
import 'cbt_exercise_creator.dart';
import 'quiz_creator.dart';

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
      title: 'Interactive Content Admin Wizard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const ContentWizard(),
    );
  }
}

class ContentWizard extends StatefulWidget {
  const ContentWizard({Key? key}) : super(key: key);

  @override
  _ContentWizardState createState() => _ContentWizardState();
}

class _ContentWizardState extends State<ContentWizard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminState>(
      builder: (context, adminState, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Interactive Content Creator'),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: _showHelpDialog,
                tooltip: 'Help',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showSettingsDialog,
                tooltip: 'Settings',
              ),
            ],
          ),
          drawer: _buildNavigationDrawer(adminState),
          body: _buildContentForActiveModule(adminState),
        );
      },
    );
  }
  
  Widget _buildNavigationDrawer(AdminState adminState) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content Creator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create interactive content for your app',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Content type options
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Visual Novel / Interactive Story'),
            selected: adminState.activeModuleType == ContentModuleType.storyModule,
            onTap: () {
              adminState.setActiveModuleType(ContentModuleType.storyModule);
              if (adminState.storyModule == null) {
                adminState.createNewModule(ContentModuleType.storyModule);
              }
              Navigator.pop(context); // Close drawer
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.sports_esports),
            title: const Text('Mini-Game'),
            selected: adminState.activeModuleType == ContentModuleType.gameModule,
            onTap: () {
              adminState.setActiveModuleType(ContentModuleType.gameModule);
              if (adminState.gameModule == null) {
                adminState.createNewModule(ContentModuleType.gameModule);
              }
              Navigator.pop(context); // Close drawer
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.psychology),
            title: const Text('CBT Exercise'),
            selected: adminState.activeModuleType == ContentModuleType.cbtExercise,
            onTap: () {
              adminState.setActiveModuleType(ContentModuleType.cbtExercise);
              if (adminState.cbtExercise == null) {
                adminState.createNewModule(ContentModuleType.cbtExercise);
              }
              Navigator.pop(context); // Close drawer
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Quiz'),
            selected: adminState.activeModuleType == ContentModuleType.quizModule,
            onTap: () {
              adminState.setActiveModuleType(ContentModuleType.quizModule);
              if (adminState.quizModule == null) {
                adminState.createNewModule(ContentModuleType.quizModule);
              }
              Navigator.pop(context); // Close drawer
            },
          ),
          
          const Divider(),
          
          // Module management options
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create New Module'),
            onTap: () => _showCreateNewModuleDialog(adminState),
          ),
          
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Open Existing Module'),
            onTap: () => _showOpenModuleDialog(adminState),
          ),
          
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Deploy Current Module'),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              await _deployCurrentModule(adminState);
            },
          ),
          
          const Divider(),
          
          // Help and support options
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Documentation'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showHelpDialog();
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildContentForActiveModule(AdminState adminState) {
    switch (adminState.activeModuleType) {
      case ContentModuleType.storyModule:
        return _buildStoryModuleEditor();
      case ContentModuleType.gameModule:
        return _buildGameModuleEditor(adminState);
      case ContentModuleType.cbtExercise:
        return _buildCBTExerciseEditor(adminState);
      case ContentModuleType.quizModule:
        return _buildQuizModuleEditor(adminState);
    }
  }
  
  Widget _buildStoryModuleEditor() {
    // This would integrate with your existing StoryWizard implementation
    return const Center(
      child: Text('Story Module Editor would be integrated here'),
    );
  }
  
  Widget _buildGameModuleEditor(AdminState adminState) {
    if (adminState.gameModule == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return const MiniGameCreator();
  }
  
  Widget _buildCBTExerciseEditor(AdminState adminState) {
    if (adminState.cbtExercise == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return const CBTExerciseCreator();
  }
  
  Widget _buildQuizModuleEditor(AdminState adminState) {
    if (adminState.quizModule == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return const QuizCreator();
  }
  
  // Dialog methods
  void _showCreateNewModuleDialog(AdminState adminState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Module'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select the type of content module to create:'),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Visual Novel / Interactive Story'),
              onTap: () {
                adminState.createNewModule(ContentModuleType.storyModule);
                adminState.setActiveModuleType(ContentModuleType.storyModule);
                Navigator.pop(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.sports_esports),
              title: const Text('Mini-Game'),
              onTap: () {
                adminState.createNewModule(ContentModuleType.gameModule);
                adminState.setActiveModuleType(ContentModuleType.gameModule);
                Navigator.pop(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text('CBT Exercise'),
              onTap: () {
                adminState.createNewModule(ContentModuleType.cbtExercise);
                adminState.setActiveModuleType(ContentModuleType.cbtExercise);
                Navigator.pop(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Quiz'),
              onTap: () {
                adminState.createNewModule(ContentModuleType.quizModule);
                adminState.setActiveModuleType(ContentModuleType.quizModule);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showOpenModuleDialog(AdminState adminState) {
    // This would show a dialog to open existing modules
    // For now, we'll just show a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Existing Module'),
        content: const Text('This feature would allow you to browse and open saved modules.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deployCurrentModule(AdminState adminState) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Deploying content module...'),
          ],
        ),
      ),
    );
    
    // Attempt to deploy the module
    final success = await adminState.deployCurrentModule();
    
    // Close loading dialog
    Navigator.of(context).pop();
    
    // Show result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success ? 'Deployment Successful' : 'Deployment Failed'),
        content: Text(
          success
              ? 'Your content module has been successfully deployed to the app.'
              : 'There was an error deploying your content module. Please try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Documentation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Creating Interactive Content',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This admin wizard allows you to create various types of interactive content:',
              ),
              SizedBox(height: 8),
              Text('• Visual Novels & Interactive Stories'),
              Text('• Mini-Games for learning and engagement'),
              Text('• CBT Exercises for mental wellbeing'),
              Text('• Quizzes for knowledge assessment'),
              SizedBox(height: 16),
              Text(
                'Getting Started',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Select a content type from the navigation drawer'),
              Text('2. Configure the content using the provided tools'),
              Text('3. Preview your creation to test it'),
              Text('4. Deploy it to make it available in your app'),
              SizedBox(height: 16),
              Text(
                'Need More Help?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Refer to the complete documentation at:'),
              Text('https://docs.example.com/admin-wizard'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.color_lens),
              title: Text('Theme'),
              trailing: Text('Light'),
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Language'),
              trailing: Text('English'),
            ),
            ListTile(
              leading: Icon(Icons.cloud),
              title: Text('API Endpoint'),
              trailing: Text('Default'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Interactive Content Admin Wizard',
      applicationVersion: 'v1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      applicationLegalese: '© 2025 Your Organization',
      children: [
        const SizedBox(height: 16),
        const Text(
          'This tool allows you to create and manage interactive content for your app using Flame Engine and Jenny dialogue system.',
        ),
      ],
    );
  }
}
