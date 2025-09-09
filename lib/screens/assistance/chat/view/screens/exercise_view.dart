// lib/screens/assistance/chat/view/screens/exercise_view.dart

import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../models/exercise/Exercise_model.dart';
import '../../../../../util/colors.dart';

class EnhancedExerciseView extends StatefulWidget {
  final String exerciseType;
  final List<Steps> steps;
  final int duration;

  const EnhancedExerciseView({
    Key? key,
    required this.exerciseType,
    required this.steps,
    required this.duration,
  }) : super(key: key);

  @override
  State<EnhancedExerciseView> createState() => _EnhancedExerciseViewState();
}

class _EnhancedExerciseViewState extends State<EnhancedExerciseView>
    with SingleTickerProviderStateMixin {
  // We'll use a simple approach with a reliable audio source
  final AudioPlayer _player = AudioPlayer();
  late FlutterTts _tts;
  late AnimationController _animationController;
  late Timer _timer;
  
  int _currentStepIndex = 0;
  bool _isPlaying = false;
  double _musicVolume = 0.5; // Increased default volume
  bool _isTtsSpeaking = false;
  int _secondsElapsed = 0;
  int _totalSeconds = 0;
  int _stepTimeElapsed = 0;
  int _currentStepDuration = 10; // Default 10 seconds per step if not specified
  bool _canNavigateToNextStep = false;
  bool _canNavigateToPreviousStep = false;
  bool _isMusicPlaying = false;

  // Use a direct MP3 URL that's known to work
  final String _audioUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  @override
  void initState() {
    super.initState();
    _initAudio();
    _initTts();
    _initAnimation();
    _totalSeconds = widget.duration * 60;  // Convert minutes to seconds
    _updateStepDuration();
    
    // Set up player event listeners
    _setupPlayerListeners();
  }
  
  void _setupPlayerListeners() {
    _player.onPlayerStateChanged.listen((state) {
      print('Player state changed: $state');
      
      if (state == PlayerState.playing) {
        setState(() => _isMusicPlaying = true);
      } else if (state == PlayerState.paused || state == PlayerState.stopped) {
        setState(() => _isMusicPlaying = false);
      }
    });
    
    _player.onPlayerComplete.listen((event) {
      print('Music playback completed, restarting');
      // Restart music when it ends
      if (_isPlaying && !_isTtsSpeaking) {
        _playBackgroundMusic();
      }
    });
  }

  void _updateStepDuration() {
    _stepTimeElapsed = 0;
    _canNavigateToNextStep = false;
    _canNavigateToPreviousStep = _currentStepIndex > 0;
    
    if (widget.steps.isNotEmpty && widget.steps[_currentStepIndex].instruction != null) {
      _currentStepDuration = 10;
    }
  }

  Future<void> _initAudio() async {
    // Set volume (0.0 to 1.0)
    await _player.setVolume(_musicVolume);
    // Set release mode to loop
    await _player.setReleaseMode(ReleaseMode.loop);
    print('Audio player initialized with volume: $_musicVolume');
  }

  Future<void> _playBackgroundMusic() async {
    try {
      print('Attempting to play music from URL: $_audioUrl');
      
      if (_isMusicPlaying) {
        await _player.resume();
        print('Resumed existing audio playback');
        return;
      }
      
      // Play from URL
      await _player.play(UrlSource(_audioUrl));
      print('Started playing audio from URL');
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> _pauseBackgroundMusic() async {
    try {
      await _player.pause();
      print('Paused background music');
    } catch (e) {
      print('Error pausing music: $e');
    }
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isTtsSpeaking = false;
        });
        // Resume background music when TTS completes
        if (_isPlaying) {
          _playBackgroundMusic();
        }
      }
    });
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsElapsed < _totalSeconds) {
            _secondsElapsed++;
            _stepTimeElapsed++;
            
            // Enable navigation when step time has elapsed
            if (_stepTimeElapsed >= _currentStepDuration) {
              _canNavigateToNextStep = _currentStepIndex < widget.steps.length - 1;
            }
          } else {
            timer.cancel();
            _completeExercise();
          }
        });
      }
    });
  }

  void _pauseTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
  }

  void _completeExercise() {
    // Stop background music
    _player.stop();
    _isMusicPlaying = false;
    
    // Show completion dialog and handle completion logic
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('images/appLogo_yokai.png', height: 90, width: 90,),
                const SizedBox(height: 16),
                Text(
                  'Exercise Completed!',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Great job completing the ${widget.exerciseType} exercise.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 24),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Text(
                        'Return to Activities',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _player.dispose();
    _tts.stop();
    _animationController.dispose();
    if (_isPlaying) {
      _pauseTimer();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.exerciseType,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildTimer(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.steps.length,
                    (index) => _buildStepIndicator(index),
                  ),
                ),
              ),
              
              // Visualization
              _buildVisualizer(),
              
              // Step timer indicator
              _buildStepTimer(),
              
              // Current step display
              _buildCurrentStep(),
              
              // Controls
              _buildControlButtons(),
              
              // Music control and volume slider
              _buildMusicControl(),
              
              // Volume slider
              _buildVolumeControl(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: primaryLiteColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: primaryColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            _formatTime(_secondsElapsed),
            style: GoogleFonts.montserrat(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTimer() {
    final progress = _currentStepDuration > 0 
        ? _stepTimeElapsed / _currentStepDuration 
        : 1.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step Timer',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${_stepTimeElapsed}s / ${_currentStepDuration}s',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int index) {
    final isActive = index <= _currentStepIndex;
    final isCurrent = index == _currentStepIndex;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isCurrent ? 12 : 10,
      height: isCurrent ? 12 : 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? primaryColor : Colors.grey[300],
        border: isCurrent ? Border.all(color: primaryLiteColor, width: 2) : null,
      ),
    );
  }

  Widget _buildVisualizer() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 180,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background pulse animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 180 + (_animationController.value * 20),
                height: 180 + (_animationController.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryLiteColor.withOpacity(0.3 + (_animationController.value * 0.2)),
                ),
              );
            },
          ),
          
          // Middle ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryLiteColor.withOpacity(0.5),
            ),
          ),
          
          // Step number
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'STEP',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${_currentStepIndex + 1}/${widget.steps.length}',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Step ${_currentStepIndex + 1}',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.steps[_currentStepIndex].instruction ?? 'No instruction provided',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
          if (_isTtsSpeaking) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Speaking...',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMusicControl() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isMusicPlaying ? Icons.music_note : Icons.music_off,
            size: 16,
            color: _isMusicPlaying ? primaryColor : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            _isMusicPlaying ? 'Music playing' : 'Music paused',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: _isMusicPlaying ? primaryColor : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              _isMusicPlaying ? Icons.volume_up : Icons.volume_off,
              size: 20,
              color: _isMusicPlaying ? primaryColor : Colors.grey,
            ),
            onPressed: () {
              if (_isMusicPlaying) {
                _pauseBackgroundMusic();
              } else if (_isPlaying) {
                _playBackgroundMusic();
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildVolumeControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.volume_down, color: Colors.grey),
          Expanded(
            child: Slider(
              value: _musicVolume,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                setState(() {
                  _musicVolume = value;
                });
                _player.setVolume(_musicVolume);
              },
              activeColor: primaryColor,
            ),
          ),
          Icon(Icons.volume_up, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous button
          _buildControlButton(
            icon: Icons.skip_previous_rounded,
            onTap: (_canNavigateToPreviousStep && _currentStepIndex > 0) ? _previousStep : null,
          ),
          
          // Play/Pause button
          _buildPlayButton(),
          
          // Next button
          _buildControlButton(
            icon: Icons.skip_next_rounded,
            onTap: (_canNavigateToNextStep && _currentStepIndex < widget.steps.length - 1) ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final bool isDisabled = onTap == null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[200] : Colors.white,
            shape: BoxShape.circle,
            boxShadow: isDisabled ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: isDisabled ? Colors.grey[300]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isDisabled ? Colors.grey[400] : primaryColor,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isPlaying ? _pauseExercise : _startExercise,
        borderRadius: BorderRadius.circular(40),
        child: Ink(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  Future<void> _startExercise() async {
    setState(() => _isPlaying = true);
    _startTimer();
    
    // First play background music
    await _playBackgroundMusic();
    
    // Then speak the current step (this will pause the music)
    await _speakCurrentStep();
  }

  Future<void> _pauseExercise() async {
    setState(() => _isPlaying = false);
    _pauseTimer();
    await _tts.stop();
    await _pauseBackgroundMusic();
    setState(() => _isTtsSpeaking = false);
  }

  Future<void> _nextStep() async {
    if (_canNavigateToNextStep && _currentStepIndex < widget.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _updateStepDuration();
      });
      
      if (_isPlaying) {
        await _speakCurrentStep();
      }
    }
  }

  Future<void> _previousStep() async {
    if (_canNavigateToPreviousStep && _currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _updateStepDuration();
      });
      
      if (_isPlaying) {
        await _speakCurrentStep();
      }
    }
  }

  Future<void> _speakCurrentStep() async {
    // Pause background music when speaking
    await _pauseBackgroundMusic();
    
    setState(() => _isTtsSpeaking = true);
    await _tts.speak(widget.steps[_currentStepIndex].instruction ?? '');
    // Music will resume automatically in the _tts completion handler
  }
}