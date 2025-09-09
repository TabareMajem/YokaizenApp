/// Enhanced Games Selection Screen
/// Beautiful UI for Unity games with improved UX and responsive design

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../services/unity_game_service.dart';
import '../../../util/colors.dart';
import '../../../util/text_styles.dart';

import 'unity_game_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  final UnityGameService gameService = Get.put(UnityGameService());
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Start animations
    _cardAnimationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 380;
    
    return Scaffold(
      backgroundColor: colorWhite,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          _buildSliverAppBar(),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section with animation
                  FadeTransition(
                    opacity: _cardAnimationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _cardAnimationController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: _buildModernHeaderSection(screenSize),
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 20 : 30),
                  
                  // Games grid with animation
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _cardAnimationController,
                        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                      ),
                    ),
                    child: _buildResponsiveGamesGrid(screenSize),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 20 : 30),
                  
                  // Game statistics with animation
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _cardAnimationController,
                        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                      ),
                    ),
                    child: _buildModernGameStatistics(),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        title: Text(
          'Voice Bridge Games',
          style: AppTextStyle.normalBold18.copyWith(
            color: indigo950,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                indigo500.withOpacity(0.1),
                coral500.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: SvgPicture.asset(
            'icons/arrowLeft.svg',
            color: indigo950,
            width: 20,
            height: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildModernHeaderSection(Size screenSize) {
    final isSmallScreen = screenSize.width < 380;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            indigo500.withOpacity(0.08),
            coral500.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: indigo100, width: 1),
        boxShadow: [
          BoxShadow(
            color: indigo500.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Modern icon container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [indigo500, coral500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: indigo500.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.games,
                  color: Colors.white,
                  size: isSmallScreen ? 24 : 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Bridge Collection',
                      style: (isSmallScreen 
                          ? AppTextStyle.normalBold16 
                          : AppTextStyle.normalBold20).copyWith(
                        color: indigo950,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rhythm-based games combining voice interaction with bridge building',
                      style: AppTextStyle.normalBold12.copyWith(
                        color: indigo700,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Status chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [coral500, coral500.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: coral500.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videogame_asset,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '2 Games Available',
                      style: AppTextStyle.normalBold12.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              
              // Achievement badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: indigo100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: indigo600,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'New',
                      style: AppTextStyle.normalBold10.copyWith(
                        color: indigo600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGamesGrid(Size screenSize) {
    final isSmallScreen = screenSize.width < 380;
    
    final games = [
      {
        'type': GameType.voiceBridge,
        'title': 'VoiceBridge Classic',
        'subtitle': 'Original voice adventure',
        'difficulty': 'Beginner',
        'duration': '10-15 min',
        'color': indigo500,
        'status': 'available',
        'players': '1P',
        'rating': 4.8,
      },
      {
        'type': GameType.voiceBridgePolished,
        'title': 'VoiceBridge Polished',
        'subtitle': 'Enhanced graphics & mechanics',
        'difficulty': 'Intermediate',
        'duration': '15-20 min',
        'color': coral500,
        'status': 'available',
        'players': '1P',
        'rating': 4.9,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Games',
          style: (isSmallScreen 
              ? AppTextStyle.normalBold18 
              : AppTextStyle.normalBold20).copyWith(
            color: indigo950,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: games.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildModernGameCard(games[index], screenSize, index);
          },
        ),
      ],
    );
  }

  Widget _buildModernGameCard(Map<String, dynamic> game, Size screenSize, int index) {
    final gameType = game['type'] as GameType;
    final isAvailable = game['status'] == 'available';
    final isSmallScreen = screenSize.width < 380;
    
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        final slideValue = Tween<double>(
          begin: 100.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            0.2 + (index * 0.1),
            0.8 + (index * 0.1),
            curve: Curves.easeOutCubic,
          ),
        )).value;

        return Transform.translate(
          offset: Offset(0, slideValue),
          child: GestureDetector(
            onTap: isAvailable ? () => _launchGame(gameType) : null,
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isAvailable 
                      ? (game['color'] as Color).withOpacity(0.2) 
                      : greyCh.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isAvailable 
                        ? (game['color'] as Color).withOpacity(0.15) 
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Main content row
                  Row(
                    children: [
                      // Game icon
                      Hero(
                        tag: 'game_icon_$index',
                        child: Container(
                          width: isSmallScreen ? 60 : 70,
                          height: isSmallScreen ? 60 : 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                game['color'] as Color,
                                (game['color'] as Color).withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (game['color'] as Color).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: isSmallScreen ? 24 : 28,
                              ),
                              if (isAvailable)
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(9),
                                      border: Border.all(
                                        color: game['color'] as Color,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: game['color'] as Color,
                                      size: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Game info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game['title'] as String,
                              style: (isSmallScreen 
                                  ? AppTextStyle.normalBold14 
                                  : AppTextStyle.normalBold16).copyWith(
                                color: indigo950,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            
                            Text(
                              game['subtitle'] as String,
                              style: AppTextStyle.normalBold12.copyWith(
                                color: indigo600,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            
                            // Rating
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < (game['rating'] as double).floor() 
                                          ? Icons.star 
                                          : Icons.star_outline,
                                      color: coral500,
                                      size: 14,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  game['rating'].toString(),
                                  style: AppTextStyle.normalBold10.copyWith(
                                    color: coral500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Play button
                      if (isAvailable)
                        Container(
                          width: isSmallScreen ? 44 : 50,
                          height: isSmallScreen ? 44 : 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                game['color'] as Color,
                                (game['color'] as Color).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: (game['color'] as Color).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: isSmallScreen ? 20 : 24,
                          ),
                        )
                      else
                        Container(
                          width: isSmallScreen ? 44 : 50,
                          height: isSmallScreen ? 44 : 50,
                          decoration: BoxDecoration(
                            color: greyCh,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.lock,
                            color: grey2,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Game tags
                  Row(
                    children: [
                      _buildModernGameTag(
                        icon: Icons.trending_up,
                        text: game['difficulty'] as String,
                        color: game['color'] as Color,
                        isSmall: isSmallScreen,
                      ),
                      const SizedBox(width: 8),
                      _buildModernGameTag(
                        icon: Icons.timer,
                        text: game['duration'] as String,
                        color: indigo500,
                        isSmall: isSmallScreen,
                      ),
                      const SizedBox(width: 8),
                      _buildModernGameTag(
                        icon: Icons.person,
                        text: game['players'] as String,
                        color: coral500,
                        isSmall: isSmallScreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernGameTag({
    required IconData icon,
    required String text,
    required Color color,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmall ? 10 : 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: (isSmall 
                ? AppTextStyle.normalBold10 
                : AppTextStyle.normalBold12).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernGameStatistics() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: indigo100),
        boxShadow: [
          BoxShadow(
            color: indigo500.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: indigo500,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Gaming Stats',
                style: AppTextStyle.normalBold18.copyWith(
                  color: indigo950,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.emoji_events,
                  title: 'High Score',
                  value: '2,450',
                  color: coral500,
                  subtitle: 'Personal Best',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.schedule,
                  title: 'Play Time',
                  value: '45 min',
                  color: indigo500,
                  subtitle: 'Total Time',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            value,
            style: AppTextStyle.normalBold18.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          Text(
            title,
            style: AppTextStyle.normalBold12.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          
          Text(
            subtitle,
            style: AppTextStyle.normalBold10.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _launchGame(GameType gameType) async {
    // Show modern loading dialog
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [indigo500, coral500],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(Icons.hourglass_bottom)
                /*Lottie.asset(
                  'image/loader2.json',
                  width: 60,
                  height: 60,
                ),*/
              ),
              const SizedBox(height: 24),
              
              Text(
                'Loading Game...',
                style: AppTextStyle.normalBold18.copyWith(
                  color: indigo950,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Preparing Unity environment',
                style: AppTextStyle.normalBold12.copyWith(
                  color: grey2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Progress indicator
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: indigo100,
                  valueColor: AlwaysStoppedAnimation<Color>(coral500),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Initialize game
    final success = await gameService.initializeGame(gameType);
    
    // Close loading dialog
    Get.back();
    
    if (success) {
      // Navigate to game screen with hero animation
      Get.to(
        () => UnityGameScreen(gameType: gameType),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      // Show modern error dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Game Launch Failed',
                  style: AppTextStyle.normalBold16.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Unable to start the game. Please try again.',
                  style: AppTextStyle.normalBold12.copyWith(
                    color: grey2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: coral500,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: AppTextStyle.normalBold14.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}