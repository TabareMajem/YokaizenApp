/// navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';


import '../../../util/colors.dart';
import '../../../util/text_styles.dart';
import '../../../util/constants.dart';
import '../../assistance/view/screens/assistance_screen.dart';
import '../../chat/view/characters_page.dart';
import '../../games/view/games_screen.dart';
import '../../home/view/home_screen.dart';
import '../../profile/view/profile_screen.dart';
import '../../read/view/browse_stories_page.dart';
import 'package:get/get.dart';

class NavigationPage extends StatefulWidget {
  NavigationPage({super.key, this.index = 0});

  final int index;

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  var _currentIndex = 0;
  // Add a key to access the YokaiAssistanceScreen
  final GlobalKey<YokaiAssistanceScreenState> _yokaiScreenKey = GlobalKey<YokaiAssistanceScreenState>();

  @override
  void initState() {
    // TODO: implement initState
    // notification();

    super.initState();
    if (widget.index != '') {
      _currentIndex = widget.index;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: colorWhite,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SalomonBottomBar(
            backgroundColor: navigationBackground,
            selectedColorOpacity: 1,
            selectedItemColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (i) {
              setState(() => _currentIndex = i);
              
              // Show Yokai selection bottom sheet when Yokai tab is tapped
              if (i == 4 && constants.appYokaiPath == null) {
                // Use a small delay to ensure the screen is built
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_yokaiScreenKey.currentState != null) {
                    _yokaiScreenKey.currentState!.showYokaiSelectionBottomSheet();
                  }
                });
              }
            },
            items: [
              SalomonBottomBarItem(
                activeIcon: SvgPicture.asset(
                  'icons/home.svg',
                  color: Colors.white,
                ),
                icon: SvgPicture.asset(
                  'icons/home2.svg',
                ),
                title: Text(
                  " Home ".tr,
                  style: AppTextStyle.questionAnswer.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                selectedColor: coral500,
              ),
              SalomonBottomBarItem(
                activeIcon: SvgPicture.asset(
                  'icons/read.svg',
                  color: Colors.white,
                ),
                icon: SvgPicture.asset('icons/read2.svg'),
                title: Text(
                  " Read ".tr,
                  style: AppTextStyle.questionAnswer.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                selectedColor: coral500,
              ),
              SalomonBottomBarItem(
                activeIcon: SvgPicture.asset(
                  'icons/chat.svg',
                  color: Colors.white,
                ),
                icon: SvgPicture.asset('icons/chat2.svg'),
                title: Text(
                  " Chat ".tr,
                  style: AppTextStyle.questionAnswer.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                selectedColor: coral500,
              ),
             /* SalomonBottomBarItem(
                activeIcon: Icon(
                  Icons.games,
                  color: Colors.white,
                ),
                icon: Icon(
                  Icons.games_outlined,
                  color: Colors.white70,
                ),
                title: Text(
                  " Games ".tr,
                  style: AppTextStyle.questionAnswer.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                selectedColor: coral500,
              ),*/
              SalomonBottomBarItem(
                activeIcon: SvgPicture.asset(
                  'images/yokai_outline.svg',
                  color: Colors.white,
                ),
                icon: SvgPicture.asset('images/yokai_outline.svg'),
                title: Text(
                  " Yokai ".tr,
                  style: AppTextStyle.questionAnswer.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      ),
                ),
                selectedColor: coral500,
              ),
              SalomonBottomBarItem(
                activeIcon: SvgPicture.asset(
                  'icons/profile.svg',
                  color: Colors.white,
                ),
                icon: SvgPicture.asset('icons/profile2.svg'),
                title: Text(
                  " Profile ".tr,
                  style: AppTextStyle.questionAnswer.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                selectedColor: coral500,
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(),
            BrowseStoriesPage(),
            CharactersPage(),
            GamesScreen(),
            // ChallengeScreen(), // over here
            YokaiAssistanceScreen(key: _yokaiScreenKey),
            ProfileScreen(),
          ],
        ),
      ),
    );
  }
}
