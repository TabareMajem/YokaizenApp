import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:yokai_quiz_app/screens/challenge/view/challenge_screen.dart';
import 'package:yokai_quiz_app/screens/profile/view/profileScreen.dart';

import '../../../util/colors.dart';
import '../../../util/text_styles.dart';
import '../../chat/view/characters_page.dart';
import '../../home/view/home_screen.dart';
import '../../read/view/browse_stories_page.dart';
import 'package:get/get.dart';

class NavigationPage extends StatefulWidget {
  NavigationPage({this.index = 0});

  int index = 0;

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  var _currentIndex = 0;

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
            onTap: (i) => setState(() => _currentIndex = i),
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
              SalomonBottomBarItem(
                activeIcon: SvgPicture.asset(
                  'icons/challenge.svg',
                  color: Colors.white,
                ),
                icon: SvgPicture.asset('icons/challenge.svg'),
                title: Text(
                  " Challenge ".tr,
                  style: AppTextStyle.questionAnswer.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 8),
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
          children: const [
            HomeScreen(),
            BrowseStoriesPage(),
            CharactersPage(),
            ChallengePage(),
            ProfileScreen(),
          ],
        ),
      ),
    );
  }
}
