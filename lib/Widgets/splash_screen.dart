/// splash_screen.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';
import 'package:yokai_quiz_app/screens/Settings/view/language_page.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import '../api/local_storage.dart';
import '../global.dart';
import '../main.dart';
import '../screens/navigation/view/navigation.dart';
import '../services/app_state_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AppStateManager appStateManager;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeStateManager();
    _setupAnimations();
    _startOptimizedSplashFlow();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  /// Initialize the app state manager
  void _initializeStateManager() {
    // Initialize app state manager if not already done
    if (!Get.isRegistered<AppStateManager>()) {
      Get.put(AppStateManager());
    }
    appStateManager = AppStateManager.instance;
  }

  /// Setup progress animation
  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  /// Start the optimized splash flow with API prefetching
  Future<void> _startOptimizedSplashFlow() async {
    try {
      // Start progress animation
      _progressController.forward();
      
      // Setup user preferences early
      await _setupUserPreferences();
      
      // Request permissions in parallel with prefetching
      final permissionsFuture = _requestPermissions();
      
      // App state manager handles the prefetching automatically
      // We just need to wait for the minimum splash duration
      
      // Set up navigation timer for 6 seconds (original duration)
      _navigationTimer = Timer(const Duration(milliseconds: 6000), () {
        if (!_hasNavigated) {
          _navigateToNextScreen();
        }
      });
      
      // Wait for permissions (non-blocking for prefetch)
      await permissionsFuture;
      
    } catch (e) {
      print('❌ Error during splash initialization: $e');
      // Continue with navigation even if there are errors
      if (!_hasNavigated) {
        _navigateToNextScreen();
      }
    }
  }

  /// Setup user preferences (moved out for better organization)
  Future<void> _setupUserPreferences() async {
    try {
      final pref = await SharedPreferences.getInstance();
      constants.appYokaiPath = pref.getString('yokaiImage');
      constants.selectedYokai = pref.getString('yokaiName') ?? 'default_yokai';
    } catch (e) {
      print('⚠️ Error setting up user preferences: $e');
    }
  }

  /// Request necessary permissions
  Future<void> _requestPermissions() async {
    try {
      await [
        Permission.storage,
        Permission.notification,
        Permission.camera,
        Permission.microphone,
      ].request();
    } catch (e) {
      print('⚠️ Error requesting permissions: $e');
    }
  }

  /// Navigate to the appropriate next screen
  Future<void> _navigateToNextScreen() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    // Complete splash screen in state manager
    await appStateManager.completeSplashScreen();
    
    // Check login status
    final isLoggedIn = prefs.getBool(LocalStorage.isLogin) ?? false;
    print("isLogin :: ${prefs.getBool(LocalStorage.isLogin)}");
    print("isLoggedIn :: $isLoggedIn");
    
    // Navigate based on login status
    if (!isLoggedIn) {
      Get.to(
        () => const LoginScreen(
          // isFromSplashScreen: true,
        ),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 1000),
      );
    } else {
      // Navigate to home with optimized loading
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => NavigationPage(),
          transitionDuration: const Duration(milliseconds: 1000),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(),
        child: Stack(
          children: [
            // Main splash content
            Center(
              child: Container(
                child: Image.asset(
                  "gif/elegant-splash-screen.gif",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Subtle progress indicator at bottom
            // Positioned(
            //   bottom: 30,
            //   left: 40,
            //   right: 40,
            //   child: _buildProgressIndicator(),
            // ),
          ],
        ),
      ),
    );
  }



  /// Build subtle progress indicator
  Widget _buildProgressIndicator() {
    return Obx(() {
      final progress = appStateManager.dataLoadProgress;
      
      return AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Container(
            height: 2,
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : _progressAnimation.value,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.3),
              ),
            ),
          );
        },
      );
    });
  }
}
