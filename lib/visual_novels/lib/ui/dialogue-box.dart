import 'package:flutter/material.dart';
import 'dart:async';
import '../managers/assets-manager.dart';

class DialogueBox extends StatefulWidget {
  final String characterName;
  final String text;
  final Function() onNext;
  final List<String>? choices;
  final Function(String)? onChoice;
  final AssetsManager? assetsManager;
  final bool autoPlay;

  const DialogueBox({
    super.key,
    required this.characterName,
    required this.text,
    required this.onNext,
    this.choices,
    this.onChoice,
    this.assetsManager,
    this.autoPlay = false,
  });

  @override
  State<DialogueBox> createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> with SingleTickerProviderStateMixin {
  String _displayedText = '';
  int _currentCharIndex = 0;
  bool _isTyping = false;
  bool _isCompleted = false;
  Timer? _textTimer;
  Timer? _autoPlayTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = false;
  // Special flag to identify the end of chapter message
  bool get _isEndOfChapterMessage => 
      widget.text.trim() == "End of chapter reached. Thank you for reading!";

  // Get text speed from assets manager or use default
  int get _textSpeed => widget.assetsManager?.getTextSpeed() ?? 30;

  // Get auto play delay from assets manager or use default
  int get _autoPlayDelay => widget.assetsManager?.getAutoPlayDelay() ?? 2000;

  @override
  void initState() {
    super.initState();

    // Setup fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();

    // Start typing animation
    _startTypingAnimation();
  }

  @override
  void didUpdateWidget(DialogueBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If text changed, reset and start typing again
    if (oldWidget.text != widget.text) {
      _resetTyping();
      _fadeController.reset();
      _fadeController.forward();
      
      // Reset scroll position
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      _showScrollHint = false;
    }
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _autoPlayTimer?.cancel();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetTyping() {
    _textTimer?.cancel();
    _autoPlayTimer?.cancel();
    _currentCharIndex = 0;
    _displayedText = '';
    _isTyping = false;
    _isCompleted = false;

    // Start typing animation again
    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    setState(() {
      _isTyping = true;
      _isCompleted = false;
    });

    // Calculate delay between characters based on text speed (characters per second)
    final delay = 1000 ~/ _textSpeed;

    _textTimer = Timer.periodic(Duration(milliseconds: delay), (timer) {
      if (_currentCharIndex < widget.text.length) {
        setState(() {
          _displayedText = widget.text.substring(0, _currentCharIndex + 1);
          _currentCharIndex++;
        });
        
        // Check if we need to auto-scroll to keep up with typing
        _checkForAutoScroll();
      } else {
        timer.cancel();
        setState(() {
          _isTyping = false;
          _isCompleted = true;
          
          // Check if text needs scrolling
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && 
                _scrollController.position.maxScrollExtent > 0) {
              setState(() {
                _showScrollHint = true;
              });
            }
          });
        });

        // Start auto play timer if enabled
        if (widget.autoPlay && widget.choices == null) {
          _autoPlayTimer = Timer(Duration(milliseconds: _autoPlayDelay), () {
            widget.onNext();
          });
        }
      }
    });
  }
  
  void _checkForAutoScroll() {
    // Only auto-scroll during typing if near the end
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 50) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // Complete current text immediately
  void _completeText() {
    if (_isTyping) {
      _textTimer?.cancel();
      setState(() {
        _displayedText = widget.text;
        _currentCharIndex = widget.text.length;
        _isTyping = false;
        _isCompleted = true;
        
        // Check if text needs scrolling
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && 
              _scrollController.position.maxScrollExtent > 0) {
            setState(() {
              _showScrollHint = true;
            });
          }
        });
      });
    } else if (_isCompleted && widget.choices == null) {
      // If text is already complete, proceed to next
      _autoPlayTimer?.cancel();
      widget.onNext();
    }
  }

  // Handle next button click with special case for end message
  void _handleNextButtonClick() {
    // Check if this is the end of chapter message
    if (widget.text == "End of chapter reached. Thank you for reading!") {
      print("End of chapter message detected, showing exit dialogue from dialogue box");
      // Find the parent VisualNovelUI widget and show the exit dialogue
      final context = this.context;
      // Delay slightly to ensure proper execution order
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text('Chapter Complete', style: TextStyle(color: Colors.white)),
            content: const Text(
              'You have reached the end of this chapter. Would you like to return to the main game?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Exit back to main game
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        );
      });
    }
    
    // Always call the original onNext handler
    _autoPlayTimer?.cancel();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _completeText,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Dialogue Box Background (text_box.png)
              Image.asset(
                'visualassets/ui/dialogue/text_box.png',
                fit: BoxFit.contain,
                width: double.infinity,
              ),
              
              // Name Plate (positioned above the text box)
              if (widget.characterName.isNotEmpty)
                Positioned(
                  top: -20, // Position the name plate slightly above the text box
                  left: 20,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Name Plate Background
                      Image.asset(
                        'visualassets/ui/dialogue/name_plate.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      // Character Name Text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          widget.characterName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                     ],
                  ),
                ),

              // Dialogue Text - Now Scrollable
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 25, 30, 45),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      _displayedText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Scroll hint indicator (if text is scrollable)
              if (_showScrollHint)
                Positioned(
                  right: 45,
                  bottom: 45,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                ),

              // Next Button (positioned at bottom right)
              if (_isCompleted && (widget.choices == null || widget.choices!.isEmpty))
                Positioned(
                  bottom: 10,
                  right: 20,
                  child: GestureDetector(
                    onTap: _handleNextButtonClick,
                    child: Image.asset(
                      'visualassets/ui/dialogue/next_button.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),

              // Choices (if any)
              if (_isCompleted && widget.choices != null && widget.choices!.isNotEmpty)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 10,
                  child: _buildChoices(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.choices!.map((choice) =>
          TextButton(
            onPressed: () => widget.onChoice?.call(choice),
            style: TextButton.styleFrom(
              backgroundColor: Colors.black38,
              padding: EdgeInsets.zero,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                choice,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ).toList(),
    );
  }
}